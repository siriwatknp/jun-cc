#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$SCRIPT_DIR/targets.json"

for cmd in jq gum; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd is required. Install with: brew install $cmd"
    exit 1
  fi
done

expand_path() { echo "${1/#\~/$HOME}"; }

# Get mtime of a file (macOS compatible)
get_mtime() { stat -f %m "$1" 2>/dev/null || echo 0; }

# Get newest mtime in a directory (recursive)
get_newest_mtime() {
  local dir="$1"
  local newest=0
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    local mt
    mt=$(get_mtime "$f")
    (( mt > newest )) && newest=$mt
  done < <(find "$dir" -type f 2>/dev/null)
  echo "$newest"
}

# Compare source vs target, return "newer", "older", "same", or "missing"
compare_item() {
  local src="$1" dest="$2"
  [[ ! -e "$dest" ]] && echo "missing" && return
  [[ ! -e "$src" ]] && echo "new" && return

  if [[ -d "$src" ]]; then
    local src_mt dest_mt
    src_mt=$(get_newest_mtime "$src")
    dest_mt=$(get_newest_mtime "$dest")
    if (( dest_mt > src_mt )); then
      echo "newer"
    elif (( dest_mt < src_mt )); then
      echo "older"
    else
      echo "same"
    fi
  else
    local src_mt dest_mt
    src_mt=$(get_mtime "$src")
    dest_mt=$(get_mtime "$dest")
    if (( dest_mt > src_mt )); then
      echo "newer"
    elif (( dest_mt < src_mt )); then
      echo "older"
    else
      echo "same"
    fi
  fi
}

# Only consider copy targets (symlinks already point to source)
COPY_TARGETS=""
ALL_TARGETS=$(jq -r '.targets | keys[]' "$CONFIG")
while IFS= read -r target; do
  [[ -z "$target" ]] && continue
  method=$(jq -r ".targets[\"$target\"].method" "$CONFIG")
  [[ "$method" == "copy" ]] || continue
  COPY_TARGETS="${COPY_TARGETS}${target}"$'\n'
done <<< "$ALL_TARGETS"
COPY_TARGETS="$(echo "$COPY_TARGETS" | sed '/^$/d')"

if [[ -z "$COPY_TARGETS" ]]; then
  echo "No copy targets found (symlink targets don't need sync-back)."
  exit 0
fi

# Select targets
if [[ $# -gt 0 ]]; then
  SELECTED="$*"
else
  SELECTED=$(echo "$COPY_TARGETS" | gum filter --no-limit --header "Select targets to sync back from:" --selected="*")
  if [[ -z "$SELECTED" ]]; then
    echo "No targets selected."
    exit 0
  fi
fi

# Collect all changed items across selected targets
CHANGES=""

for target in $SELECTED; do
  DEST_BASE=$(expand_path "$(jq -r ".targets[\"$target\"].path" "$CONFIG")")

  # Check skills
  SKILLS_CFG=$(jq -r ".targets[\"$target\"].skills" "$CONFIG")
  if [[ "$SKILLS_CFG" == '"*"' ]]; then
    SKILLS=$(ls -1 "$SCRIPT_DIR/skills/" 2>/dev/null || true)
  else
    SKILLS=$(jq -r ".targets[\"$target\"].skills[]" "$CONFIG" 2>/dev/null || true)
  fi

  while IFS= read -r skill; do
    [[ -z "$skill" ]] && continue
    local_src="$SCRIPT_DIR/skills/$skill"
    remote="$DEST_BASE/skills/$skill"
    status=$(compare_item "$local_src" "$remote")
    if [[ "$status" == "newer" || "$status" == "new" ]]; then
      CHANGES="${CHANGES}[$target] skill: $skill ($status)"$'\n'
    fi
  done <<< "$SKILLS"

  # Check commands
  COMMANDS_CFG=$(jq -r ".targets[\"$target\"].commands" "$CONFIG")
  if [[ "$COMMANDS_CFG" == '"*"' ]]; then
    CMDS=""
    while IFS= read -r f; do
      [[ -z "$f" ]] && continue
      rel="${f#$SCRIPT_DIR/commands/}"
      CMDS="${CMDS}${rel%.md}"$'\n'
    done < <(find "$SCRIPT_DIR/commands" -name '*.md' -type f 2>/dev/null || true)
  else
    CMDS=$(jq -r ".targets[\"$target\"].commands[]" "$CONFIG" 2>/dev/null || true)
  fi

  while IFS= read -r cmd_name; do
    [[ -z "$cmd_name" ]] && continue
    local_src="$SCRIPT_DIR/commands/$cmd_name.md"
    remote="$DEST_BASE/commands/$cmd_name.md"
    status=$(compare_item "$local_src" "$remote")
    if [[ "$status" == "newer" || "$status" == "new" ]]; then
      CHANGES="${CHANGES}[$target] command: $cmd_name ($status)"$'\n'
    fi
  done <<< "$CMDS"

  # Check agent-md
  AGENT_MD=$(jq -r ".targets[\"$target\"].agent_md // false" "$CONFIG")
  if [[ "$AGENT_MD" == "true" ]] && [[ -d "$SCRIPT_DIR/agent-md" ]]; then
    for src_file in "$SCRIPT_DIR/agent-md"/*; do
      [[ ! -f "$src_file" ]] && continue
      filename="$(basename "$src_file")"

      # Find the target file (same logic as distribute.sh)
      target_file=""
      if [[ -f "$DEST_BASE/$filename" ]]; then
        target_file="$DEST_BASE/$filename"
      elif [[ -f "$(dirname "$DEST_BASE")/$filename" ]]; then
        target_file="$(dirname "$DEST_BASE")/$filename"
      fi
      [[ -z "$target_file" ]] && continue

      # Extract the tagged section from target and compare to source
      begin_marker="<!-- BEGIN jun-cc:agent-md -->"
      end_marker="<!-- END jun-cc:agent-md -->"
      if grep -qF "$begin_marker" "$target_file" 2>/dev/null; then
        current_content=$(awk -v begin="$begin_marker" -v end="$end_marker" '
          $0 == begin { skip=1; next }
          $0 == end { skip=0; next }
          skip { print }
        ' "$target_file")
        source_content=$(cat "$src_file")
        if [[ "$current_content" != "$source_content" ]]; then
          CHANGES="${CHANGES}[$target] agent-md: $filename (modified)"$'\n'
        fi
      fi
    done
  fi
done

CHANGES="$(echo "$CHANGES" | sed '/^$/d')"

if [[ -z "$CHANGES" ]]; then
  echo "Everything is up to date. No changes to sync back."
  exit 0
fi

# Let user pick which changes to sync
echo "Detected changes at targets:"
echo ""

SELECTED_CHANGES=$(echo "$CHANGES" | gum filter --no-limit --header "Select changes to sync back:" --selected="*")
if [[ -z "$SELECTED_CHANGES" ]]; then
  echo "Nothing selected."
  exit 0
fi

echo ""
echo "Will sync back:"
echo "$SELECTED_CHANGES" | sed 's/^/  /'
echo ""
gum confirm "Proceed?" || exit 0

# Apply selected changes
while IFS= read -r line; do
  [[ -z "$line" ]] && continue

  # Parse: [target] type: name (status)
  target=$(echo "$line" | sed 's/^\[\(.*\)\].*/\1/')
  rest=$(echo "$line" | sed 's/^\[.*\] //')
  type=$(echo "$rest" | cut -d: -f1)
  name_status=$(echo "$rest" | cut -d: -f2- | sed 's/^ //')
  name=$(echo "$name_status" | sed 's/ (.*)//')

  DEST_BASE=$(expand_path "$(jq -r ".targets[\"$target\"].path" "$CONFIG")")

  case "$type" in
    skill)
      remote="$DEST_BASE/skills/$name"
      local_dest="$SCRIPT_DIR/skills/$name"
      if [[ -d "$local_dest" ]]; then
        rm -rf "$local_dest"
      fi
      cp -R "$remote" "$local_dest"
      echo "  SYNC skill $name ← $target"
      ;;
    command)
      remote="$DEST_BASE/commands/$name.md"
      local_dest="$SCRIPT_DIR/commands/$name.md"
      mkdir -p "$(dirname "$local_dest")"
      cp "$remote" "$local_dest"
      echo "  SYNC command $name ← $target"
      ;;
    agent-md)
      target_file=""
      if [[ -f "$DEST_BASE/$name" ]]; then
        target_file="$DEST_BASE/$name"
      elif [[ -f "$(dirname "$DEST_BASE")/$name" ]]; then
        target_file="$(dirname "$DEST_BASE")/$name"
      fi
      if [[ -n "$target_file" ]]; then
        begin_marker="<!-- BEGIN jun-cc:agent-md -->"
        end_marker="<!-- END jun-cc:agent-md -->"
        content=$(awk -v begin="$begin_marker" -v end="$end_marker" '
          $0 == begin { skip=1; next }
          $0 == end { skip=0; next }
          skip { print }
        ' "$target_file")
        echo "$content" > "$SCRIPT_DIR/agent-md/$name"
        echo "  SYNC agent-md $name ← $target"
      fi
      ;;
  esac
done <<< "$SELECTED_CHANGES"

echo ""
echo "Done."

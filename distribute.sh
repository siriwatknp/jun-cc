#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$SCRIPT_DIR/targets.json"

# Check deps
for cmd in jq gum; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd is required. Install with: brew install $cmd"
    exit 1
  fi
done

# Read target names
TARGETS=$(jq -r '.targets | keys[]' "$CONFIG")
if [[ -z "$TARGETS" ]]; then
  echo "No targets found in $CONFIG"
  exit 1
fi

# Multi-select targets
SELECTED=$(echo "$TARGETS" | gum filter --no-limit --header "Select targets to distribute to:")
if [[ -z "$SELECTED" ]]; then
  echo "No targets selected."
  exit 0
fi

expand_path() {
  echo "${1/#\~/$HOME}"
}

distribute_item() {
  local type="$1" name="$2" method="$3" dest_base="$4"

  if [[ "$type" == "skill" ]]; then
    local src="$SCRIPT_DIR/skills/$name"
    local dest="$dest_base/skills/$name"
  else
    local src="$SCRIPT_DIR/commands/$name.md"
    local dest="$dest_base/commands/$name.md"
  fi

  if [[ ! -e "$src" ]]; then
    echo "  SKIP $type $name (source not found: $src)"
    return
  fi

  mkdir -p "$(dirname "$dest")"

  if [[ "$method" == "symlink" ]]; then
    if [[ -L "$dest" ]]; then
      rm "$dest"
    elif [[ -d "$dest" ]]; then
      rm -rf "$dest"
    elif [[ -f "$dest" ]]; then
      rm "$dest"
    fi
    ln -s "$src" "$dest"
    echo "  LINK $type $name"
  else
    if [[ -L "$dest" ]]; then
      rm "$dest"
    elif [[ -d "$dest" ]]; then
      rm -rf "$dest"
    elif [[ -f "$dest" ]]; then
      rm "$dest"
    fi
    cp -R "$src" "$dest"
    echo "  COPY $type $name"
  fi
}

clean_stale() {
  local target="$1" dest_base="$2" skills_cfg="$3" commands_cfg="$4"

  # Clean stale skills
  local skills_dir="$dest_base/skills"
  if [[ -d "$skills_dir" ]]; then
    for item in "$skills_dir"/*/; do
      [[ ! -d "$item" ]] && continue
      local name="$(basename "$item")"
      if [[ "$skills_cfg" == '"*"' ]]; then
        [[ -d "$SCRIPT_DIR/skills/$name" ]] && continue
      else
        [[ ! -d "$SCRIPT_DIR/skills/$name" ]] && continue
        jq -e ".targets[\"$target\"].skills | index(\"$name\")" "$CONFIG" &>/dev/null && continue
      fi
      rm -rf "$item"
      echo "  CLEAN skill $name"
    done
  fi

  # Clean stale commands
  local cmds_dir="$dest_base/commands"
  if [[ -d "$cmds_dir" ]]; then
    while IFS= read -r file; do
      [[ -z "$file" ]] && continue
      local rel="${file#$cmds_dir/}"
      local name="${rel%.md}"
      if [[ "$commands_cfg" == '"*"' ]]; then
        [[ -f "$SCRIPT_DIR/commands/$name.md" ]] && continue
      else
        [[ ! -f "$SCRIPT_DIR/commands/$name.md" ]] && continue
        jq -e ".targets[\"$target\"].commands | index(\"$name\")" "$CONFIG" &>/dev/null && continue
      fi
      rm -f "$file"
      echo "  CLEAN command $name"
    done < <(find "$cmds_dir" -name '*.md' -type f -o -name '*.md' -type l)

    find "$cmds_dir" -type d -empty -delete 2>/dev/null || true
  fi
}

for target in $SELECTED; do
  echo ""
  echo "=== $target ==="

  METHOD=$(jq -r ".targets[\"$target\"].method" "$CONFIG")
  DEST_BASE=$(expand_path "$(jq -r ".targets[\"$target\"].path" "$CONFIG")")

  # Resolve skills ("*" = all)
  SKILLS_CFG=$(jq -r ".targets[\"$target\"].skills" "$CONFIG")
  if [[ "$SKILLS_CFG" == '"*"' ]]; then
    SKILLS=$(ls -1 "$SCRIPT_DIR/skills/" 2>/dev/null || true)
  else
    SKILLS=$(jq -r ".targets[\"$target\"].skills[]" "$CONFIG" 2>/dev/null || true)
  fi

  # Resolve commands ("*" = all)
  COMMANDS_CFG=$(jq -r ".targets[\"$target\"].commands" "$CONFIG")
  if [[ "$COMMANDS_CFG" == '"*"' ]]; then
    COMMANDS=""
    while IFS= read -r f; do
      [[ -z "$f" ]] && continue
      rel="${f#$SCRIPT_DIR/commands/}"
      COMMANDS="${COMMANDS}${rel%.md}"$'\n'
    done < <(find "$SCRIPT_DIR/commands" -name '*.md' -type f 2>/dev/null || true)
  else
    COMMANDS=$(jq -r ".targets[\"$target\"].commands[]" "$CONFIG" 2>/dev/null || true)
  fi

  # Clean stale items (skip cleaning for fields set to "*")
  clean_stale "$target" "$DEST_BASE" "$SKILLS_CFG" "$COMMANDS_CFG"

  for skill in $SKILLS; do
    distribute_item "skill" "$skill" "$METHOD" "$DEST_BASE"
  done

  for cmd_name in $COMMANDS; do
    distribute_item "command" "$cmd_name" "$METHOD" "$DEST_BASE"
  done
done

echo ""
echo "Done."

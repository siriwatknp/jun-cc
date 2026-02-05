#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$SCRIPT_DIR/targets.json"
SCAN_DIR="${1:-$HOME/Personal-Repos}"

for cmd in jq gum; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd is required. Install with: brew install $cmd"
    exit 1
  fi
done

if [[ ! -d "$SCAN_DIR" ]]; then
  echo "Error: $SCAN_DIR is not a directory"
  exit 1
fi

EXISTING_KEYS=$(jq -r '.targets | keys[]' "$CONFIG" 2>/dev/null || true)
EXISTING_PATHS=$(jq -r '.targets[].path' "$CONFIG" 2>/dev/null || true)

# Build selection list: existing targets + new repos
ITEMS=""

# Add existing targets (marked for edit)
while IFS= read -r key; do
  [[ -z "$key" ]] && continue
  ITEMS="${ITEMS}${key} (edit)"$'\n'
done <<< "$EXISTING_KEYS"

# Add new repos from scan dir (exclude those already in targets)
for dir in "$SCAN_DIR"/*/; do
  [[ ! -d "$dir" ]] && continue
  repo_name="$(basename "$dir")"
  already_exists=false
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    if [[ "$p" == *"/$repo_name/"* ]] || [[ "$p" == *"/$repo_name" ]]; then
      already_exists=true
      break
    fi
  done <<< "$EXISTING_PATHS"
  if ! $already_exists; then
    ITEMS="${ITEMS}${repo_name}"$'\n'
  fi
done

ITEMS="$(echo "$ITEMS" | sed '/^$/d')"
if [[ -z "$ITEMS" ]]; then
  echo "No repos or targets found"
  exit 0
fi

# 1. Pick repo or existing target
SELECTION=$(echo "$ITEMS" | gum filter --header "Select a repo or existing target:")
if [[ -z "$SELECTION" ]]; then
  echo "No selection made."
  exit 0
fi

# Determine if editing existing target
IS_EXISTING=false
EXISTING_KEY=""
if [[ "$SELECTION" == *" (edit)" ]]; then
  IS_EXISTING=true
  EXISTING_KEY="${SELECTION% (edit)}"
fi

# Load current config for existing targets
CURRENT_PATH=""
CURRENT_METHOD=""
CURRENT_SKILLS=""
CURRENT_COMMANDS=""
if $IS_EXISTING; then
  CURRENT_PATH=$(jq -r ".targets[\"$EXISTING_KEY\"].path" "$CONFIG")
  CURRENT_METHOD=$(jq -r ".targets[\"$EXISTING_KEY\"].method" "$CONFIG")
  CURRENT_SKILLS=$(jq -r ".targets[\"$EXISTING_KEY\"].skills[]" "$CONFIG" 2>/dev/null || true)
  CURRENT_COMMANDS=$(jq -r ".targets[\"$EXISTING_KEY\"].commands[]" "$CONFIG" 2>/dev/null || true)
fi

# 2. Target key name
if $IS_EXISTING; then
  TARGET_KEY=$(gum input --value "$EXISTING_KEY" --header "Target key name:")
else
  TARGET_KEY=$(gum input --value "$SELECTION" --header "Target key name:")
fi
if [[ -z "$TARGET_KEY" ]]; then
  echo "No target key provided."
  exit 0
fi

# Check key collision
if ! $IS_EXISTING && jq -e ".targets[\"$TARGET_KEY\"]" "$CONFIG" &>/dev/null; then
  echo "Error: target '$TARGET_KEY' already exists in $CONFIG"
  exit 1
fi
if $IS_EXISTING && [[ "$TARGET_KEY" != "$EXISTING_KEY" ]] && jq -e ".targets[\"$TARGET_KEY\"]" "$CONFIG" &>/dev/null; then
  echo "Error: target '$TARGET_KEY' already exists in $CONFIG"
  exit 1
fi

# 3. Method (pre-select for existing)
if $IS_EXISTING; then
  METHOD=$(printf "copy\nsymlink" | gum choose --header "Distribution method:" --selected="$CURRENT_METHOD")
else
  METHOD=$(printf "copy\nsymlink" | gum choose --header "Distribution method:")
fi

# 4. Select skills (pre-select for existing)
AVAILABLE_SKILLS=$(ls -1 "$SCRIPT_DIR/skills/" 2>/dev/null || true)
SELECTED_SKILLS=""
if [[ -n "$AVAILABLE_SKILLS" ]]; then
  if $IS_EXISTING && [[ -n "$CURRENT_SKILLS" ]]; then
    PRESELECT=$(echo "$CURRENT_SKILLS" | tr '\n' ',' | sed 's/,$//')
    SELECTED_SKILLS=$(echo "$AVAILABLE_SKILLS" | gum filter --no-limit --header "Select skills:" --selected="$PRESELECT" || true)
  else
    SELECTED_SKILLS=$(echo "$AVAILABLE_SKILLS" | gum filter --no-limit --header "Select skills:" || true)
  fi
fi

# 5. Select commands (pre-select for existing)
AVAILABLE_COMMANDS=""
while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  rel="${f#$SCRIPT_DIR/commands/}"
  rel="${rel%.md}"
  AVAILABLE_COMMANDS="${AVAILABLE_COMMANDS}${rel}"$'\n'
done < <(find "$SCRIPT_DIR/commands" -name '*.md' -type f 2>/dev/null || true)
AVAILABLE_COMMANDS="$(echo "$AVAILABLE_COMMANDS" | sed '/^$/d')"

SELECTED_COMMANDS=""
if [[ -n "$AVAILABLE_COMMANDS" ]]; then
  if $IS_EXISTING && [[ -n "$CURRENT_COMMANDS" ]]; then
    PRESELECT=$(echo "$CURRENT_COMMANDS" | tr '\n' ',' | sed 's/,$//')
    SELECTED_COMMANDS=$(echo "$AVAILABLE_COMMANDS" | gum filter --no-limit --header "Select commands:" --selected="$PRESELECT" || true)
  else
    SELECTED_COMMANDS=$(echo "$AVAILABLE_COMMANDS" | gum filter --no-limit --header "Select commands:" || true)
  fi
fi

# Build JSON arrays
SKILLS_JSON="[]"
if [[ -n "$SELECTED_SKILLS" ]]; then
  SKILLS_JSON=$(echo "$SELECTED_SKILLS" | jq -R . | jq -s .)
fi

COMMANDS_JSON="[]"
if [[ -n "$SELECTED_COMMANDS" ]]; then
  COMMANDS_JSON=$(echo "$SELECTED_COMMANDS" | jq -R . | jq -s .)
fi

# Determine target path
if $IS_EXISTING; then
  TARGET_PATH="$CURRENT_PATH"
else
  SCAN_DIR_SHORT="${SCAN_DIR/#$HOME/\~}"
  TARGET_PATH="$SCAN_DIR_SHORT/$SELECTION/.claude"
fi

# Write to targets.json
TMP_CONFIG="$CONFIG.tmp"

# Handle key rename: delete old key first
if $IS_EXISTING && [[ "$TARGET_KEY" != "$EXISTING_KEY" ]]; then
  jq "del(.targets[\"$EXISTING_KEY\"])" "$CONFIG" > "$TMP_CONFIG" && mv "$TMP_CONFIG" "$CONFIG"
fi

jq --arg key "$TARGET_KEY" \
   --arg path "$TARGET_PATH" \
   --arg method "$METHOD" \
   --argjson skills "$SKILLS_JSON" \
   --argjson commands "$COMMANDS_JSON" \
   '.targets[$key] = {path: $path, method: $method, skills: $skills, commands: $commands}' \
   "$CONFIG" > "$TMP_CONFIG" && mv "$TMP_CONFIG" "$CONFIG"

echo ""
if $IS_EXISTING; then
  echo "Updated target '$TARGET_KEY':"
else
  echo "Added target '$TARGET_KEY':"
fi
echo "  path:     $TARGET_PATH"
echo "  method:   $METHOD"
echo "  skills:   $(echo "$SELECTED_SKILLS" | tr '\n' ' ')"
echo "  commands: $(echo "$SELECTED_COMMANDS" | tr '\n' ' ')"
echo ""
echo "Run ./distribute.sh to distribute."

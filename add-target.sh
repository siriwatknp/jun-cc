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

# Collect existing target paths
EXISTING_PATHS=$(jq -r '.targets[].path' "$CONFIG")

# List repos, exclude ones already in targets.json
REPOS=""
for dir in "$SCAN_DIR"/*/; do
  [[ ! -d "$dir" ]] && continue
  repo_name="$(basename "$dir")"
  # Check if any existing path contains this repo name
  already_exists=false
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    if [[ "$p" == *"/$repo_name/"* ]] || [[ "$p" == *"/$repo_name" ]]; then
      already_exists=true
      break
    fi
  done <<< "$EXISTING_PATHS"
  if ! $already_exists; then
    REPOS="${REPOS}${repo_name}"$'\n'
  fi
done

REPOS="$(echo "$REPOS" | sed '/^$/d')"
if [[ -z "$REPOS" ]]; then
  echo "No new repos found in $SCAN_DIR"
  exit 0
fi

# 1. Pick repo
REPO=$(echo "$REPOS" | gum filter --header "Select a repo:")
if [[ -z "$REPO" ]]; then
  echo "No repo selected."
  exit 0
fi

# 2. Target key name
TARGET_KEY=$(gum input --value "$REPO" --header "Target key name:")
if [[ -z "$TARGET_KEY" ]]; then
  echo "No target key provided."
  exit 0
fi

# Check key doesn't already exist
if jq -e ".targets[\"$TARGET_KEY\"]" "$CONFIG" &>/dev/null; then
  echo "Error: target '$TARGET_KEY' already exists in $CONFIG"
  exit 1
fi

# 3. Method
METHOD=$(printf "copy\nsymlink" | gum choose --header "Distribution method:")

# 4. Select skills
AVAILABLE_SKILLS=$(ls -1 "$SCRIPT_DIR/skills/" 2>/dev/null || true)
SELECTED_SKILLS=""
if [[ -n "$AVAILABLE_SKILLS" ]]; then
  SELECTED_SKILLS=$(echo "$AVAILABLE_SKILLS" | gum filter --no-limit --header "Select skills:" || true)
fi

# 5. Select commands
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
  SELECTED_COMMANDS=$(echo "$AVAILABLE_COMMANDS" | gum filter --no-limit --header "Select commands:" || true)
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

# Convert scan dir back to tilde-prefixed path
SCAN_DIR_SHORT="${SCAN_DIR/#$HOME/\~}"
TARGET_PATH="$SCAN_DIR_SHORT/$REPO/.claude"

# Write to targets.json
jq --arg key "$TARGET_KEY" \
   --arg path "$TARGET_PATH" \
   --arg method "$METHOD" \
   --argjson skills "$SKILLS_JSON" \
   --argjson commands "$COMMANDS_JSON" \
   '.targets[$key] = {path: $path, method: $method, skills: $skills, commands: $commands}' \
   "$CONFIG" > "$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"

echo ""
echo "Added target '$TARGET_KEY':"
echo "  path:     $TARGET_PATH"
echo "  method:   $METHOD"
echo "  skills:   $(echo "$SELECTED_SKILLS" | tr '\n' ' ')"
echo "  commands: $(echo "$SELECTED_COMMANDS" | tr '\n' ' ')"
echo ""
echo "Run ./distribute.sh to distribute."

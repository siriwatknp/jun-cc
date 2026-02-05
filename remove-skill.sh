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

# Build combined list with prefixes
ITEMS=""
while IFS= read -r skill; do
  [[ -z "$skill" ]] && continue
  ITEMS="${ITEMS}skill: ${skill}"$'\n'
done <<< "$(ls -1 "$SCRIPT_DIR/skills/" 2>/dev/null || true)"

while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  rel="${f#$SCRIPT_DIR/commands/}"
  rel="${rel%.md}"
  ITEMS="${ITEMS}command: ${rel}"$'\n'
done < <(find "$SCRIPT_DIR/commands" -name '*.md' -type f 2>/dev/null || true)

ITEMS="$(echo "$ITEMS" | sed '/^$/d')"
if [[ -z "$ITEMS" ]]; then
  echo "No skills or commands found."
  exit 0
fi

# 1. Select items to remove
SELECTED=$(echo "$ITEMS" | gum filter --no-limit --header "Select items to remove:" || true)
if [[ -z "$SELECTED" ]]; then
  echo "Nothing selected."
  exit 0
fi

# Split selections back into skills and commands
SELECTED_SKILLS=""
SELECTED_COMMANDS=""
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  if [[ "$line" == skill:* ]]; then
    SELECTED_SKILLS="${SELECTED_SKILLS}${line#skill: }"$'\n'
  elif [[ "$line" == command:* ]]; then
    SELECTED_COMMANDS="${SELECTED_COMMANDS}${line#command: }"$'\n'
  fi
done <<< "$SELECTED"
SELECTED_SKILLS="$(echo "$SELECTED_SKILLS" | sed '/^$/d')"
SELECTED_COMMANDS="$(echo "$SELECTED_COMMANDS" | sed '/^$/d')"

# Find affected targets (those that reference any selected item)
expand_path() { echo "${1/#\~/$HOME}"; }

AFFECTED_TARGETS=""
TARGETS=$(jq -r '.targets | keys[]' "$CONFIG" 2>/dev/null || true)
while IFS= read -r target; do
  [[ -z "$target" ]] && continue
  while IFS= read -r skill; do
    [[ -z "$skill" ]] && continue
    if jq -e ".targets[\"$target\"].skills | if type == \"array\" then index(\"$skill\") else false end" "$CONFIG" &>/dev/null; then
      AFFECTED_TARGETS="${AFFECTED_TARGETS}${target}"$'\n'
      break
    fi
  done <<< "$SELECTED_SKILLS"
  # Skip if already added
  echo "$AFFECTED_TARGETS" | grep -qx "$target" && continue
  while IFS= read -r cmd; do
    [[ -z "$cmd" ]] && continue
    if jq -e ".targets[\"$target\"].commands | if type == \"array\" then index(\"$cmd\") else false end" "$CONFIG" &>/dev/null; then
      AFFECTED_TARGETS="${AFFECTED_TARGETS}${target}"$'\n'
      break
    fi
  done <<< "$SELECTED_COMMANDS"
done <<< "$TARGETS"
AFFECTED_TARGETS="$(echo "$AFFECTED_TARGETS" | sed '/^$/d')"

# 2. Select targets to clean
SELECTED_TARGETS=""
if [[ -n "$AFFECTED_TARGETS" ]]; then
  SELECTED_TARGETS=$(echo "$AFFECTED_TARGETS" | gum filter --no-limit --header "Select targets to clean:" --selected="$(echo "$AFFECTED_TARGETS" | tr '\n' ',' | sed 's/,$//')" || true)
fi

# Confirm
echo ""
echo "Items to remove:"
echo "$SELECTED" | sed 's/^/  - /'
if [[ -n "$SELECTED_TARGETS" ]]; then
  echo "From targets:"
  echo "$SELECTED_TARGETS" | sed 's/^/  - /'
fi
echo ""
gum confirm "Proceed?" || exit 0

TMP_CONFIG="$CONFIG.tmp"

# 3. Remove source files and update targets.json
while IFS= read -r skill; do
  [[ -z "$skill" ]] && continue
  rm -rf "$SCRIPT_DIR/skills/$skill"
  echo "  DELETE skill $skill"

  jq --arg s "$skill" '
    .targets |= with_entries(.value.skills = (.value.skills | if type == "array" then map(select(. != $s)) else . end))
  ' "$CONFIG" > "$TMP_CONFIG" && mv "$TMP_CONFIG" "$CONFIG"

  if [[ -f "$SCRIPT_DIR/.pulled" ]]; then
    grep -v "^${skill}$" "$SCRIPT_DIR/.pulled" > "$SCRIPT_DIR/.pulled.tmp" 2>/dev/null && mv "$SCRIPT_DIR/.pulled.tmp" "$SCRIPT_DIR/.pulled" || true
  fi
done <<< "$SELECTED_SKILLS"

while IFS= read -r cmd; do
  [[ -z "$cmd" ]] && continue
  rm -f "$SCRIPT_DIR/commands/$cmd.md"
  echo "  DELETE command $cmd"

  jq --arg c "$cmd" '
    .targets |= with_entries(.value.commands = (.value.commands | if type == "array" then map(select(. != $c)) else . end))
  ' "$CONFIG" > "$TMP_CONFIG" && mv "$TMP_CONFIG" "$CONFIG"
done <<< "$SELECTED_COMMANDS"

find "$SCRIPT_DIR/commands" -type d -empty -delete 2>/dev/null || true

# 4. Clean from selected target destinations
while IFS= read -r target; do
  [[ -z "$target" ]] && continue
  DEST_BASE=$(expand_path "$(jq -r ".targets[\"$target\"].path" "$CONFIG")")
  echo ""
  echo "=== $target ==="

  while IFS= read -r skill; do
    [[ -z "$skill" ]] && continue
    dest="$DEST_BASE/skills/$skill"
    if [[ -L "$dest" ]] || [[ -d "$dest" ]]; then
      rm -rf "$dest"
      echo "  CLEAN skill $skill"
    fi
  done <<< "$SELECTED_SKILLS"

  while IFS= read -r cmd; do
    [[ -z "$cmd" ]] && continue
    dest="$DEST_BASE/commands/$cmd.md"
    if [[ -L "$dest" ]] || [[ -f "$dest" ]]; then
      rm -f "$dest"
      echo "  CLEAN command $cmd"
    fi
  done <<< "$SELECTED_COMMANDS"

  find "$DEST_BASE/commands" -type d -empty -delete 2>/dev/null || true
done <<< "$SELECTED_TARGETS"

echo ""
echo "Done."

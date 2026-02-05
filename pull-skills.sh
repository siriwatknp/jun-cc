#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$HOME/.agents/skills"
PULLED_FILE="$SCRIPT_DIR/.pulled"

if ! command -v gum &>/dev/null; then
  echo "Error: gum is required. Install with: brew install gum"
  exit 1
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Error: $SOURCE_DIR does not exist. Install skills first with: npx skills install"
  exit 1
fi

AVAILABLE=$(ls -1 "$SOURCE_DIR" 2>/dev/null || true)
if [[ -z "$AVAILABLE" ]]; then
  echo "No skills found in $SOURCE_DIR"
  exit 0
fi

PRESELECTED=""
if [[ -f "$PULLED_FILE" ]]; then
  PRESELECTED=$(paste -sd, "$PULLED_FILE")
fi

FILTER_ARGS=(--no-limit --header "Select skills to pull:")
if [[ -n "$PRESELECTED" ]]; then
  FILTER_ARGS+=(--selected "$PRESELECTED")
fi

SELECTED=$(echo "$AVAILABLE" | gum filter "${FILTER_ARGS[@]}")
if [[ -z "$SELECTED" ]]; then
  echo "No skills selected."
  exit 0
fi

mkdir -p "$SCRIPT_DIR/skills"
: > "$PULLED_FILE"

COUNT=0
while IFS= read -r skill; do
  [[ -z "$skill" ]] && continue
  cp -R "$SOURCE_DIR/$skill" "$SCRIPT_DIR/skills/"
  echo "$skill" >> "$PULLED_FILE"
  echo "  PULL $skill"
  ((COUNT++))
done <<< "$SELECTED"

echo ""
echo "Pulled $COUNT skill(s) into skills/"

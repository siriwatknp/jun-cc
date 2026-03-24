#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
  echo "Usage: jun-cc sync-back <path>"
  echo ""
  echo "Sync a skill or command back to jun-cc."
  echo "Detects type from path (looks for /skills/ or /commands/ segment)."
  echo ""
  echo "Examples:"
  echo "  jun-cc sync-back ~/.claude/skills/my-skill"
  echo "  jun-cc sync-back ~/.claude/skills/my-skill/SKILL.md"
  echo "  jun-cc sync-back /path/to/project/.claude/commands/mui/triage-issue.md"
  exit 1
}

[[ $# -lt 1 || "$1" == "-h" || "$1" == "--help" ]] && usage

# Resolve to absolute path (strip trailing slash)
INPUT="${1%/}"
if [[ -d "$INPUT" ]]; then
  TARGET_PATH="$(cd "$INPUT" && pwd)"
elif [[ -f "$INPUT" ]]; then
  TARGET_PATH="$(cd "$(dirname "$INPUT")" && pwd)/$(basename "$INPUT")"
else
  echo "Error: $INPUT does not exist"
  exit 1
fi

# Detect type by finding /skills/ or /commands/ in the path
# Append / so both "skills/foo" and "skills/foo/file" match consistently
match_path="$TARGET_PATH/"
if [[ "$match_path" == */skills/* ]]; then
  after_skills="${match_path#*/skills/}"
  skill_name="${after_skills%%/*}"
  skill_dir="${TARGET_PATH%%/skills/*}/skills/$skill_name"
  dest="$SCRIPT_DIR/skills/$skill_name"

  if [[ -d "$dest" ]]; then
    echo "Overwrite skill: $skill_name"
  else
    echo "New skill: $skill_name"
  fi

  rm -rf "$dest"
  cp -R "$skill_dir" "$dest"
  echo "  ← $skill_dir"

elif [[ "$FILE_PATH" == */commands/* ]]; then
  # Extract relative command path after /commands/ (e.g. mui/triage-issue.md)
  after_commands="${FILE_PATH#*/commands/}"
  cmd_name="${after_commands%.md}"
  dest="$SCRIPT_DIR/commands/$cmd_name.md"

  mkdir -p "$(dirname "$dest")"

  if [[ -f "$dest" ]]; then
    echo "Overwrite command: $cmd_name"
  else
    echo "New command: $cmd_name"
  fi

  cp "$FILE_PATH" "$dest"
  echo "  ← $FILE_PATH"

else
  echo "Error: cannot detect type from path"
  echo "Path must contain /skills/ or /commands/ segment"
  exit 1
fi

echo "Done."

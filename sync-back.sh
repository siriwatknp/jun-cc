#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"

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
if [[ ! -e "$INPUT" ]]; then
  echo "Error: $INPUT does not exist"
  exit 1
fi

# Logical absolute path (keeps symlinks in the path so /skills/ and
# /commands/ detection works against the path the user passed in).
# Physical path follows symlinks — used to detect when the input already
# lives inside this repo (e.g. a distributed symlink).
if [[ -d "$INPUT" ]]; then
  TARGET_PATH="$(cd "$INPUT" && pwd)"
  TARGET_PATH_PHYS="$(cd "$INPUT" && pwd -P)"
else
  parent_log="$(cd "$(dirname "$INPUT")" && pwd)"
  parent_phys="$(cd "$(dirname "$INPUT")" && pwd -P)"
  fname="$(basename "$INPUT")"
  TARGET_PATH="$parent_log/$fname"
  if [[ -L "$parent_phys/$fname" ]]; then
    link="$(readlink "$parent_phys/$fname")"
    [[ "$link" != /* ]] && link="$parent_phys/$link"
    TARGET_PATH_PHYS="$(cd "$(dirname "$link")" && pwd -P)/$(basename "$link")"
  else
    TARGET_PATH_PHYS="$parent_phys/$fname"
  fi
fi

# If the source resolves into this repo (symlink-distributed targets),
# the .claude path *is* the jun-cc source — nothing to copy back.
# Guard against rm -rf destroying the real files via the symlink.
if [[ "$TARGET_PATH_PHYS" == "$SCRIPT_DIR" || "$TARGET_PATH_PHYS" == "$SCRIPT_DIR"/* ]]; then
  echo "Path is symlinked into jun-cc; already in sync."
  echo "  → $TARGET_PATH_PHYS"
  exit 0
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

elif [[ "$match_path" == */commands/* ]]; then
  # Extract relative command path after /commands/ (e.g. mui/triage-issue.md)
  after_commands="${TARGET_PATH#*/commands/}"
  cmd_name="${after_commands%.md}"
  src_file="${TARGET_PATH%%/commands/*}/commands/$after_commands"
  dest="$SCRIPT_DIR/commands/$cmd_name.md"

  mkdir -p "$(dirname "$dest")"

  if [[ -f "$dest" ]]; then
    echo "Overwrite command: $cmd_name"
  else
    echo "New command: $cmd_name"
  fi

  cp "$src_file" "$dest"
  echo "  ← $src_file"

else
  echo "Error: cannot detect type from path"
  echo "Path must contain /skills/ or /commands/ segment"
  exit 1
fi

echo "Done."

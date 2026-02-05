# jun-cc

Central repo for managing Claude Code skills and commands across multiple projects.

Skills and commands are authored/collected here, then distributed to target project `.claude/` directories via copy or symlink.

## Structure

```
skills/           # skill directories (pulled or authored)
commands/         # slash command .md files (namespaced: me/, mui/)
targets.json      # distribution config: which targets get which skills/commands
.pulled           # tracks which skills were pulled from ~/.agents (vs authored locally)
```

## Workflow

### Pull third-party skills

Copy skills from `~/.agents/skills/` (populated by `npx skills install`) into this repo.

```sh
./pull-skills.sh
```

Previously pulled skills are pre-selected on re-run. Tracks origin in `.pulled`.

### Create a new skill

Create a directory under `skills/` with the skill name and add the skill files.

```sh
mkdir skills/my-skill
# add skill files...
```

### Create a new command

Create a `.md` file under `commands/` with optional namespace directory.

```sh
# namespaced
mkdir -p commands/me
# create commands/me/my-command.md

# or top-level
# create commands/my-command.md
```

### Add a new target

```sh
./add-target.sh            # scans ~/Personal-Repos by default
./add-target.sh ~/Work     # or specify a directory
```

Prompts for: repo, target key, method (`copy`/`symlink`), skills, commands.

Supports the global target (`~/.claude`) and project targets.

### Update an existing target

Run the same script — existing targets appear with `(edit)` suffix. Current skills/commands are pre-selected.

```sh
./add-target.sh
# select "my-project (edit)"
```

### Remove a skill/command from a target

Run `./add-target.sh`, select the target to edit, deselect the skill/command, then redistribute.

### Remove a skill/command from this repo

```sh
./remove-skill.sh
```

Prompts to multi-select skills and commands to remove. Deletes sources, removes from all targets in `targets.json`, and redistributes automatically.

### Distribute

```sh
./distribute.sh
```

Copies or symlinks based on each target's configured method. Cleans stale items that were removed from a target's config.

## targets.json

```jsonc
{
  "targets": {
    "<key>": {
      "path": "~/.claude", // destination .claude directory
      "method": "symlink", // "copy" or "symlink"
      "skills": ["skill-name"], // or "*" for all
      "commands": ["ns/cmd-name"], // or "*" for all
    },
  },
}
```

## Dependencies

- [gum](https://github.com/charmbracelet/gum) — interactive prompts (`brew install gum`)
- [jq](https://jqlang.github.io/jq/) — JSON processing (`brew install jq`)

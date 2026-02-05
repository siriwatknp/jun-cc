# jun-cc

Central repo for managing Claude Code skills and commands across multiple projects.

Skills and commands are authored/collected here, then distributed to target project `.claude/` directories via copy or symlink.

## Structure

```
skills/           # skill directories (pulled or authored)
commands/         # slash command .md files (namespaced: me/, mui/)
targets.json      # distribution config: which targets get which skills/commands
```

## Workflow

1. **Pull third-party skills** into `skills/` from `~/.agents/skills/` (populated by `npx skills install`)

   ```sh
   ./pull-skills.sh
   ```

2. **Add a target** project to `targets.json`

   ```sh
   ./add-target.sh            # scans ~/Personal-Repos by default
   ./add-target.sh ~/Work     # or specify a directory
   ```

   Prompts for: repo, target key, method (`copy`/`symlink`), skills, commands.

3. **Distribute** skills and commands to selected targets
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
      "skills": ["skill-name"], // skills to distribute
      "commands": ["ns/cmd-name"], // commands to distribute
    },
  },
}
```

## Dependencies

- [gum](https://github.com/charmbracelet/gum) — interactive prompts (`brew install gum`)
- [jq](https://jqlang.github.io/jq/) — JSON processing (`brew install jq`), used by `add-target.sh` and `distribute.sh`

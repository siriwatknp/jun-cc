---
name: maintain-claude-md
description: A skill for creating/updating CLAUDE.md or AGENTS.md file
---

Before interacting with CLAUDE.md, MUST read and understand the guidelines below for highest quality and consistency.

# CLAUDE.md Guidelines

CLAUDE.md is a special file that Claude reads at the start of every conversation — the only file that goes into **every single context window**. It gives Claude persistent context **it can't infer from code alone**.

Also applicable to `AGENTS.md` for other agents/harnesses (OpenCode, Zed, Cursor, Codex).

## Core Principle: Less Is More

LLMs are stateless — they know nothing about your codebase at session start. CLAUDE.md is how you onboard them. But it's also shared context space:

- Frontier thinking LLMs follow **~150–200 instructions** reliably; Claude Code's system prompt already uses **~50**.
- As instruction count increases, **all** instructions are ignored more uniformly.
- LLMs bias toward instructions at the **peripheries** (beginning and end of context).

**Target: < 300 lines**, shorter is better. For each line, ask: _"Would removing this cause Claude to make mistakes?"_ If not, cut it.

| ✅ Include                                           | ❌ Exclude                                         |
| ---------------------------------------------------- | -------------------------------------------------- |
| Bash commands Claude can't guess                     | Anything Claude can figure out by reading code     |
| Code style rules that differ from defaults           | Standard language conventions Claude already knows |
| Testing instructions and preferred test runners      | Detailed API documentation (link to docs instead)  |
| Repository etiquette (branch naming, PR conventions) | Information that changes frequently                |
| Architectural decisions specific to your project     | Long explanations or tutorials                     |
| Developer environment quirks (required env vars)     | File-by-file descriptions of the codebase          |
| Common gotchas or non-obvious behaviors              | Self-evident practices like "write clean code"     |

## Progressive Disclosure

Keep only universally applicable instructions in CLAUDE.md. Move task-specific content to **separate files**:

```
docs-agent/
  |- building_the_project.md
  |- running_tests.md
  |- code_conventions.md
  |- service_architecture.md
```

List these files with brief descriptions in CLAUDE.md; instruct Claude to read only the relevant ones.

**Prefer pointers to copies** — don't embed code snippets (they go stale). Use `file:line` references instead.

CLAUDE.md can import files using `@path/to/import` syntax:

```markdown
See @README.md for project overview and @package.json for available npm commands.

- Git workflow: @docs/git-instructions.md
- Personal overrides: @~/.claude/my-project-instructions.md
```

For domain knowledge or workflows only relevant sometimes, use [skills](/en/skills) instead — Claude loads them on demand.

## Don't Use Claude as a Linter

LLMs are slow and expensive compared to linters. Claude is an **in-context learner** — it follows existing patterns naturally after a few codebase searches.

- Use linters that auto-fix (e.g., Biome)
- Consider a [Stop hook](https://code.claude.com/docs/en/hooks#stop) that runs your formatter/linter and feeds errors back
- Create a [Slash Command](https://code.claude.com/docs/en/slash-commands) for code style review separately from implementation

## File Placement

- **Home folder (`~/.claude/CLAUDE.md`)**: Applies to all sessions
- **Project root (`./CLAUDE.md`)**: Check into git to share with your team, or use `CLAUDE.local.md` and `.gitignore` it
- **Parent directories**: Useful for monorepos (`root/CLAUDE.md` + `root/foo/CLAUDE.md`)
- **Child directories**: Pulled in on demand when working with files in those directories

## Craft It Carefully

CLAUDE.md is the **highest leverage point** of the harness — a bad line compounds through research → planning → implementation. Don't auto-generate it with `/init`.

Treat it like code: review when things go wrong, prune regularly, and test changes by observing behavior shifts. You can add emphasis (e.g., "IMPORTANT", "YOU MUST") to improve adherence.

## Summary

1. Define your project's **WHY**, **WHAT**, and **HOW**
2. **Less is more** — as few instructions as reasonably possible
3. Keep contents **concise and universally applicable**
4. Use **Progressive Disclosure** — tell Claude _how to find_ information, not everything upfront
5. **Claude is not a linter** — use linters, hooks, and slash commands
6. **Highest leverage point** — craft every line carefully

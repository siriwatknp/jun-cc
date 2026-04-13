---
name: ramp-up
description: Get up to speed on an in-progress PR or working branch. Use this skill at the start of a session when on a non-main branch, or when the user says "ramp up", "catch me up", "where was I", "continue working", "resume", "what's left", or wants to understand the current state of a half-finished PR. Also trigger when the user opens a conversation on a feature branch and asks what to do next. Even if the user doesn't say "ramp up" explicitly, use this when context suggests they're resuming interrupted work on a branch.
---

# Ramp Up

Quickly build a complete picture of an in-progress branch/PR so you can resume work without the user re-explaining everything.

## Why this matters

Context loss between sessions is expensive. The user shouldn't have to re-explain requirements, decisions, or progress every time they open a new conversation. This skill reconstructs that context from what's already in the repo and PR.

## Arguments

The user may provide additional resource paths (files, directories, URLs) as arguments. Only read resources the user explicitly provides — never guess or scan for files outside of what git diff reveals and what the user specifies.

## Step 1: Detect environment

First, determine the base ref. The local main/master branch may be stale, so always diff against the remote.

Detect if the repo is a fork: check if an `upstream` remote exists (`git remote get-url upstream`). If it does, the repo is a fork — use `upstream` as the remote for the base ref. Otherwise, use `origin`.

- If a PR exists, use the PR's `baseRefName` with the appropriate remote (e.g., `upstream/main` for forks, `origin/main` otherwise)
- Otherwise, detect the default branch from the appropriate remote: `git remote show <remote> | grep 'HEAD branch'`, then use `<remote>/<that branch>`

Store this as `$BASE` for all subsequent commands.

Run these in parallel:

- `git branch --show-current` — confirm we're on a working branch (not main/master)
- `git log $BASE..HEAD --oneline` — list of commits on this branch
- `gh pr view --json title,body,url,state,baseRefName,headRefName,statusCheckRollup,labels,milestone` — get PR metadata if one exists
- `git diff $BASE...HEAD --stat` — overview of changed files

If the current branch is the default branch and no PR context given, tell the user and stop — nothing to ramp up on.

## Step 2: Read the diff for context

The git diff is the primary source of truth for what's happened.

1. From the `--stat` output, identify any `*.md` files in the diff — these are likely requirements, tech analysis, or plan documents. Read them first with the Read tool, as they provide the highest-level context about what this branch is for.
2. Scan the diff for code changes to understand the implementation progress. Use `git diff $BASE...HEAD` (with path filters if the diff is large) to understand what's been built so far.
3. If the user provided additional resource paths as arguments, read those now.

## Step 3: Check CI status (lightweight)

If a PR exists and `statusCheckRollup` has data, note any failing checks. Don't deep-dive — just flag them as context (e.g., "CI: 2 checks failing — lint and test").

## Step 4: Synthesize and present

Present a concise structured summary. Use this format:

```
## Ramp-Up Summary

**Branch**: `feature/xyz` → `main`
**PR**: #123 — "Title here" (draft/open/closed)

### Requirement
<1-3 sentences distilled from MD docs or PR description>

### Key Decisions
<Bullet list of architectural/design decisions found in docs or commit messages. Skip if none found.>

### What's Done
<Bullet list of completed work, derived from commits and code changes>

### What's Left
<Bullet list of remaining work, derived from plan docs (unchecked items), TODO comments, or gaps between requirements and current implementation>

### CI Status
<One line summary, or "All green" / "No PR yet">
```

Keep it tight — the user knows this project, they just need a refresher, not a tutorial.

## Step 5: Ask what's next

After the summary, present the remaining tasks (if identifiable) as numbered options, then ask:

> "Which step should I work on next, or should I proceed in order?"

If there's no clear task list, simply ask:

> "What should I focus on?"

## Rules

- Never fabricate context. If you can't find requirements or a plan, say so.
- Don't read files that aren't in the diff or explicitly provided by the user.
- Don't start working on anything yet — this skill is purely about gathering and presenting context. The user decides what happens next.
- Keep the summary scannable. Prefer bullets over paragraphs.

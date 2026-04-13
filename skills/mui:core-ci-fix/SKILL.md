---
name: mui:core-ci-fix
description: Update a PR branch to latest upstream (with full conflict resolution), run CI static checks in parallel via agent teams, commit fixes, and push. Use when asked to fix CI, update, or maintain a Material UI (core) PR.
user-invocable: true
argument-hint: "[pr-number-or-url] [--centralized]"
---

Update PR branch and fix CI static check failures on a given PR.

The user provides a PR number or URL (e.g. `#1234` or `https://github.com/mui/material-ui/pulls/1234`).

## Options

- `--centralized`: Use centralized fix mode. All subagents only run checks and report failures. The main agent fixes all issues, then re-dispatches subagents to verify. Default mode is phased — subagents fix issues themselves.

## Steps

### 1. Check PR status

```bash
gh pr checks <pr>
```

If **all checks passed** and the PR has **no merge conflicts**, **stop immediately** and report to the user that no action is needed.

Otherwise, proceed.

### 2. Get PR info

```bash
gh pr view <pr> --json number,title,body,headRefName,headRepository,headRepositoryOwner,baseRefName,url
```

If the PR is not found, **stop immediately** and report the error to the user.

Also fetch the linked issue if referenced in the body (look for `#<number>`, `fixes #`, `closes #`, etc.) via `gh issue view`.

### 3. Understand the PR

Before making any changes, build context:

- Read the PR title, body, and linked issue to understand **why** this PR exists
- Review the PR diff to understand **what** changed: `gh pr diff <pr>`
- Summarize the PR purpose and key changes to the user

This context is critical — if conflicts arise, you need to know which changes belong to the PR vs. the base branch.

### 4. Enter worktree

Use the `EnterWorktree` tool to create an isolated worktree for this work.

### 5. Checkout PR

```bash
gh pr checkout <pr>
```

### 6. Update to latest upstream

```bash
git fetch upstream <baseRefName>
git merge upstream/<baseRefName> --no-edit
```

If merge succeeds, skip to step 6.

If merge conflicts occur:

1. **Abort** the failed merge:

   ```bash
   git merge --abort
   ```

2. **Save PR commits** — identify commits unique to this PR:

   ```bash
   git log --oneline upstream/<baseRefName>..HEAD
   ```

   Note the commit range.

3. **Force-merge accepting all incoming changes** — creates a clean merge point:

   ```bash
   git merge upstream/<baseRefName> --no-edit -X theirs
   ```

4. **Cherry-pick PR commits on top** — reapply the PR's own changes:

   ```bash
   git cherry-pick <oldest-pr-commit>^..<newest-pr-commit>
   ```

   If cherry-pick conflicts occur, resolve by keeping the cherry-picked (PR) changes:

   ```bash
   git checkout --theirs .
   git add .
   git cherry-pick --continue
   ```

5. **Verify** — `git log --oneline -10` and `git diff upstream/<baseRefName> --stat` to sanity-check.

### 7. Install dependencies

Run `pnpm install --frozen-lockfile --prefer-offline`. The `--prefer-offline` flag reuses the shared pnpm store (already warm from the local repo) and avoids network requests. If it fails, fall back to `pnpm install`.

### 8. Run CI checks

All agents share the same worktree. The execution mode depends on the `--centralized` flag.

#### CI check definitions

| Agent | Name           | Commands                                                                                                                                                                                 | Auto-fixable?                                   |
| ----- | -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------- |
| 1     | `test_static`  | a. `pnpm deduplicate` (only if PR changes any `package.json`)<br>b. `pnpm prettier`<br>c. `pnpm proptypes`<br>d. `pnpm docs:api`<br>e. `pnpm docs:i18n`<br>f. `pnpm extract-error-codes` | Yes (commands regenerate files)                 |
| 2     | `test_types`   | a. `pnpm docs:typescript:formatted`<br>b. `pnpm typescript:ci`<br>c. `pnpm typescript:module-augmentation`                                                                               | Partially (a regenerates files, b-c are checks) |
| 3     | `test_lint`    | a. `pnpm eslint --fix`<br>b. `pnpm stylelint --fix`<br>c. `pnpm markdownlint --fix`                                                                                                      | Yes (--fix auto-corrects)                       |
| 4     | `test_unit`    | a. `pnpm test:node --no-isolate --no-file-parallelism`                                                                                                                                   | No (needs code fixes)                           |
| 5     | `test_browser` | a. `pnpm test:browser --no-isolate --no-file-parallelism`<br>Requires Playwright. If not installed, skip and report.                                                                     | No (needs code fixes)                           |

#### Phased mode (default)

Run in two phases to avoid file conflicts between agents.

**Phase 1** — Launch agents 1-3 (`test_static`, `test_types`, `test_lint`) in parallel.

- Each agent runs its commands, checks `git diff` after each command, and reports changes.
- If a check command fails (e.g. `typescript:ci`), the agent analyzes the error and fixes it, then re-runs the failing command to verify.
- Each agent loops until all its checks pass (max 3 retries).

**Phase 2** — After phase 1 completes and changes are committed, launch agents 4-5 (`test_unit`, `test_browser`) in parallel.

- Each agent runs tests, and if they fail, analyzes failures and fixes them (e.g. update snapshots, fix assertions, adjust test expectations to match PR changes).
- Each agent loops until tests pass (max 3 retries).

#### Centralized mode (`--centralized`)

All 5 agents run in parallel but **only report failures** — they do NOT edit any files.

Each agent should report:

- Which commands failed
- Full error output
- Which files are likely involved

After all agents complete, the **main agent**:

1. Analyzes all reported failures together
2. Fixes all issues (single writer, no conflicts)
3. Re-dispatches only the failed agents to verify fixes
4. Repeats until all pass (max 3 retries)

### 9. Commit and push

After all checks pass, if there are changes, stage all and commit with message: `fix ci`

Push with `--force-with-lease` (safe — won't overwrite others' changes, but needed if history was rewritten during conflict resolution).

```bash
git push --force-with-lease
```

### 10. Exit worktree

Use the `ExitWorktree` tool with `delete: true` to always clean up the worktree.

### 11. Report

Summarize:

- PR purpose (from step 2)
- Whether conflicts were encountered and how they were resolved
- What CI checks were fixed (from each agent's results)
- Which mode was used (phased or centralized)
- Final state of the branch

## Important

- Only commit if there are actual changes.
- Max 3 retry loops per agent to prevent infinite loops.
- If an agent exhausts retries, report the remaining failures to the user.

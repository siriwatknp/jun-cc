---
name: mui:core-ci-fix
description: Update a PR branch to latest upstream (with full conflict resolution), run CI static checks in parallel via agent teams, commit fixes, and push. Use when asked to fix CI, update, or maintain a Material UI (core) PR.
user-invokable: true
---

Update PR branch and fix CI static check failures on a given PR.

The user provides a PR number or URL (e.g. `#1234` or `https://github.com/mui/material-ui/pulls/1234`).

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

### 8. Run CI checks in parallel

Launch 3 agents in parallel using the Agent tool, each simulating a CI workflow. Pass the worktree path so agents run commands in the correct directory.

#### Agent 1: `test_static`

Run these commands sequentially:
a. `pnpm deduplicate` — Only if the PR diff includes changes to any `package.json` (check via `gh pr diff <pr> --name-only | grep package.json`). Skip otherwise.
b. `pnpm prettier` — Format changed files (uses `pretty-quick --branch master` under the hood)
c. `pnpm proptypes` — Regenerate PropTypes
d. `pnpm docs:api` — Regenerate API docs
e. `pnpm docs:i18n` — Update navigation translations
f. `pnpm extract-error-codes` — Update error codes

#### Agent 2: `test_types`

Run these commands sequentially:
a. `pnpm docs:typescript:formatted` — Regenerate JS demo files
b. `pnpm typescript:ci` — Run TypeScript checks

#### Agent 3: `test_lint`

Run these commands sequentially:
a. `pnpm eslint --fix` — Fix lint issues
b. `pnpm stylelint --fix` — Fix style lint issues
c. `pnpm markdownlint --fix` — Fix markdown lint issues

Each agent should report which commands produced changes (via `git status` or `git diff` after each command).

### 9. Commit and push

After all agents complete, if there are changes, stage all and commit with message: `fix ci`

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
- Final state of the branch

## Important

- If a CI command fails with actual code errors (not just formatting), report to user instead of trying to fix code logic.
- Only commit if there are actual changes.

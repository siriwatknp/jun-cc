---
name: keep-pr-update
description: Update a PR branch with the latest changes from its target branch (upstream/origin). Handles merge conflicts by accepting incoming changes and reapplying PR commits. Use when asked to update a PR, rebase a PR, sync a PR with its base branch, or keep a PR up to date. For MUI repos, prefer mui:core-ci-fix or mui:x-ci-fix which include this + CI fixes.
user-invokable: true
argument-hint: <pr-number-or-url>
---

Update a PR branch to the latest target branch.

The user provides a PR number or URL (e.g. `#1234` or `https://github.com/org/repo/pull/1234`).

## Steps

### 1. Get PR info

```bash
gh pr view <pr> --json number,title,body,headRefName,baseRefName,url
```

If the PR is not found, **stop immediately** and report the error to the user. Do not proceed with any further steps.

Also fetch the linked issue if referenced in the body (look for `#<number>`, `fixes #`, `closes #`, etc.) via `gh issue view`.

### 2. Understand the PR

Before making any changes, build context:

- Read the PR title, body, and linked issue to understand **why** this PR exists
- Review the PR diff to understand **what** changed: `gh pr diff <pr>`
- Summarize the PR purpose and key changes to the user

This context is critical — if conflicts arise, you need to know which changes belong to the PR vs. the base branch.

### 3. Enter worktree

Use the `EnterWorktree` tool with name `<pr-number>-<short-description>` (e.g. `1234-fix-button-style`). Derive the short description from the PR title.

### 4. Checkout PR

```bash
gh pr checkout <pr>
```

### 5. Determine remote and update

The target branch comes from `baseRefName` (step 1). Determine the correct remote:

```bash
git remote -v
```

- If `upstream` remote exists → use `upstream/<baseRefName>`
- Otherwise → use `origin/<baseRefName>`

Then fetch and merge:

```bash
git fetch <remote> <baseRefName>
git merge <remote>/<baseRefName> --no-edit
```

### 6. Handle merge conflicts

If the merge in step 5 succeeds with no conflicts, skip to step 7.

If conflicts occur:

1. **Abort** the failed merge:

   ```bash
   git merge --abort
   ```

2. **Save PR commits** — identify commits unique to this PR:

   ```bash
   git log --oneline <remote>/<baseRefName>..HEAD
   ```

   Note the commit range.

3. **Force-merge accepting all incoming changes** — this creates a clean merge point:

   ```bash
   git merge <remote>/<baseRefName> --no-edit -X theirs
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

5. **Verify** — confirm the final state includes both the updated base and the PR's changes. Run `git log --oneline -10` and `git diff <remote>/<baseRefName> --stat` to sanity-check.

### 7. Push

```bash
git push --force-with-lease
```

`--force-with-lease` is needed because the history was rewritten during conflict resolution. It's safe because it won't overwrite changes pushed by someone else since the last fetch.

### 8. Report

Summarize:

- PR purpose (from step 2)
- Whether conflicts were encountered and how they were resolved
- Final state of the branch

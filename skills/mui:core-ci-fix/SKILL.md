---
name: mui:core-ci-fix
description: Fix failed checks on the PR of mui/material-ui repo. Pull a PR into a worktree, update it to latest upstream, run CI static checks in parallel via agent teams, commit fixes, and push. Use when asked to fix CI on a Material UI (core) PR.
user-invokable: true
---

Fix CI static check failures on a given PR.

The user provides a PR number or URL (e.g. `#1234` or `https://github.com/mui/material-ui/pulls/1234`).

## Steps

1. **Get PR info** — Use `gh pr view <pr> --json number,headRefName,headRepository,headRepositoryOwner,baseRefName` to get the branch name, base branch, and fork info.

2. **Enter worktree** — Use the `EnterWorktree` tool to create an isolated worktree for this work.

3. **Checkout PR** — Run `gh pr checkout <pr>` to check out the PR branch in the worktree.

4. **Update to latest upstream** — Run:

   ```bash
   git fetch upstream <baseRefName>
   git merge upstream/<baseRefName> --no-edit
   ```

   If merge conflicts occur, abort the merge with `git merge --abort`, report the conflict to the user, and continue with the remaining steps (install deps, run CI checks, etc.).

5. **Install dependencies** — Run `pnpm install --frozen-lockfile --prefer-offline`. The `--prefer-offline` flag reuses the shared pnpm store (already warm from the local repo) and avoids network requests. If it fails, fall back to `pnpm install`.

6. **Run CI checks in parallel** — Launch 3 agents in parallel using the Agent tool, each simulating a CI workflow. Pass the worktree path so agents run commands in the correct directory.

   ### Agent 1: `test_static`

   Run these commands sequentially:
   a. `pnpm deduplicate` — Only if the PR diff includes changes to any `package.json` (check via `gh pr diff <pr> --name-only | grep package.json`). Skip otherwise.
   b. `pnpm prettier` — Format changed files (uses `pretty-quick --branch master` under the hood)
   c. `pnpm proptypes` — Regenerate PropTypes
   d. `pnpm docs:api` — Regenerate API docs
   e. `pnpm docs:i18n` — Update navigation translations
   f. `pnpm extract-error-codes` — Update error codes

   ### Agent 2: `test_types`

   Run these commands sequentially:
   a. `pnpm docs:typescript:formatted` — Regenerate JS demo files
   b. `pnpm typescript:ci` — Run TypeScript checks

   ### Agent 3: `test_lint`

   Run these commands sequentially:
   a. `pnpm eslint --fix` — Fix lint issues
   b. `pnpm stylelint --fix` — Fix style lint issues
   c. `pnpm markdownlint --fix` — Fix markdown lint issues

   Each agent should report which commands produced changes (via `git status` or `git diff` after each command).

7. **Commit** — After all agents complete, if there are changes, stage all and commit with message: `fix ci`

8. **Push** — Run `git push` to push the changes to the PR branch.

9. **Exit worktree** — Use the `ExitWorktree` tool.

10. **Report** — Summarize what was fixed (from each agent's results) and confirm the push succeeded.

## Important

- If merge conflicts occur during the upstream merge, abort the merge (`git merge --abort`), report to user, but continue with the rest of the steps.
- If a CI command fails with actual code errors (not just formatting), report to user instead of trying to fix code logic.
- Only commit if there are actual changes.

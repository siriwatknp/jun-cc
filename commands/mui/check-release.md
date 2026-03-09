---
name: mui:check-release
description: Check the consistency between the core branch and the docs branch before a release.
model: haiku
argument-hint: [docs-branch] [core-branch]
---

## Context

The release process force-pushes the core branch to the release branch. If the docs branch has cherry-picked commits not in the core branch, those commits get lost. This command detects that.

- core repo: `mui/material-ui`
- docs repo: `mui/material-ui-docs`

## Step 1: Resolve arguments

Verify git remote is `mui/material-ui`. Abort if not.

**core-branch** (default: current git branch):

- Warn and ask to confirm if not `master` or `v{major}.x`

**docs-branch** (no default):

- ALWAYS use AskUserQuestion. Do NOT guess.
- Suggest a branch based on the core→docs mapping below.
- After reply, verify branch exists in docs repo before proceeding.

### Core→docs branch mapping

Check latest tag on `upstream/master` via `git describe --tags --abbrev=0 upstream/master`.

Pre-release phase (tag matches `v{major}.0.0-{alpha|beta|rc}.{number}`):

- `master` → `next`
- `v{major}.x` → `latest`

Stable releases:

- `master` → `latest`
- `v{major}.x` → `v{major}.x`

## Step 2: Find inconsistent commits

```bash
git log upstream/<docs-branch> --not upstream/<core-branch> --oneline --no-merges
```

This lists commits in the docs branch that are NOT in the core branch.

### Filter out false positives

Cherry-picked commits have different SHAs but identical content. For each candidate commit, extract the PR number from the message (e.g. `#47820`) and check if the core branch already has it:

```bash
git log upstream/<core-branch> --oneline --no-merges --grep="<PR number>"
```

If a match is found, the commit is a false positive — remove it from the list.

Present only the **truly missing** commits to the user.

## Step 3: Fix (only if user asks)

For each inconsistent commit, create a PR targeting the core branch:

- One PR per commit
- Title: cherry-picked commit message with original author username as prefix to PR number, e.g. `[blog] Blogpost for upcoming price changes for MUI X (@GHuser) (#47820)`
- Body: empty, no co-authors or signature

### Example

Given `core=v7.x`, `docs=latest`, and 3 cherry-picked commits only in `latest`:

```
abc1234 [blog] Blogpost for upcoming price changes for MUI X (#47820)
def5678 [docs] Fix broken link in Data Grid pagination (#47835)
ghi9012 [core] Fix CI flaky test (#47850)
```

Create 3 PRs targeting `v7.x`:

- `[blog] Blogpost for upcoming price changes for MUI X (@alexfauquette) (#47820)`
- `[docs] Fix broken link in Data Grid pagination (@cherniavskii) (#47835)`
- `[core] Fix CI flaky test (@michaldudak) (#47850)`

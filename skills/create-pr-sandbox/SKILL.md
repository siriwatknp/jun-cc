---
name: create-pr-sandbox
description: Fetch latest PRs from a given MUI repo, find one that is a bug fix/new feature/regression, create a StackBlitz sandbox demoing the change, and update the PR description with the sandbox URL. Designed to run on a recurring schedule via /loop to automatically process new PRs.
argument-hint: "[repo]"
allowed-tools: Bash, Read, Skill(create-mui-sandbox), Skill(using-mui-components)
---

## Input

- `$ARGUMENTS` = GitHub repo (e.g. `mui/material-ui` or `mui/mui-x`)

If no argument provided, ask for the repo.

## Steps

### 1. Fetch latest PRs

```bash
gh pr list --repo $ARGUMENTS --limit 10 --state open --json number,title,labels,body --jq '.[] | {number, title, labels: [.labels[]?.name], has_stackblitz: (.body | test("stackblitz\\.com")), has_try_it: (.body | test("^Try it here:"))}'
```

### 2. Filter PRs

From the results, keep PRs matching ALL criteria:

- **Labels** contain one of: `bug`, `new feature`, `regression`, `enhancement`, `type: enhancement`, `type: bug`. If no label match, fall back to title containing `[fix]`, `regression`, or starting with a component tag followed by "Add" (e.g. `[Button] Add ...`).
- **`has_stackblitz` is `false`** AND **`has_try_it` is `false`** (no existing sandbox)

Skip PRs with labels like `internal`, `dependencies`, `release`, `website`, `scope: docs-infra`, `scope: code-infra` — these are not user-facing changes worth demoing.

If no PR matches, report "No eligible PRs found", write a log entry (see Step 7), and stop.

### 3. Create task list

Sort the filtered PRs by PR number ascending. Create a task for each using `TaskCreate`:

- Task name: `PR #<number> — <title>`
- Status: pending

Process tasks **sequentially** in order. Before starting each task, set its status to `in_progress`. After completion, set to `completed` or `failed`.

### 4. For each task: check CI status

Before reading the diff, check if "Continuous Releases" has passed:

```bash
gh pr checks <number> --repo $ARGUMENTS --json name,state --jq '.[] | select(.name == "Continuous Releases")'
```

If the check is not `SUCCESS`, mark the task as `failed` with reason "Waiting for 'Continuous Releases' CI" and move to the next task.

### 5. For each task: understand the PR change

First check the diff size:

```bash
gh pr diff <number> --repo $ARGUMENTS | wc -l
```

If over 2000 lines, use `--stat` to get an overview and only read the diff for the most relevant source files (skip test files, generated files, docs JSON):

```bash
gh pr diff <number> --repo $ARGUMENTS --stat
gh pr diff <number> --repo $ARGUMENTS -- 'packages/*/src/**'
```

Read the diff to understand:

- Which component(s) changed
- What the fix/feature does
- What MUI packages are involved

### 6. For each task: create sandbox

Invoke `/create-mui-sandbox` with an explicit prompt like:

> Create a StackBlitz sandbox for PR #<number> from <repo>. I need a shareable URL.
>
> The PR <one-sentence summary of the change>. Here's the demo code:
>
> ```tsx
> <your Demo.tsx code here>
> ```

The demo code should render the affected component in a way that showcases the fix or new feature. Keep it minimal — just enough to see the change in action.

If sandbox creation fails, mark the task as `failed` with the error reason and move to the next task.

### 7. For each task: update PR description

Once you have the forked StackBlitz URL, prepend it to the PR body safely using a temp file (avoids shell quoting issues with special characters in PR bodies):

```bash
gh pr view <number> --repo $ARGUMENTS --json body --jq '.body' > /tmp/pr-body.txt
printf 'Try it here: %s\n\n' "$FORKED_URL" | cat - /tmp/pr-body.txt > /tmp/pr-body-new.txt
gh pr edit <number> --repo $ARGUMENTS --body-file /tmp/pr-body-new.txt
rm /tmp/pr-body.txt /tmp/pr-body-new.txt
```

Mark the task as `completed`. If the update fails, mark as `failed`.

### 8. Write log report

After all tasks are processed (or if no eligible PRs found), write a markdown log to `~/.claude/log/create-pr-sandbox-<YYYY-MM-DD-HHmmss>.md`:

```markdown
# create-pr-sandbox log

- **Repo:** <repo>
- **Date:** <ISO timestamp>
- **Eligible PRs:** <count>

## Results

| PR                                           | Title                | Status    | Sandbox URL                     | Error                 |
| -------------------------------------------- | -------------------- | --------- | ------------------------------- | --------------------- |
| [#1234](https://github.com/<repo>/pull/1234) | [Button] Fix hover   | completed | https://stackblitz.com/edit/xxx | —                     |
| [#1235](https://github.com/<repo>/pull/1235) | [TextField] Add size | failed    | —                               | agent-browser timeout |

## Summary

- Completed: N
- Failed: N
- Skipped (no eligible): N
```

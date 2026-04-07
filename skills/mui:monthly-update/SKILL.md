---
name: mui:monthly-update
description: Generate a monthly update report for Material UI (core and X) contributions, including merged PRs, highlights, and stats. Use when asked to summarize recent contributions or create a monthly report
user-invocable: true
argument-hint: "[month]"
---

Default month is the previous calendar month (e.g. if today is June 15, default to May).
Use the 1st and last day of that month as the date range.

## Parallelism

Maximize parallel tool calls throughout. The steps below note which calls are independent.

## Step 1: Detect fork and resolve upstream repo + Get CSE team members

Run both in **parallel**:

```bash
# Call 1
gh repo view --json isFork,parent,defaultBranchRef

# Call 2
gh api orgs/mui/teams/cse/members --jq '.[].login'
```

- If `isFork` is true, use `parent.owner.login/parent.name` as the target repo and `parent.defaultBranchRef.name` as the target branch.
- If not a fork, use the current repo and its default branch.

Store the resolved `OWNER/REPO` and `DEFAULT_BRANCH` for all subsequent queries.

## Step 2: Collect merged PRs for each member

Run **all** author and reviewer searches in **parallel** (one Bash tool call per search):

```bash
# one call per member — run ALL in parallel
gh search prs --repo OWNER/REPO --author USERNAME --merged-at YYYY-MM-01..YYYY-MM-DD --state closed --json number,title,url,closedAt,labels --limit 100

# one call per member — run ALL in parallel (same batch as above)
gh search prs --repo OWNER/REPO --reviewed-by USERNAME --merged-at YYYY-MM-01..YYYY-MM-DD --state closed --json number,title,url,closedAt,labels,author --limit 100
```

Deduplicate PRs across members and categories. Tag each PR with:

- `authored-by: <username>` if authored
- `reviewed-by: [<usernames>]` if reviewed/approved

## Step 3: Fetch +/- stats and linked issues in one parallel batch

`additions`, `deletions`, and `closingIssuesReferences` are NOT available in `gh search prs --json`. Fetch them together per authored PR.

Run a **single Bash call** that fetches all PRs in parallel using background jobs:

```bash
for pr in PR1 PR2 PR3 ...; do
  (gh pr view $pr --repo OWNER/REPO --json additions,deletions,closingIssuesReferences \
    --jq "{number: $pr, additions: .additions, deletions: .deletions, issues: [.closingIssuesReferences[].number]}") &
done | jq -s '.'
wait
```

Then collect all unique issue numbers from the results and fetch their reaction counts in **one parallel batch**:

```bash
for issue in ISSUE1 ISSUE2 ...; do
  (echo -n "$issue "; gh api repos/OWNER/REPO/issues/$issue --jq '.reactions.total_count') &
done
wait
```

Use reaction counts to rank PRs for the Achievements section — PRs fixing highly-upvoted issues (10+ reactions) should appear first in highlights. PRs with no linked issue or low-reaction issues can still be highlights if they are significant features or breaking changes.

## Step 4: Generate the report

Create `MONTHLY_UPDATE_<YYYY-MM>.md` in the current directory.

### Report structure

The report should be slide-compatible — concise bullets that can be copy-pasted into a presentation slide. Follow this format:

```markdown
# CSE Monthly Update — <Month YYYY>

## Achievements in <Month>

- Feature or contribution summary
- Another achievement
- Theme-level summary (e.g. "v9 beta and stable prep")
- ...

### Achievement References

| Achievement | PR | Demo / Deploy Preview |
| ----------- | -- | --------------------- |
| Feature or contribution summary | [#123](pr-url) | [preview](deploy-preview-url) |
| Another achievement | [#456](pr-url) | - |

## Full PR list

### <username>

#### Authored

| #           | Title | +/-      | Date       |
| ----------- | ----- | -------- | ---------- |
| [#123](url) | Title | +100/-50 | YYYY-MM-DD |

#### Reviewed

| #           | Title | Author | Date       |
| ----------- | ----- | ------ | ---------- |
| [#456](url) | Title | author | YYYY-MM-DD |
```

### Guidelines for Achievements

- Keep each bullet as plain text — no links, no markdown. These get copy-pasted into Google Slides
- Group related PRs into a single bullet when they form a theme (e.g. "v9 beta and stable prep")
- Focus on user-facing impact: new features, bug fixes, performance improvements
- Prioritize PRs that fix highly-upvoted issues (10+ reactions) — mention the reaction count in parentheses, e.g. "(25 upvotes)"
- 3-5 bullets max

### Guidelines for Full PR list

- Sort PRs by date (most recent first)
- Only include members who had activity in the month

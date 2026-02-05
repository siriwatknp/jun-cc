---
allowed-tools: mcp__github__get_issue, mcp__github__get_issue_comments, mcp__github__search_issues, mcp__github__search_pull_requests
description: Collect my merged commits to master/main branch of the specified range.
argument-hint: [username] [range]
---

If username argument is not provided, default to every user.

If no range argument is provided, default to last 3 months.
Always use the 1st of the start month and the last day of the end month for the range.

IMPORTANT!: recheck the username and date range with the user before proceeding.

## Goal

Go through my merged commits (siriwatknp) to master/main branch since last specific months, and create a summary report named `CONTRIBUTIONS_<username>_<range>.md`.

The report should include:

- Highlights of significant contributions
- Total number of commits
- Amount of lines added and removed (per PR and total)
- List of all merged pull requests with links ordered by date (most recent first) and include the issue number with links if applicable

## Rules

- Use Github CLI, fallback to Github MCP if necessary
- Focus on merged commits to master/main branch only

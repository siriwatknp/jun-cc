---
allowed-tools: mcp__github__get_issue, mcp__github__get_issue_comments, mcp__github__search_issues, mcp__github__search_pull_requests
description: Triage the provided issue and write down detailed information to a markdown file.
---

Triage issue $1 and finally write down detailed information to `.claude/issues/<issue-number>.md` file.

<preparation>
Throw error if any of the following conditions are not met:
1. Ensure you have access to the repository and can view issues.
2. Ensure the Github MCP is enabled and configured.
</preparation>

Steps to triage an issue:

## Gather context

- Read the issue description and comments
- Check for related issues or pull requests
- Skim the codebase to understand the relevant components

Put those information into the file.

The top of the file should contain a table summary:

- Size and complexity of the issue
- Value to users once resolved (e.g. take user upvote count into account)
- A brief description of the problem

Then, add concise content and focus on the key points.
Add links to related issues, pull requests, or documentation as needed.

## Analyze the issue

Drill down into the technical details and relevant codebase from the context.
Identify the root cause of the issue and any dependencies or constraints.

Write down your findings to the file. Provide code snippets or diagrams if they help illustrate the problem.

Summarize the maintainer's perspective/latest decision/suggestion if available.

## Reproduce the issue

If you are in a `material-ui-x` local repository, create a minimal reproduction of the issue at `docs/pages/playground/{issue-<issue-number>-<short-name>}.tsx`.

The reproduction should follow the pattern of existing playground examples.

## Explore potential solutions

Write down possible approaches to resolve the issue, including:

A summary table of the solutions ordered by size, with columns for:

- Approach
- Effort (time estimate)
- Affected components (e.g. components, docs)

Then, add detailed descriptions of each approach, including:

- List pros and cons of each approach
- Consider the impact on existing functionality
- Estimate the effort required for each approach
- Suggest documentation updates if applicable
  - Include demos or examples, especially for the recommended solution
  - For code snippets, all usage in the snippet should be defined or imported at the top of the snippet

Note: the recommended solution should have much more details than the alternatives including code snippets, demos and explanations.

## Further steps

A summary of the next steps to resolve the issue, including:

- Recommended approach to take
- Any additional research or investigation needed

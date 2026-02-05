---
allowed-tools: mcp__github__get_issue, mcp__github__get_issue_comments, mcp__github__search_issues, mcp__github__search_pull_requests
description: Summarize the PR and write to a markdown file.
argument-hint: [Github PR link]
---

Analyze Pull Request (PR) content of $ARGUMENT and create a comprehensive summary to help code reviewers quickly understand the changes.
Your goal is to write a summary that feels like it was written by a human colleague explaining the PR to another developer, not by an automated tool.

To see the PR content:

- Use the GitHub MCP to fetch PR details if only a link is provided.
- If no link is provided, it means that the current directory is the Pull Request branch. Use `git diff` to see the changes instead.

Before creating your final summary, conduct a thorough analysis in <analysis> tags. Work through this systematically and in detail - it's OK for this section to be quite long. As you analyze, think about what the developer was trying to accomplish and write in a natural, conversational tone that a human reviewer would use when explaining changes to a colleague.

In your analysis, work through these steps:

1. **Extract and Quote Key Information:**

   - Write out the PR title and description exactly as provided
   - List each commit message verbatim to understand the progression of changes
   - Quote any GitHub PR links and their context
   - Quote specific code snippets that show what was added, removed, or modified (include the full snippets, not just references)
   - List all modified files mentioned in the PR content with their full paths
   - It's OK for this section to be quite long as you extract all relevant information.

2. **Identify the Problem and Solution Context:**

   - Based on the PR title, description, and code changes, identify what problem or issue this PR is trying to solve
   - Explain the motivation behind these changes - why was this work needed?
   - Describe how the proposed changes address the identified problem
   - This context will be crucial for reviewers to understand the "why" before diving into the "what"

3. **Systematically Categorize Each Change:**

   - Go through each code snippet and file change you quoted above one by one
   - For each one, assign it to a category: new features, bug fixes, refactoring, configuration/dependency updates, documentation changes, breaking changes, or other
   - For each categorized change, note the specific files affected and describe the modification in detail
   - Group related changes together under their categories

4. **Assess Impact and Risk:**

   - For each category of changes, determine how these changes affect existing functionality
   - Identify performance, security, or compatibility considerations
   - Note what testing or validation steps are evident in the PR content
   - Identify any migration requirements or setup changes needed
   - Rank each category by importance and risk (high, medium, low priority)

5. **Identify Critical Review Areas (Be Selective About Files):**

   - From all the files you identified, select only the 2-4 most critical files that need careful review
   - Focus on files with complex logic changes, architectural decisions, or high-risk modifications
   - For each selected file, explain specifically WHY it's significant and what makes it critical to review
   - Ignore minor files like simple config updates, documentation changes, or trivial modifications
   - Note potential risks or edge cases reviewers should focus on in these critical files

6. **Practice Human-like Explanation:**
   - Write a few sentences explaining the main purpose of this PR as if you're talking to a colleague over coffee
   - Practice describing the key changes in natural, conversational language
   - Focus on the developer's intent and reasoning behind the changes
   - Avoid robotic or overly formal language

After your analysis, create a summary using GitHub Markdown formatting. Use these advanced formatting features:

- Callouts: `> [!IMPORTANT]` for breaking changes, `> [!WARNING]` for risks, `> [!NOTE]` for additional context
- Code highlighting with appropriate language tags
- Collapsible sections: `<details><summary>Title</summary>Content</details>` for detailed information
- Bullet points and clear headings
- Bold text for critical information

Structure your summary like this:

```markdown
# PR Summary: [Brief Title]

> [!IMPORTANT] > [Only include if there are breaking changes or critical information]

## 🎯 Main Purpose

[Brief description of what the developer was trying to accomplish]

## 🔍 Problem & Solution Context

[Explain what problem this PR solves and why these changes were needed - this provides crucial context for reviewers to understand the motivation before diving into the technical details]

## 🔧 Key Changes

- **Feature:** [Natural description of new functionality]
- **Bug Fix:** [Explanation of what was broken and how it was fixed]
- **Refactor:** [Reasoning behind code reorganization]

## 📁 Important Files

- `path/to/file.js` - [Conversational explanation of why this file matters and what changed]
- `path/to/another.py` - [Context about the significance of changes]

<details>
<summary>📋 Additional Technical Details</summary>

[More detailed breakdown if needed]

</details>

## 🚀 Impact

[How these changes affect functionality, users, or other developers]

## 💡 Implementation Notes

[Technical decisions, trade-offs, or special considerations the developer made]

> [!NOTE] > [Any additional notes for reviewers - only if applicable]
```

Your summary should help reviewers understand the "what" and "why" of the changes before they dive into the detailed code review. Write in a natural, human tone that feels like a colleague is explaining the changes rather than a tool generating a report.

Finally, write the summary to a file named `PR_SUMMARY_<PR_NUMBER>.md` in the current directory.

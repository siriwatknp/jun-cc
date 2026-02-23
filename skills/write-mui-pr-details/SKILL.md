---
name: mui:write-pr-details
description: Write PR details based on the changes made to be used in Github PR description.
---

This skill can be used only for Github Pull Requests. Make sure you have full understanding of GitHub Flavored Markdown (GFM) to write effective PR descriptions.

## Important: Use `gh` CLI without PR body

**NEVER copy or reuse an existing PR description.** Always create the PR description fresh by:

1. MUST use `gh pr view --json number,title,url,baseRefName,headRefName,commits` (WITHOUT `body`) to read PR metadata and commits.
2. Reading the actual code changes (`gh pr diff`)
3. Understanding the implementation from the source files
4. Writing a new description based on your analysis

## Goal

Write detailed Github PR description to be included in the Pull Request to a new markdown file.
The size of the PR description varies depending on the complexity of the changes made and type of changes BUT the format remains consistent.

## Content

- should have `closes #ISSUE_NUMBER` if applicable
- should have links to deploy preview (all of the updated demos) if applicable
- for a new feature, invoke the `/create-mui-sandbox` skill to create a sandbox with shareable link. **IMPORTANT: Always create a NEW sandbox - never reuse existing sandbox URLs from the PR body. After the sandbox is created, add the sandbox URL to the PR description under the usage section.**
  - for bux fixes, the sandbox should demonstrate how the change fixes the issue
  - for small new feature, the sandbox should demonstrate the basic usage with minimal explanation
  - for medium to large new feature, the sandbox should demonstrate multiple examples with explanations starting from basic usage to advance customization
- write a summary of the changes. this should be a high-level for users to understand in human language (might include a psuedocode or code snippet for usage if applicable), also include other relevant features that are related to the changes made in the PR.
- write another section for reviewers to explain the technical details but avoid presenting code snippets unless absolutely necessary. should focus on explaining the design decisions and trade-offs.
- for technical details, add references to the "Files changed" section of the Github PR for context, for example:
  - "The new [`GridEditLongTextCell`](https://github.com/mui/mui-x/pull/20980/files#diff-35467323ef549bba986740b362d085874355e6e8e7ea267a1b20f4da38478490) component is introduced to handle multiline text editing."
  - "[Prevent space key](https://github.com/mui/mui-x/pull/20980/files#diff-c6752f337948eb1066d4821e37e073ea84276370ab549d3efb97ebb3a2e10bdaR794-R796) from the grid navigation when the column is `longText`"

## GitHub Diff Anchors

**IMPORTANT:** GitHub diff anchors are `sha256(file_path)`, NOT the file blob SHA from the API.

To generate correct diff anchor for a file:

```bash
echo -n "path/to/file.tsx" | shasum -a 256 | cut -d' ' -f1
```

Example:

```bash
echo -n "packages/x-data-grid/src/components/cell/GridLongTextCell.tsx" | shasum -a 256 | cut -d' ' -f1
# Output: 0ae22d41cfc8f0b3bd9fc8df5c2238618661545fda0429b7b20e985bae629691
```

Link format: `https://github.com/{owner}/{repo}/pull/{pr}/files#diff-{sha256_of_filepath}`

To link to specific lines, append `R{line}` or `L{line}-R{line}`:

- `#diff-{hash}R123` - right side (new) line 123
- `#diff-{hash}L100-R105` - left line 100 to right line 105

## Deploy preview

The deploy preview URL can be found by the `mui-bot` in the comments section of the PR.

## Sandbox packages

When invoking `/create-mui-sandbox`, pass the PR context so it uses `pkg.pr.new` packages automatically. See the `create-mui-sandbox` skill's [PR Packages](../create-mui-sandbox/SKILL.md#pr-packages) section for details.

## Format

```
closes #ISSUE_NUMBER (if applicable)

- **Docs**: {{deploy preview url}}
- **Sandbox:** [Try it on StackBlitz]({{sandbox url}})  <-- REQUIRED for new features

## Summary

{{summary of changes}}

## For Reviewers

{{technical details with references to "Files changed" section}}

---

- [x] I have followed (at least) the [PR section of the contributing guide](https://github.com/mui/mui-x/blob/HEAD/CONTRIBUTING.md#sending-a-pull-request).
```

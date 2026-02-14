---
description: Follow the steps to prepare an alpha release for MUI packages or audit a PR that prepares an alpha release.
---

## Prerequisites

Get the context about the preparation from the prior releast PR: https://github.com/mui/material-ui/pull/45132/changes

- If you are asked to prepare the release, use the TaskList tool to do the following steps. Each step should be a separate commit. After completing all the steps, create a PR with the title `chore: prepare alpha release` and include the checklist of all the steps in the PR description.
- If you are asked to audit the release PR, review the PR description and check if all the steps are covered, then review the code changes to make sure they are correct and create a markdown report.

## Steps

1. locate all the files for '#npm-tag-reference' in the codebase (ignore folders/files from `.gitignore`) and update the package installation (within 20 lines before the reference tag) to `next` for all MUI packages.

For example, in `docs/data/system/getting-started/installation/installation.md`, the tag reference should be updated as follows:

````diff
<!-- #npm-tag-reference -->

<codeblock storageKey="package-manager">

```bash npm
- npm install @mui/system @mui/styled-engine-sc styled-components
+ npm install @mui/system@next @mui/styled-engine-sc@next styled-components
```

```bash pnpm
- pnpm add @mui/system @mui/styled-engine-sc styled-components
+ pnpm add @mui/system@next @mui/styled-engine-sc@next styled-components
```

```bash yarn
- yarn add @mui/system @mui/styled-engine-sc styled-components
+ yarn add @mui/system@next @mui/styled-engine-sc@next styled-components
```

```
````

IMPORTANT!

- DO NOT update `@mui/joy` (it's on hold).
- DO NOT update other non-MUI packages (e.g., `styled-components`, `@emotion/react`, or `@base-ui/react`).

2. locate all the files for '#host-reference' in the codebase (ignore folders/files from `.gitignore`) and update the host (within 20 lines before the reference tag) from `https://mui.com` to `https://next.mui.com`.

For example, in `README.md`, the host reference should be updated as follows:

```diff
<!-- #host-reference -->
<!-- markdownlint-disable-next-line -->
<p align="center">
-  <a href="https://mui.com/core/" rel="noopener" target="_blank"><img width="150" height="133" src="https://mui.com/static/logo.svg" alt="Material UI logo"></a>
+  <a href="https://next.mui.com/core/" rel="noopener" target="_blank"><img width="150" height="133" src="https://next.mui.com/static/logo.svg" alt="Material UI logo"></a>
</p>
```

3. Update workspace dependency versions to `*` like this commit: https://github.com/mui/material-ui/pull/45132/commits/613958d611dd9b2dd4eb08f88219216da0078376
4. Update all `/examples/**/package.json` to target `next` for all MUI packages EXCEPT `@mui/joy`.

For example, in `examples/material-ui-nextjs-ts/package.json`, the dependencies should be updated as follows:

```diff
  "dependencies": {
-    "@mui/icons-material": "latest",
+    "@mui/icons-material": "next",
-    "@mui/material": "latest",
+    "@mui/material": "next",
-    "@mui/material-nextjs": "latest",
+    "@mui/material-nextjs": "next",
  }
```

5. Update publish command NPM tag to `next` like this commit: https://github.com/mui/material-ui/pull/45132/changes/9352e1ae79592d8c040f57946fcd5ff07c9365d2
6. Update docs deploy command to target material-ui-docs's next branch like this commit: https://github.com/mui/material-ui/pull/45132/changes/c6eea46b7f460fab14261c43ce36cb8e693ce963
7. Add v\*.x version (ask the user for the exact version before proceed this step) item in docs versions dropdown like this commit: https://github.com/mui/material-ui/pull/45132/changes/c2f569712116584ce9eb2d5653c7d7c12cf31404
8. Update the table of supported versions in docs like this commit: https://github.com/mui/material-ui/pull/45132/changes/bfb1602436c02bd1a26fa1c556652cf6676eb93e
9. Create a migration guide docs page (follow the existing pattern in the repo) for the next major version like this commit: https://github.com/mui/material-ui/pull/45143/changes#diff-310636e6b95b7f316e611b17873df36a57addd78ecbad24f9d8f6b3dedff9ad9

- Create `docs/data/system/migration/upgrade-to-v*/upgrade-to-v*.md` (ask the user for the exact version before proceed this step)
- Create `docs/pages/material-ui/migration/upgrade-to-v*.js` (same version as above)
- Update `docs/data/material/pages.ts` to include the new migration guide page
- Create `docs/data/system/migration/upgrade-to-v*/upgrade-to-v*.md` (same version as above)
- Create `docs/pages/system/migration/upgrade-to-v7.js` (same version as above)
- Update `docs/data/system/pages.ts` to include the new migration guide page
- Finally run `pnpm docs:i18n` to generate the i18n files for the new migration guide pages

10. Bump internal packages to the next major version like this commit: https://github.com/mui/material-ui/pull/45154/changes
11. Check MUI X redirects are the correct ones like this commit: https://github.com/mui/material-ui/pull/45207/changes

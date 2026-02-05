---
name: build-mui-demo
description: Build and/or update a Material UI or MUI X demo and its documentation
---

You will be asked to build/update a demo for one of the packages below.

## Quick Start

1. Identify target package from the table below
2. Start dev server: `pnpm docs:dev` (Material UI: port 3000, MUI X: port 3001)
3. Follow steps 0-5 below

## Target Packages

| Package               | productId        | Doc Data Path             | Dev Port |
| --------------------- | ---------------- | ------------------------- | -------- |
| `@mui/material`       | `material-ui`    | `docs/data/material/`     | 3000     |
| `@mui/x-data-grid`    | `x-data-grid`    | `docs/data/data-grid/`    | 3001     |
| `@mui/x-charts`       | `x-charts`       | `docs/data/charts/`       | 3001     |
| `@mui/x-date-pickers` | `x-date-pickers` | `docs/data/date-pickers/` | 3001     |
| `@mui/x-tree-view`    | `x-tree-view`    | `docs/data/tree-view/`    | 3001     |

Notes:

- Data Grid markdown files do not need frontmatter
- Material UI sidebar: `docs/data/material/pages.ts`
- MUI X sidebar: `docs/data/pages.ts`
- **Data Grid recipes**: Advanced demos combining multiple features. Located in `*-recipes` folders (e.g., `column-recipes`, `row-recipes`)

## Component Doc Folder Structure

**Standard demo folder:**

```
{{component}}/
├── {{component}}.md          # Main documentation file
├── {{DemoName}}.tsx          # Demo source (TypeScript)
├── {{DemoName}}.js           # Generated from .tsx via pnpm command
└── {{DemoName}}.tsx.preview  # (optional) Auto-generated preview snippet
```

**Data Grid recipe folder:**

```
{{feature}}-recipes/
├── index.md                  # Uses index.md instead of {{feature}}.md
├── {{RecipeName}}.tsx
├── {{RecipeName}}.js
└── {{RecipeName}}.tsx.preview
```

Recipe markdown only needs `title` in frontmatter:

```md
---
title: Data Grid - {{Feature}} recipes
---
```

## Steps to Build/Update a Demo

Variables to identify:

- `{{markdownFilePath}}`: path to component markdown file
- `{{pagePath}}`: path to Next.js page file
- `{{url}}`: url to view the demo
- `{{DemoName}}`: PascalCase demo name (e.g., `BasicNumberField`)

### 0. Determine doc location (if path not provided)

Search `docs/data/{{productId}}/**` to understand the folder structure.

**A. For existing component/feature** (adding demo to existing docs):

1. Find folder matching the component/feature name
2. Locate the `.md` file within that folder
3. Check if a similar demo already exists (search for related keywords in `.tsx` files)
   - If found: **STOP and notify user** with the existing demo path, then wait for instruction

**B. For new component/feature** (creating new docs):

1. Find a similar component to use as reference
2. Create new folder following the same pattern:
   - Material UI: `docs/data/material/components/{{component}}/`
   - MUI X: `docs/data/{{productId}}/{{feature}}/`
3. Use kebab-case for folder and file names (e.g., `number-field`)

Once determined, set:

- `{{markdownFilePath}}`: e.g., `docs/data/material/components/number-field/number-field.md`
- `{{pagePath}}`: derive from similar component's page in `docs/pages/`
- `{{url}}`: based on dev port + pathname pattern from similar component

### 1. Create component markdown (if not existing)

Location: `{{markdownFilePath}}`

**Copy structure from similar component's `.md` file** (found in Step 0) and adapt:

- Update frontmatter: `productId`, `title`, `components`, `githubLabel`, `githubSource`
- Update heading and description
- Remove demo references (will add in Step 4)

Minimal frontmatter (skip for Data Grid):

```md
---
productId: {{productId}}
title: {{Component}} React component
components: {{Component}}
githubLabel: 'scope: {{component}}'
githubSource: packages/mui-material/src/{{Component}}
---
```

### 2. Create demo TypeScript file

Location: same folder as `{{markdownFilePath}}`

**Before writing**: Read existing demos in the folder to match style/structure.

Rules:

- Demo name: short, descriptive, PascalCase (e.g., `BasicNumberField`)
- Must export React component as default
- Keep focused on one feature/concept
- Match existing demos' style
- Comments only when: code is incomplete OR non-obvious decisions exist
- Invoke the skill `using-mui-components` for best practices

### 3. Generate JavaScript version of the demo

Run the following command to generate the JavaScript version of the demo:

**Material UI:**

```bash
pnpm docs:typescript:formatted --pattern {{DemoName}}
```

**MUI X** (`--pattern` not supported):

```bash
pnpm docs:typescript:formatted
```

### 4. Include the demo in the component markdown

In the component markdown file located at {{markdownFilePath}}, include the demo by adding the following line at the appropriate location:

```md
{{"demo": "{{DemoName}}.js"}}
```

!IMPORTANT: ensure that the demo with `.js` is generated before including it in the markdown file.

### 5. Create Next.js page (once)

Location: `{{pagePath}}` (find similar pages in `docs/pages/` to match the pattern)

```tsx
import MarkdownDocs from "docs/src/modules/components/MarkdownDocsV2";
import AppFrame from "docs/src/modules/components/AppFrame";
import * as pageProps from "{{markdownFilePath}}?muiMarkdown";

export default function Page() {
  return <MarkdownDocs {...pageProps} />;
}

Page.getLayout = (page) => {
  return <AppFrame>{page}</AppFrame>;
};
```

**Add to sidebar** (see Target Packages for file location):

```ts
{
  pathname: '/material-ui/react-{{component}}',  // or '/x/react-charts/{{chart-type}}'
  title: '{{Component}}',
}
```

## Coding Conventions

- Import order: third-party → local files
- Alphabetical within each group
- **No unused imports or variables**

```tsx
// ✅ CORRECT
import React from "react";
import Button from "@mui/material/Button";
import CustomComponent from "./CustomComponent";

// ❌ INCORRECT
import CustomComponent from "./CustomComponent";
import React from "react";
import Button from "@mui/material/Button";
```

---

## Example

Adding `number-field` component to Material UI with demos `BasicNumberField` and `SpinnerField`:

| Variable         | Value                                                        |
| ---------------- | ------------------------------------------------------------ |
| markdownFilePath | `docs/data/material/components/number-field/number-field.md` |
| pagePath         | `docs/pages/material-ui/react-number-field.js`               |
| sidebar          | `docs/data/material/pages.ts`                                |
| url              | `http://localhost:3000/material-ui/react-number-field/`      |

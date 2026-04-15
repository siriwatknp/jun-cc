---
name: mui:migrate-v9
description: Migrate a project's @mui/* dependencies from v7/v8 to v9 (stable). Use whenever the user asks to upgrade, migrate, bump, or move Material UI or MUI X to v9 — or mentions issues after upgrading, broken codemods, Grid size prop, PickersDay→PickerDay, MuiInputBase-inputSizeSmall, system-props on Box/Grid/Typography, or v9 browser targets. Material UI skips v8, going straight from v7 to v9 in lockstep with MUI X v9.
---

Migrate `@mui/*` packages from v7/v8 to v9 in a project. Codemod-first, with surgical manual fixes for the residue. The skill is structured as **five sequential phases**; each phase ends with a named commit so reviewers (and `git bisect`) can follow the work.

## Why this skill exists

Running MUI codemods against a source directory naively traverses `node_modules` for hours and still reports `0 ok` because the default extension glob excludes `.tsx`. This skill captures the correct invocation pattern (explicit file list via `find | xargs`) plus the manual fixes codemods cannot express — Select sm-size selectors, Menu `PaperProps`, legacy `*Outline` icons, system-prop holdouts, etc. Following the phases in order avoids hours of guessing.

## Track progress with TodoWrite

Before starting Phase 0, create a todo list using the `TodoWrite` tool seeded with the five phases. Update each item to `in_progress` when you start it and `completed` the moment the phase's commit lands — don't batch updates. This migration touches many files and spans multiple commits; the todo list is what keeps you (and the user watching) oriented across long codemod runs and CI waits.

Seed items:

1. Phase 0 — Preflight audit
2. Phase 1 — Bump versions + commit
3. Phase 2 — Run codemods + commit
4. Phase 3 — Manual fixes + commit(s)
5. Phase 4 — Verify (typecheck, lint, build, tests)
6. Phase 5 — Secondary workspaces (if any) + commit

If Phase 3 fans out into several unrelated concerns (icons / theme / system props / etc.), add a todo per concern so the commit plan stays legible.

## Inputs to gather before starting

Ask the user if any of these are unclear:

- **Repo layout** — which directories hold app code (e.g. `src`, `app`, `components`, `lib`, or multi-workspace dirs like `apps/*`, `packages/*`). Call this set `<src-dirs>`.
- **Primary workspace** — the one that must pass CI first. Secondary workspaces (other apps, examples) go in Phase 5.
- **Keep or drop `@mui/x-date-pickers-pro`** — v9 shifted Pro/Premium to application-based licensing. If the user isn't using Pro-only pickers, drop it.
- **Package manager** — `pnpm`, `npm`, or `yarn`. Affects install + lockfile commands.

## Phase 0 — Preflight (no commit)

Produce intel, don't touch source yet.

1. Working tree must be clean. Create branch: `git checkout -b upgrade/mui-v9`.
2. Enumerate all `@mui/*` deps across every `package.json` in the repo:
   ```bash
   grep -H '"@mui' **/package.json
   ```
3. Verify peers. v9 requires React ≥ 19 and bumps browser targets to Chrome 117+, Firefox 121+, Safari 17+. Flag any `engines`/`browserslist`/`targets` that would conflict.
4. Audit breaking-change hotspots in `<src-dirs>`:
   ```bash
   grep -rn "GridLegacy\|components=\|componentsProps=\|TransitionComponent\|x-date-pickers-pro\|MuiInputBase-inputSizeSmall\|PickersDay\|unstableFieldRef\|ChartContainer\|useItemHighlighted\|TreeViewBaseItem\|useTreeViewApiRef\|enableAccessibleFieldDOMStructure\|@mui/icons-material/[A-Z][A-Za-z]*Outline" <src-dirs>
   ```
5. Report hits to the user, confirm pickers-pro decision, then continue.

**Commit:** none. Phase 0 is read-only.

## Phase 1 — Bump versions

Update every `package.json` that references `@mui/*`:

```
@mui/material              ^9
@mui/icons-material        ^9
@mui/material-nextjs       ^9
@mui/system                ^9
@mui/utils                 ^9
@mui/lab                   latest v9 tag (may still be beta)
@mui/x-charts              ^9
@mui/x-data-grid           ^9
@mui/x-date-pickers        ^9
@mui/x-tree-view           ^9
```

If dropping pickers-pro, **remove** `@mui/x-date-pickers-pro` from every `package.json`.

Material UI skips v8 — do not try `^8`.

Run the project install to regenerate the lockfile (`pnpm install` / `npm install` / `yarn`).

**Commit (atomic):**
```
bump @mui/* to v9[, drop x-date-pickers-pro]
```
Only `package.json` files + lockfile. Keeping the lockfile churn isolated makes the source diffs in later phases readable.

## Phase 2 — Run codemods

### Critical invocation pattern

`npx @mui/codemod deprecations/<name> <dir>` does the wrong thing:
- Without `--extensions`, jscodeshift defaults to `.js` and silently skips `.ts/.tsx` (`0 ok` on files that obviously need changes).
- Adding `--extensions ts,tsx` makes it walk `node_modules`, spending minutes per codemod on third-party packages.

**Always pass an explicit file list via stdin.** This is fast and correct:

```bash
FILES=$(find <src-dirs> -type f \( -name "*.ts" -o -name "*.tsx" \) -not -path "*/node_modules/*")
echo "$FILES" | xargs npx -y @mui/codemod@latest deprecations/<codemod-name>
```

Same pattern for `@mui/x-codemod`.

### Material UI deprecation loop

Run all 55 — most will be no-ops per repo, but they're cheap when scoped correctly:

```bash
FILES=$(find <src-dirs> -type f \( -name "*.ts" -o -name "*.tsx" \) -not -path "*/node_modules/*")
for m in \
  accordion-props accordion-summary-classes alert-classes alert-props \
  avatar-props avatar-group-props autocomplete-props backdrop-props badge-props \
  button-classes button-group-classes card-header-props checkbox-props chip-classes \
  circular-progress-classes dialog-classes dialog-props drawer-props drawer-classes \
  divider-props form-control-label-props filled-input-props image-list-item-bar-classes \
  input-props input-base-classes input-base-props linear-progress-classes list-item-props \
  list-item-text-props menu-props mobile-stepper-props modal-props outlined-input-props \
  pagination-item-props pagination-item-classes popper-props popover-props radio-props \
  rating-props select-classes slider-props slider-classes snackbar-props \
  step-connector-classes step-content-props step-label-props speed-dial-props \
  speed-dial-action-props switch-props table-pagination-props table-sort-label-classes \
  tabs-props tab-classes toggle-button-group-classes text-field-props tooltip-props \
  typography-props; do
  out=$(echo "$FILES" | xargs npx -y @mui/codemod@latest deprecations/$m 2>&1 | grep -E "^[0-9]+ (ok|errors|skipped)$" | tr '\n' ' ')
  echo "$m: $out"
done
```

Then the one-shot `system-props` codemod (converts `<Box py={2}>` → `<Box sx={{ py: 2 }}>` and similar for Typography/Grid):

```bash
echo "$FILES" | xargs npx -y @mui/codemod@latest v9.0.0/system-props
```

### MUI X codemods

```bash
echo "$FILES" | xargs npx -y @mui/x-codemod@latest v9.0.0/charts/preset-safe
echo "$FILES" | xargs npx -y @mui/x-codemod@latest v9.0.0/pickers/preset-safe
echo "$FILES" | xargs npx -y @mui/x-codemod@latest v9.0.0/data-grid/remove-stabilized-experimentalFeatures
```

No `v9.0.0/tree-view/preset-safe` yet. Tree View breaking changes are manual (Phase 3.9).

**Commit (atomic):**
```
migrate sources to MUI v9 (codemods)
```
Nothing but codemod output. Reviewers can skim and confirm it's mechanical. Keeping it separate from Phase 3 also lets you `git diff` the codemod result against the manual fixes later.

## Phase 3 — Manual fixes

Run `npx tsc --noEmit 2>&1 | tail -80` and classify every remaining error into one of the buckets below. Do not mass-suppress — each bucket has a correct fix.

### 3.1 Legacy `*Outline` icons removed

v9 deleted 23 icon exports that were duplicates of `*Outlined`. Error: `Cannot find module '@mui/icons-material/FooOutline'`.

```diff
-import FooIcon from "@mui/icons-material/FooOutline";
+import FooIcon from "@mui/icons-material/FooOutlined";
```

Common culprits: `AddCircleOutline`, `HelpOutline`, `RemoveCircleOutline`, `CheckCircleOutline`.

### 3.2 Menu / component `PaperProps` → `slotProps.paper`

```diff
 MuiMenu: {
   defaultProps: {
-    PaperProps: { elevation: 0, variant: "outlined" },
+    slotProps: {
+      paper: { elevation: 0, variant: "outlined" },
+    },
   },
 }
```

Same pattern for any theme defaultProps using `PaperProps`, `TransitionProps`, etc.

### 3.3 Select/Input theme `MuiInputBase-inputSizeSmall` class removed

v9 removed this class from the `<input>` element. The size class now lives on the parent root as `MuiInputBase-sizeSmall`. Nested style overrides break silently: small controls fall back to md padding (visible as "my sm Select is suddenly 36px instead of 32px").

```diff
 select: {
   "&.MuiOutlinedInput-input": {
     paddingBlock: ...,
-    "&.MuiInputBase-inputSizeSmall": { paddingBlock: ... },
+    ".MuiInputBase-sizeSmall > &": { paddingBlock: ... },
   }
 }
```

Grep for other deprecated input classes (codemod's postcss plugin can't reach TS object literals):

```bash
grep -rn "MuiInputBase-inputSizeSmall\|MuiInputBase-inputMultiline\|MuiInputBase-inputAdornedStart\|MuiInputBase-inputAdornedEnd\|MuiInputBase-inputHiddenLabel" <src-dirs>
```

Replacements:
- `MuiInputBase-inputSizeSmall` → `MuiInputBase-sizeSmall > .MuiInputBase-input`
- `MuiInputBase-inputMultiline` → `MuiInputBase-multiline > .MuiInputBase-input`
- `MuiInputBase-inputAdornedStart/End` → `MuiInputBase-adornedStart/End > .MuiInputBase-input`
- `MuiInputBase-inputHiddenLabel` → `MuiInputBase-hiddenLabel > .MuiInputBase-input`

### 3.4 System-prop holdouts

`v9.0.0/system-props` catches most cases but misses when the target is a styled-component wrapper that preserves shorthand props. Typical error:

```
Property 'px' does not exist on type 'IntrinsicAttributes & BoxOwnProps<Theme> & ...'
```

Move every such prop into `sx`:

```diff
-<BoxMain minHeight={300} position="relative">
+<BoxMain sx={{ minHeight: 300, position: "relative" }}>

-<BoxRoot py={3} px={3.5}>
+<BoxRoot sx={{ py: 3, px: 3.5 }}>

-<Menu fontSize={16}>
+<Menu sx={{ fontSize: 16 }}>

-<Grid container justifyContent="space-between" spacing={2}>
+<Grid container spacing={2} sx={{ justifyContent: "space-between" }}>
```

If the wrapper's prop type is narrower than `BoxProps`, widen it (e.g. `{ style?: CSSProperties }` → `BoxProps`) so callers can pass `sx`.

### 3.5 `@mui/x-date-pickers-pro/themeAugmentation` after dropping pro

```diff
 import type {} from "@mui/x-date-pickers/themeAugmentation";
-import type {} from "@mui/x-date-pickers-pro/themeAugmentation";
```

### 3.6 Pickers renames (codemod covers most, verify)

- `MuiPickersDay` → `MuiPickerDay` (and `.MuiPickersDay-today` → `.MuiPickerDay-today`).
- `unstable(Start|End)FieldRef` → `(start|end)FieldRef`.
- Field slot prop legacy names (if codemod missed them inside custom TextField slots):
  - `InputProps` → `slotProps.input`
  - `inputProps` → `slotProps.htmlInput`
  - `InputLabelProps` → `slotProps.inputLabel`
  - `FormHelperTextProps` → `slotProps.formHelperText`

### 3.7 Charts renames (codemod covers most, verify)

- `Chart*` → `Charts*` (e.g. `ChartContainer` → `ChartsContainer`).
- CSS `.highlighted` / `.faded` → attribute selectors `[data-highlighted]` / `[data-faded]`.
- `useItemHighlighted()` → `useItemHighlightState()` (returns union instead of boolean object).
- `LineChart.showMark` default: `true → false`. `Heatmap.hideLegend` default: `true → false`. Set explicitly if you depend on prior behavior.
- Series `id` must be string and globally unique across all series (was per-type unique).

### 3.8 Data Grid

- DOM: `.MuiDataGrid-virtualScrollerContent` moved under `.MuiDataGrid-virtualScroller`; target rows via `.MuiDataGrid-virtualScrollerRenderZone`.
- i18n: `filterPanelColumns` → `filterPanelColumn` (note singular).
- `experimentalFeatures={{ charts: true }}` → remove; use `chartsIntegration` attribute.
- Pagination numbers are locale-formatted by default — update snapshots.

### 3.9 Tree View (manual — no preset-safe)

- `useTreeViewApiRef` → `useRichTreeViewApiRef` / `useSimpleTreeViewApiRef` / `useRichTreeViewProApiRef`.
- Type `TreeViewBaseItem` → `TreeViewDefaultItemModelProperties`.
- Classes `.Mui-expanded` / `.Mui-selected` removed from `treeItemClasses` → data-attr selectors `[data-expanded]` / `[data-selected]`.
- `RichTreeViewPro` defaults to virtualized rendering — set container height or pass `disableVirtualization` + `itemHeight={null}` for variable-height content.

### 3.10 Stale `@ts-expect-error`

v9 types are tighter. Directives that suppressed real errors in v7 may now point to lines that typecheck cleanly (`TS2578: Unused '@ts-expect-error' directive`). Delete the directive; don't replace with `@ts-ignore`.

### 3.11 GridLegacy removal

```diff
-<GridLegacy item xs={12} sm={6}>
+<Grid size={{ xs: 12, sm: 6 }}>
```

**Commit (atomic):**
```
migrate sources to MUI v9 (manual fixes)
```

If the manual fixes span several unrelated concerns (e.g. icons + theme + system props), split into multiple commits named by concern — the goal is that each commit is independently reviewable.

## Phase 4 — Verify

Run in order; don't skip ahead when something fails.

1. `npx tsc --noEmit` — must be clean.
2. Project lint — stash, run on the pre-upgrade baseline, unstash, compare. Pre-existing errors are not your problem; new ones are.
3. Project build (`next build` / `vite build` / whatever).
4. Generation steps if any (registry builds, static site export).
5. E2E / visual tests (Playwright, Cypress, Argos). **Pay particular attention to height/padding regressions** on inputs and selects — a 4px bump on sm Select is almost always 3.3.
6. Browser smoke-test representative pages covering DataGrid, Pickers, Charts, Menu, Select.

If CI surfaces a new issue, fix it with a follow-up commit named by the fix (e.g. `fix select sm-size selector for MUI v9`). Don't amend earlier phase commits — the phase boundaries matter for review.

**Commits:** one per CI-driven fix, as needed.

## Phase 5 — Secondary workspaces

After the primary workspace is green on CI, handle any remaining workspaces that reference `@mui/*` (other apps, examples, docs). They usually have no tests of their own, so run Phase 1 + Phase 2 scoped to those `<src-dirs>`, then Phase 3 to clean up.

**Commit (atomic):**
```
bump <workspace-name> @mui/* to v9
```
One commit per workspace if changes are non-trivial; otherwise bundle them into a single `bump secondary workspaces @mui/* to v9`.

## Reference links

- Material UI v9 upgrade: https://mui.com/material-ui/migration/upgrade-to-v9/
- MUI X Data Grid v8→v9: https://mui.com/x/migration/migration-data-grid-v8/
- MUI X Charts v8→v9: https://mui.com/x/migration/migration-charts-v8/
- MUI X Pickers v8→v9: https://mui.com/x/migration/migration-pickers-v8/
- MUI X Tree View v8→v9: https://mui.com/x/migration/migration-tree-view-v8/
- v9 announcement: https://mui.com/blog/introducing-mui-v9/

Always re-check the upgrade guide before starting — new codemods land between point releases and breaking-change lists grow as users report issues.

---
name: conducting-tech-analysis
description: Use this skill to perform technical analysis of requirements — explore the codebase, trace dependencies, and produce a research document structured around testable epics. Trigger when the user says "tech analysis", "feasibility study", "research this", "analyze the codebase for X", "is X possible", or before planning a non-trivial implementation. Use even when the user does not explicitly say "tech analysis" — any time they ask about feasibility, risks, or how to approach a change. This skill stops at epic boundaries; detailed task breakdown belongs in `/planning-research`.
---

## Goal

A research document at `exploration/<dd-mm-yyyy>-<short-description>/tech-analysis.md` (unless user specifies otherwise) that:

- Anchors to the provided requirements (linked or inlined)
- Surfaces codebase findings, shared dependencies, and risks
- Splits the work into **self-contained epics**, each ending with concrete **testable outcomes** (verification bullets live inside the epic, not in a separate section)
- States feasibility and complexity up front

The document feeds into `/planning-research` for detailed task breakdown.

## Prerequisite: requirements

Requirements anchor the whole analysis. Without them the research drifts into generic codebase exploration. If the user has not provided requirements, ask for them — point them at `/sharpen-scope` if they only have a rough idea.

Capture how requirements arrived:

- **File**: note the path — link it in the frontmatter.
- **Inline text**: summarize in the frontmatter (1–3 sentences).

## Steps

### 1. Understand the requirements

Read carefully. Identify key functionalities, constraints, objectives, and any nice-to-haves. Note ambiguities — ask about them as they come up, not at the end.

### 2. Explore the codebase

Navigate the parts of the codebase the requirements touch. Identify modules/components/services involved. Trace data structures and data flow via types. Note existing implementations that can be reused or need modification.

Also note **existing test infra** — test framework(s) in use, file/location conventions, mocking patterns, whether an e2e harness exists, whether the affected module currently has tests. Use this silently in context when writing each epic's **Testable outcomes** bullets. Do NOT surface it as its own section in the output — the grounding should show in how specific and realistic those bullets are.

_Why:_ the plan's quality is capped by how well you understand what's already there. Reusable pieces cut scope; hidden couplings cause missed risks; and testable outcomes divorced from the repo's actual test setup degrade into generic checklists.

### 3. Trace shared dependencies

For any code that will be modified, find ALL consumers — imports, calls, references. Verify the change won't break or unintentionally affect other features. If shared code is found, flag whether the change needs a parameter/flag to isolate behavior.

_Why:_ most implementation "surprises" live here. Surfacing them at analysis time turns them into explicit decisions rather than mid-implementation discoveries.

### 4. Ask as you go

Whenever requirements or codebase behavior is unclear, ask concise numbered questions. Do not batch to the end — early ambiguity corrupts everything downstream.

### 5. Write the document

Use the template below. Keep prose tight; sacrifice grammar for concision.

## Output template

Produce exactly this structure:

```markdown
---
requirements: <path/to/requirements.md> # use this field if requirements came from a file
requirements_summary: | # OR use this field if requirements were inline
  <1–3 sentence summary>
date: <yyyy-mm-dd>
---

# <Short title>

## Context

<1–2 sentences: what is being built and why>

## Codebase findings

- Relevant modules/files:
- Data flow:
- Reusable pieces:

## Shared dependencies & risks

- <Code being modified>: consumers at <paths>. Risk: <…>. Isolation: <flag / new function / none needed>

## Epics

Each epic is **self-contained** and ends with concrete, observable **testable outcomes**. Nice-to-haves go in the LAST epic.

### Epic 1: <name>

- **Scope:** <in / out>
- **Testable outcomes:**
  - <concrete, observable check — grounded in the repo's actual test setup>
  - <another check covering a different verification layer where it applies>
  - <manual / visual check if applicable, or `gap — no <X> harness` if the infra doesn't exist>
- **Approach:** <high-level direction only — NOT detailed tasks>

### Epic 2: <name>

…

### Epic N (nice-to-haves): <name>

<only if nice-to-haves were specified in requirements>

## Feasibility & complexity

- **Feasible:** yes / yes-with-caveats / no
- **Complexity:** low / medium / high
- **Main drivers:** <1–3 bullets — include the root-cause / urgency from the requirements, not just implementation risks>
```

### Writing testable outcomes

Each bullet under **Testable outcomes** is a concrete, observable check — not a generic category label. Cover the verification layers that actually apply to that epic (unit / integration / manual / visual); skip layers that don't. Ground bullets in the repo's real test setup (framework, conventions, the existing test pattern you'd mirror) — you discovered that in step 2 and should apply it silently. If a layer's harness doesn't exist, write `gap — no <X> harness` instead of inventing coverage.

_Why:_ the point of splitting work into epics is to pin each one to a concrete "done" signal. A vague outcome ("persistence works") gives the reader nothing to verify; a concrete one ("reload preserves preference; integration test asserts DOM class matches stored value on mount") is self-checking.

### Task granularity rule

Epics describe **direction and testable boundaries**, not implementation steps. Do NOT write "edit file X", "add function Y", "update test Z" inside an epic's approach — that level belongs in `/planning-research`. If you catch yourself naming files or functions inside an epic, pull back to the intent. (Testable-outcome bullets may reference existing test-file patterns to mirror, since that's grounding, not a task list.)

_Why:_ tech analysis decides _what_ work exists and _whether_ it's safe to do. Planning decides _how_ to execute it. Mixing the two bloats the analysis and forces rework when implementation details change.

### ASCII diagrams

Use sparingly for data flow, architecture, or UI layout — only when prose would be harder to follow.

## After writing

Tell the user where the file was saved and ask:

```
Analysis accurate? Next:

1. No. (please correct: …)
2. Yes → refine
3. Yes → hand off to `/planning-research`
```

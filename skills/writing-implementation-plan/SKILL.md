---
name: writing-implementation-plan
description: Use this skill to turn a tech-analysis doc into executable plan files — one plan file per epic, each broken into phased check-ins. Trigger after `conducting-tech-analysis` has produced a tech-analysis doc, or whenever the user says "plan this", "break down the epics", "write the implementation plan", "turn the analysis into tasks", or hands you a research/analysis doc and asks for next steps. Also use when revising an existing epic plan. This skill does NOT do feasibility research — that belongs in `conducting-tech-analysis`.
---

## Goal

Produce one **per-epic plan file** for every epic in a tech-analysis doc. Each plan file breaks the epic into ordered phases; each phase lists small tasks and ends with a testable check-in.

Plan files **do not repeat** the tech-analysis content. The analysis already states context, testable outcomes, and shared-dependency risks — the plan file links back to those sections instead of copying them. The plan's unique job is the **phase/task breakdown** and the mapping from each phase back to the analysis's testable outcomes.

Tech-analysis defaults to **one epic**; multi-epic analyses are the exception (natural milestone seams). One epic → one plan file is the common case.

**Default output path:** write each epic plan as a sibling of the tech-analysis doc.

```
<same folder as the tech-analysis doc>/epic-<N>-<slug>.md
```

If the tech-analysis doc lives at `exploration/<dd-mm-yyyy>-<short-description>/tech-analysis.md`, plan files land at `exploration/<dd-mm-yyyy>-<short-description>/epic-<N>-<slug>.md` — same folder, sibling of the analysis.

- `<N>` = epic number as it appears in the tech-analysis doc
- `<slug>` = short kebab-case slug of the epic name

If the tech-analysis doc path can't be determined (e.g., the user pasted the analysis inline), fall back to `exploration/<dd-mm-yyyy>-<short-description>/epic-<N>-<slug>.md` using today's date and a short slug of the work.

If the user asks to revise an existing epic plan, edit that file in place — don't create a new one.

## Why one file per epic (not one big plan)

Epics are already the tech-analysis unit of "self-contained work with its own testable outcomes." Splitting the plan along the same seam means:

- Each file is a focused unit an agent can pick up and execute end-to-end.
- Epics can be shipped, reviewed, or dropped independently.
- `working-on-plans` stays clean — one plan file at a time.

## Why phases inside each epic

Phases exist so the agent pauses for a **testable check-in** before continuing. Each phase is a chance to:

- Verify the expected result actually holds.
- Catch issues or hidden couplings the tech-analysis missed.
- Course-correct before sinking more time into later phases that depend on this one.

A plan without phase boundaries turns into one long burn-down with no natural stop to reassess. That's where agents drift from the spec.

## Prerequisite: a tech-analysis doc

This skill is the direct downstream of `conducting-tech-analysis`. It needs the epic structure (Scope / Testable outcomes / Approach) as input.

If the user hasn't provided a tech-analysis doc, ask for one. If they only have rough requirements, point them at `conducting-tech-analysis` first. Do NOT invent epics from bare requirements — the whole value of this skill is grounding phases in research that's already surfaced shared dependencies and risks.

## Steps

### 1. Read the tech-analysis doc end-to-end

Load the doc the user pointed at. You need:

- The **requirements** (frontmatter link or `requirements_summary`) — so phase tasks align with intent.
- Every **epic** — name, scope, testable outcomes, approach.
- **Shared dependencies & risks** — these often dictate phase ordering (e.g., "introduce isolation flag" must precede "modify shared helper").
- **Feasibility & complexity** — if the doc says "feasible with caveats," the plan must address each caveat explicitly.

### 2. Proceed — ask only when the analysis conflicts with the codebase

Default: plan every epic in the analysis and write the files. Don't ask for scope confirmation — the analysis already decided scope.

**Only ask questions when you discover an inconsistency between the analysis and the current codebase that would make implementation fail without a decision.** Concretely:

- The analysis references a file, module, or API that no longer exists (or was renamed).
- A shared dependency the analysis flagged for isolation has new consumers the analysis didn't account for.
- The analysis assumes an interface shape that the code has since changed.
- A testable outcome is no longer checkable — the harness it depended on was removed.

In those cases, ask concise numbered questions before writing, so the plan doesn't encode a broken assumption. **This should be rare** — a well-prepared tech-analysis is the whole reason this skill defers to it. If everything checks out, skip the question and write the files.

### 3. For each epic, design the phases

Phases are ordered by dependency — a phase may only depend on prior phases in the SAME epic (cross-epic dependencies belong in the tech-analysis, not here). Validate the order by asking: **"Can I demo this phase's expected result without completing later phases?"** If no, reorder.

**Phase 0 is setup + baseline health check.** Scope: environment setup, dependency installation, feature-flag scaffolding, fixture data, **and a pre-begin run of the existing unit tests** (plus lint/typecheck if the repo has them) to confirm the baseline is green before any code changes. For secrets/credentials, use placeholder values and tell the user how to obtain them (they replace with real values).

The health check matters because if tests fail mid-implementation, the agent needs to know whether it broke them or they were already broken. A green baseline turns every later failure into a real signal. Use the project's actual commands (discover from the tech-analysis, `package.json` scripts, or repo docs — don't invent `npm test` if the project uses `pnpm test:unit`).

Phase 0 is skippable only when there's genuinely nothing to set up AND the agent already knows the baseline is green (rare). When in doubt, include it.

**Distribute the epic's testable outcomes across phases.** Every testable outcome from the tech-analysis must appear as an acceptance check on some phase — that's the contract between analysis and plan. A phase may introduce its own intermediate checks too, but the epic-level outcomes cannot be dropped.

**Task granularity:** each task should be completable in a few hours. If a task is bigger, split it or add a pseudocode sketch so the shape is clear. Include code snippets or pseudocode for anything non-obvious — "add X to Y" is useless; "add field `status: 'pending' | 'done'` to the `Task` interface in `types/task.ts`; update the Zod schema in the same file" is useful.

### 4. Write each phase with a Review & adjust step

Every phase ends with an explicit Review & adjust step. This is not decoration — it's the skill's whole reason for splitting work into phases. The step tells the executing agent to pause, compare reality against the plan, and flag anything the analysis missed.

### 5. Write the files

Write one file per epic using the template below, as a sibling of the tech-analysis doc. The folder already exists (the analysis is in it); just add the new files. Use relative links (`./tech-analysis.md#…`) so the pointers keep working wherever the folder is moved.

### 6. Report back

Tell the user the folder path and list the files written. Ask:

```
Plans written. Next:

1. Revise a specific epic plan (which?)
2. Hand off to `working-on-plans` to start executing
3. Something's off — please correct: …
```

## Output template (per epic)

Use this structure for every epic plan file. Anywhere the tech-analysis already covers something, **link to its section** rather than restating it.

```markdown
---
title: <epic name>
epic: <N>
date: <dd-mm-yyyy>
tech_analysis: ./tech-analysis.md
---

# Epic <N>: <epic name>

**Source:** [tech-analysis.md § Epic <N>](./tech-analysis.md#epic-<N>-<slug>)
**Testable outcomes:** see [Epic <N> › Testable outcomes](./tech-analysis.md#epic-<N>-<slug>) — this plan maps each one to a phase below.
**Shared dependencies & risks:** see [tech-analysis.md § Shared dependencies & risks](./tech-analysis.md#shared-dependencies--risks).

## Phases

### Phase 0: Setup & baseline health check

- [ ] Task: <env var / dependency / flag scaffolding>
  - Placeholder: `FOO_API_KEY=<paste from 1password vault "foo">`
- [ ] Task: …
- [ ] Baseline health check — run existing checks and confirm they pass **before** touching any code:
  - `<unit test command — e.g., pnpm test:unit>` → expect green
  - `<lint command, if any>` → expect green
  - `<typecheck command, if any>` → expect green

**Expected result:** setup is ready (dev server boots, flag wired, etc.) AND baseline test/lint/typecheck runs are all green. Any pre-existing failure is recorded below with a decision (fix first / quarantine / proceed anyway).

**Review & adjust:** Confirm setup matches the local environment. Flag anything the analysis assumed that didn't apply, or setup it missed. If the baseline is NOT green, stop and surface the failures to the user before starting phase 1 — don't build on top of a red baseline.

### Phase 1: <name>

- [ ] Task: <small, concrete — few hours max>
  - <pseudocode / snippet if the shape isn't obvious>
- [ ] Task: …

**Expected result:** <a concrete, observable state — what a reviewer could check>

**Proves** (testable outcomes from the analysis this phase closes):

- [Epic <N> outcome: "<short quote of the bullet>"](./tech-analysis.md#epic-<N>-<slug>)
- …

**Review & adjust:** Before moving to phase 2, verify the expected result and linked outcomes hold. Surface anything you discovered that isn't in the tech-analysis — new dependencies, assumptions that turned out wrong, edge cases the analysis missed. If significant, pause and flag to the user before continuing.

### Phase 2: <name>

…

## Plan-only notes

<Only include if real. Things that belong in the plan but not the analysis: task-level assumptions, sequencing choices you made, open questions the executing agent should confirm. Do NOT duplicate anything from the analysis here.>
```

### What to link vs. what to write

- **Link, don't repeat:** context, epic scope, full list of testable outcomes, shared-dependency risks, feasibility caveats. All already in the analysis.
- **Write fresh:** phase breakdown, task lists, code snippets/pseudocode, expected results per phase, Review & adjust guidance, the phase→outcome mapping. The analysis has none of this.
- **Short quotes are fine** in the Proves block so the phase is readable standalone — just enough to identify the outcome, with the link carrying the detail.

## Rules

- **One file per epic.** Never merge epics into a single plan file, even if they're small.
- **Link to the analysis; don't duplicate it.** If the plan repeats context, outcomes, or risks, trim to a pointer.
- **Phase order respects dependencies.** Each phase must only depend on prior phases in the same file.
- **Every epic-level testable outcome is linked from some phase's Proves block.** If you can't place an outcome, the phases are wrong.
- **Every phase ends with a Review & adjust step.** No exceptions — that's the check-in contract.
- **Tasks are concrete and small.** If you write "implement feature X" as a task, split it.
- **Code snippets for non-obvious work.** Pseudocode is fine; vagueness is not.
- **Placeholder secrets, never real ones.** Point the user at where to fetch real values.

## Edge cases

- **Nice-to-haves epic from the tech-analysis:** plan it only if the user confirms in step 2. Often worth deferring.
- **Epic marked "feasible with caveats":** each caveat must appear as a task or acceptance check — usually in an early phase.
- **Revising an existing plan:** edit in place. Preserve completed-task checkboxes (`[x]`) and any phase the user has already executed — don't rewrite finished work.
- **Tech-analysis doc has no epic structure:** stop and ask the user to rerun `conducting-tech-analysis`. Don't try to bolt epics on after the fact — the value is epic-aligned testable outcomes, not arbitrary section splits.

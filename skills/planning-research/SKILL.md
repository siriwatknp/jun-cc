---
name: planning-research
description: Use this skill to create/revise implementation plan based on technical analysis/research documents by breaking down the work into testable tasks.
---

## Goal

A thorough planning document that outlines the implementation steps for engineers to follow.

Default a path to `.claude/tasks/<dd-mm-yyyy>-<short-description>/plan.md` in the current directory if not specified by the user.

If the user asked to revise an existing plan based, update the existing plan file instead.

The document should have front-matter metadata including:

```yaml
title: <short-description>
date: <dd-mm-yyyy>
reference: <link-to-technical-analysis-document>
```

## Rules

- The plan must be in phases, each phase must have a `[ ]` checkbox that indicates its completion status.
- Order phases by dependencies - each phase should only depend on prior phases
- If Phase X requires output from Phase Y, Phase Y must come first
- Validate order by asking: "Can I demo this phase without completing later phases?"
- Each phase must identify the scope of work clearly.
- Add "Expected Result" to each phase showing what's testable after completion
- Each task must be small enough to be completed within a few hours.
- Code snippets/pseudocode should be included to clarify complex tasks.
- Phase zero must include setup tasks such as environment setup, dependencies installation. For secrets or credentials, use placeholder values and guide on how to obtain them (user just need to replace them with actual values).

---
name: working-on-plans
description: Invoke this skill when asked to work on features/bugs based on a project plan or task list.
---

If the user provides a project plan or task list, follow the steps below to work on the tasks systematically.

## Step 1 - Gather Context

**Enter plan mode** to explore the codebase.

At this point, you should have a good understanding of the project structure and relevant files.
A good measurement of the context is around 20-30% of the total context limit depending on the complexity of the plan.

## Step 2 - Identify mismatches

The plan should be ahead of the current codebase. To identify mismatches:

- Roughly compare the plan or task list with the current codebase.
- If you find any mismatches, list them out clearly for the user to review before proceeding.

## Step 3 - Work on tasks

- For each task in the plan or task list, work on them one by one.
- If the plan is in phases, focus on the current phase only and let the user review once the phase is completed.

## Step 4

- Update the plan with check marks for completed tasks.
- Update any relevant documentation if needed.
- Ask the user if they want to commit the changes for the completed phase.

Finally, move on to the next phase or finish the work based on the user's response.

## Rules

- DO NOT made up or assume any details about the plan or task list. Always ask the user for clarification if needed.
- When encounter areas that you are not familiar with, DO NOT made things up. Use `@mcp__context7__get-library-docs` to find relevant documentation or search the web for specific version of the library.

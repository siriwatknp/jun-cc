---
name: conducting-tech-analysis
description: Use this skill to perform technical analysis based on the given requirements by exploring the codebase and related documentation to create a research document.
---

## Goal

A research document that outlines the technical analysis based on the given requirements. The research will be used for planning in the next steps of development.

Default a path to `.claude/tasks/<dd-mm-yyyy>-<short-description>/tech-analysis.md` in the current directory if not specified by the user.

## Steps

IMPORTANT: You MUST know the requirements before starting the analysis. If the requirements are not provided, ask the user to provide them.

1. **Understand the Requirements**

- Carefully read and analyze the provided requirements.
- Identify key functionalities, constraints, and objectives.

2. **Explore the Codebase**

- Navigate through the relevant parts of the codebase.
- Identify modules, components, or services that relate to the requirements.
- Understand the data structure through types and how data flows through the system.
- Take note of existing implementations that can be leveraged or need modification.

3. **Trace Shared Dependencies**

- For any code that will be modified, find ALL consumers/callers of that code.
- Search for imports, function calls, and references to identify every place that depends on the code.
- Verify the change won't break or unintentionally affect other features.
- If shared code is found, consider whether the change needs a parameter/flag to isolate the behavior.

4. **Ask clarifying questions**

- If any part of the requirements or codebase is unclear, ask questions to clarify.
- Ensure you have a complete understanding before proceeding.

5. **Document the Analysis**

- Summarize your findings and insights.
- Highlight potential challenges, dependencies, and design considerations.
- Provide recommendations or next steps based on the analysis.

## Output

- Technical Feasibility and the complexity of implementation should be clearly stated.
- The analysis should be concise and straight to the point.
- Sacrifice grammar for the sake of clarity and speed.
- Use bullet points, headings, and subheadings to organize the content effectively.
- Use ASCII art diagrams if necessary to illustrate complex concepts or UI related elements.

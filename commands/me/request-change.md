---
description: Receive a set of requirements and request a technical analysis based on them.
argument-hint: [requirements]
---

Do nothing if there is no requirements provided.

Save the requirements to `.claude/tasks/<dd-mm-yyyy>-<short-description>/requirements.md` in the current directory if not specified by the user.

The requirements mostly come as sentences or paragraphs, you need to extract the key points, aggregate them, and create a structured list of requirements.

Split the requirements to another folder if they are too many or too complex.

Finally, invoke technical analysis skill to perform the analysis based on the given requirements and write it down to the requirement file.

The output should look like this:

```md
# <requirement title>

...

---

## Technical Analysis

...
```

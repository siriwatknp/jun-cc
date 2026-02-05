> This is the reference guide for creating the python script.
> It's not used by the skill.

# Create StackBlitz Project

Create a StackBlitz project using the POST API.

## API Details

**Endpoint:** `POST https://stackblitz.com/run`

**Optional query params:**

- `file` - Set initial file to display (URL-encoded path, e.g., `?file=src%2FDemo.tsx`)

**Required fields:**

| Field                       | Description                                                              |
| --------------------------- | ------------------------------------------------------------------------ |
| `project[title]`            | Project name                                                             |
| `project[description]`      | Project summary                                                          |
| `project[files][FILE_PATH]` | File contents (one per file)                                             |
| `project[dependencies]`     | JSON string of dependencies                                              |
| `project[template]`         | `node`, `typescript`, `javascript`, `angular-cli`, or `create-react-app` |

**Template selection:**

- Use `node` for Vite projects (recommended for MUI sandboxes)
- `typescript` template expects `index.ts` at root, not compatible with Vite's `src/` structure

**Limitation:** Binary files not supported.

## Steps

1. Gather project requirements from user (or infer from context):
   - Template type
   - Dependencies
   - Files to include

2. Generate an HTML file that auto-submits the form:

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Open in StackBlitz</title>
  </head>
  <body>
    <form
      id="form"
      method="post"
      action="https://stackblitz.com/run"
      target="_self"
    >
      <input type="hidden" name="project[title]" value="{{TITLE}}" />
      <input
        type="hidden"
        name="project[description]"
        value="{{DESCRIPTION}}"
      />
      <input type="hidden" name="project[template]" value="{{TEMPLATE}}" />
      <input
        type="hidden"
        name="project[dependencies]"
        value="{{DEPENDENCIES_JSON}}"
      />
      <!-- One input per file -->
      <input
        type="hidden"
        name="project[files][{{FILE_PATH}}]"
        value="{{FILE_CONTENT}}"
      />
    </form>
    <script>
      document.getElementById("form").submit();
    </script>
  </body>
</html>
```

3. Write the HTML file to `/tmp/stackblitz-{{timestamp}}.html`

4. Open in browser:
   ```bash
   open /tmp/stackblitz-{{timestamp}}.html  # macOS
   ```

## Encoding Notes

- `project[dependencies]` must be JSON string with escaped quotes in HTML (`&quot;`)
- File contents must be HTML-escaped (use `&#10;` for newlines or keep as-is if no special chars)
- For complex file contents, use JavaScript to set values (recommended approach):

```html
<script>
    const files = {
      "src/Demo.tsx": `import Button from "@mui/material/Button";
  export default function Demo() {
    return <Button>Click</Button>;
  }
  `,
      "index.html": `<!DOCTYPE html>
  <html>
    <body>
      <div id="root"></div>
      <scr` + `ipt type="module" src="/src/index.tsx"></scr` + `ipt>
    </body>
  </html>
  `
    };

    for (const [path, content] of Object.entries(files)) {
      document.querySelector(\`input[name="project[files][\${path}]"]\`).value = content;
    }
    document.getElementById("form").submit();
</script>
```

## Critical Escape Rules

**IMPORTANT:** When file content contains `</script>`, it will prematurely close the outer script tag and break the HTML.

**Solution:** Split the closing script tag in template literals:

```js
// WRONG - breaks HTML parsing
"index.html": `<script src="app.js"></script>`

// CORRECT - split the tag
"index.html": `<scr` + `ipt src="app.js"></scr` + `ipt>`
```

This applies to any file content that may contain `</script>` (HTML files, inline scripts, etc.).

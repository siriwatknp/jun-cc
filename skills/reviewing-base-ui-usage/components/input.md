# Input

Import: `import { Input } from '@base-ui/react/input'`

## Structure

```jsx
<Input />
```

Not namespaced. Internally renders `Field.Control` -- prefer `Field.Control` directly for form fields.

## Gotchas

- Input is a thin wrapper around `Field.Control` -- use `Field.Control` inside `Field.Root` for forms
- `onValueChange` callback available for controlled usage (not just `onChange`)
- Must have an accessible label -- placeholder alone is insufficient

## Review Checklist

❌ `<Input.Root>` -- not namespaced, use `<Input>` directly
❌ `<Input>` without any label or `aria-label` -- needs accessible name
❌ `<Input>` inside `<Field.Root>` -- use `<Field.Control>` instead for proper integration
❌ `<Input placeholder="Email">` as sole label -- placeholder is not a label

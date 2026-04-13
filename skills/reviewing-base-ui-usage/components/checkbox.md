# Checkbox

Import: `import { Checkbox } from '@base-ui/react/checkbox'`

## Structure

```jsx
<Field.Root>
  <Checkbox.Root>
    <Checkbox.Indicator /> {/* visual check mark */}
  </Checkbox.Root>
  <Field.Label>Accept terms</Field.Label>
</Field.Root>
```

## Gotchas

- `onCheckedChange` callback -- not `onChange`
- `indeterminate` is a separate prop, not a value of `checked`
- Needs `Field.Root` + `Field.Label` or wrapping `<label>` for accessible labeling
- `name` goes on `Field.Root`, not on `Checkbox.Root` directly (for form integration)

## Review Checklist

❌ `<Checkbox.Root>` without any label -- needs `Field.Label` or wrapping `<label>`
❌ `<Checkbox.Root onChange={...}>` -- use `onCheckedChange`
❌ `<Checkbox.Root>` without `<Checkbox.Indicator>` -- no visual feedback
❌ `<Checkbox.Root name="terms">` -- put `name` on `Field.Root` for form integration
❌ Bare `<label>` next to `<Checkbox.Root>` -- use `Field.Root` + `Field.Label` for auto-association

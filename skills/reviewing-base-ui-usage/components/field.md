# Field

Import: `import { Field } from '@base-ui/react/field'`

## Structure

```jsx
<Field.Root name="email">
  <Field.Label>Email</Field.Label>
  <Field.Control type="email" required />
  <Field.Description>We'll never share it.</Field.Description>
  <Field.Error match="valueMissing">Required</Field.Error>
  <Field.Error match="typeMismatch">Invalid email</Field.Error>
</Field.Root>
```

For checkbox/radio groups:
```jsx
<Field.Item>
  <Checkbox.Root value="a">
    <Checkbox.Indicator />
  </Checkbox.Root>
  <Field.Label>Option A</Field.Label>
</Field.Item>
```

## Gotchas

- `name` goes on `Field.Root`, not on the control
- `Field.Control` replaces `<Input>` for form fields -- auto-connects label, description, errors
- `Field.Error match="..."` maps to HTML validation: `valueMissing`, `typeMismatch`, `tooShort`, `tooLong`, `patternMismatch`, `rangeUnderflow`, `rangeOverflow`, `stepMismatch`
- `Field.Validity` gives render-prop access to `ValidityState` for custom UI
- `Field.Item` wraps individual checkboxes/radios in groups (not `Field.Root`)
- `validationMode`: `'onSubmit'` (default), `'onBlur'`, `'onChange'`
- `validate` prop for async custom validation

## Review Checklist

❌ `<Field.Root>` without `<Field.Label>` -- needs accessible label
❌ `<input>` inside `<Field.Root>` -- use `<Field.Control>` for auto-connection
❌ `<Field.Error>` outside `<Field.Root>` -- must be inside Root
❌ `<Field.Root>` without `name` when inside `<Form>` -- name required for form submission
❌ `<Field.Root>` wrapping individual checkbox in a group -- use `<Field.Item>` instead
❌ `<Field.Control name="email">` -- put `name` on `<Field.Root>`, not Control

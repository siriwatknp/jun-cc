# Fieldset

Import: `import { Fieldset } from '@base-ui/react/fieldset'`

## Structure

```jsx
<Fieldset.Root>                                 {/* renders <fieldset> */}
  <Fieldset.Legend>Contact Info</Fieldset.Legend>{/* renders <legend> */}
  {/* Field components */}
</Fieldset.Root>
```

Merge with RadioGroup/CheckboxGroup:
```jsx
<Fieldset.Root render={<RadioGroup />}>
  <Fieldset.Legend>Size</Fieldset.Legend>
  <Field.Item>...</Field.Item>
</Fieldset.Root>
```

## Gotchas

- Parts are `Root` and `Legend` (not `Label` -- that's Field)
- `disabled` on Root disables all fields inside
- `render={<RadioGroup />}` or `render={<CheckboxGroup />}` merges Fieldset with group component
- Required for RadioGroup/CheckboxGroup accessibility

## Review Checklist

❌ `<Fieldset.Root>` without `<Fieldset.Legend>` -- Legend required for group accessibility
❌ `<Fieldset.Label>` -- wrong part, use `<Fieldset.Legend>`
❌ `<RadioGroup>` or `<CheckboxGroup>` without `<Fieldset.Root>` wrapper -- needs Fieldset for semantics
❌ `<Fieldset.Legend>` outside `<Fieldset.Root>` -- must be inside Root

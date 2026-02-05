# CheckboxGroup

Import: `import { CheckboxGroup } from '@base-ui/react/checkbox-group'`

## Structure

```jsx
<Fieldset.Root>
  <Fieldset.Legend>Select features</Fieldset.Legend>
  <CheckboxGroup>                               {/* not namespaced */}
    <Field.Item>
      <Checkbox.Root value="dark">             {/* value required */}
        <Checkbox.Indicator />
      </Checkbox.Root>
      <Field.Label>Dark mode</Field.Label>
    </Field.Item>
  </CheckboxGroup>
</Fieldset.Root>
```

## Gotchas

- Not namespaced -- use `<CheckboxGroup>` directly
- Needs `Fieldset.Root` + `Fieldset.Legend` wrapper for group accessibility
- Each checkbox needs `Field.Item` + `Field.Label` for individual labels
- Each `Checkbox.Root` needs `value` prop for group tracking
- `allValues` prop enables "select all" pattern

## Review Checklist

❌ `<CheckboxGroup.Root>` -- not namespaced, use `<CheckboxGroup>` directly
❌ `<CheckboxGroup>` without `<Fieldset.Root>` wrapper -- needs Fieldset for group labeling
❌ `<Checkbox.Root>` inside group without `value` -- required for group tracking
❌ `<Checkbox.Root>` without `<Field.Item>` wrapper -- needed for label association
❌ Bare `<label>` next to checkbox in group -- use `<Field.Item>` + `<Field.Label>`

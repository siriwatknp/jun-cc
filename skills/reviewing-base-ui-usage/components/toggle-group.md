# ToggleGroup

Import: `import { ToggleGroup } from '@base-ui/react/toggle-group'`

## Structure

```jsx
<ToggleGroup>                                   {/* not namespaced */}
  <Toggle value="bold">B</Toggle>              {/* value required */}
  <Toggle value="italic">I</Toggle>
  <Toggle value="underline">U</Toggle>
</ToggleGroup>
```

## Gotchas

- Not namespaced -- use `<ToggleGroup>` directly
- Uses `Toggle` from `'@base-ui/react/toggle'` as children (not `ToggleGroup.Item`)
- `toggleMultiple` prop for multi-select (default: single selection)
- Each `Toggle` needs `value` prop for group tracking

## Review Checklist

❌ `<ToggleGroup.Root>` -- not namespaced, use `<ToggleGroup>` directly
❌ `<ToggleGroup.Item value="a">` -- use `<Toggle value="a">` (separate import)
❌ `<Toggle>` inside group without `value` -- required for group identification
❌ `<ToggleGroup multiple>` -- prop is `toggleMultiple`

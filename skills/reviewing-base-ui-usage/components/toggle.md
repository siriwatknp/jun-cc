# Toggle

Import: `import { Toggle } from '@base-ui/react/toggle'`

## Structure

```jsx
<Toggle />
```

Not namespaced. When inside `ToggleGroup`, needs `value` prop.

## Gotchas

- `pressed` / `defaultPressed` for state (not `checked` or `selected`)
- `onPressedChange(pressed, eventDetails)` -- not `onChange`
- `value` prop required when used inside `ToggleGroup`
- Inside `ToggleGroup`, pressed state is managed by the group

## Review Checklist

❌ `<Toggle.Root>` -- not namespaced, use `<Toggle>` directly
❌ `<Toggle onChange={...}>` -- use `onPressedChange`
❌ `<Toggle checked={...}>` -- use `pressed` / `defaultPressed`
❌ `<Toggle>` inside `<ToggleGroup>` without `value` -- value required for group identification

## Disambiguation

| Toggle | Switch | Checkbox |
|--------|--------|----------|
| Toolbar/mode buttons | Settings on/off | Form selections |
| `pressed` state | `checked` state | `checked` state |
| `aria-pressed` | `role="switch"` | `role="checkbox"` |
| Not for forms | Immediate effect | Form submission |

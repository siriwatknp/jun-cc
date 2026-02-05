# Switch

Import: `import { Switch } from '@base-ui/react/switch'`

## Structure

```jsx
<Field.Root>
  <Field.Label>
    <Switch.Root>
      <Switch.Thumb />
    </Switch.Root>
    Enable notifications
  </Field.Label>
</Field.Root>
```

## Gotchas

- `onCheckedChange` callback -- not `onChange`
- `Switch.Thumb` required inside Root -- it's the sliding indicator
- Needs `Field.Label` for accessible labeling (wrapping label or Field.Root + Field.Label)

## Review Checklist

❌ `<Switch.Root>` without `<Switch.Thumb>` -- Thumb is the visual sliding indicator
❌ `<Switch.Root onChange={...}>` -- use `onCheckedChange`
❌ `<Switch.Root>` without label -- needs `Field.Label` or wrapping `<label>`
❌ Using Switch for form selection -- use Checkbox instead (Switch is for immediate effects)

## Disambiguation

| Switch | Checkbox | Toggle |
|--------|----------|--------|
| Immediate on/off | Form submission | Toolbar/mode buttons |
| `role="switch"` | `role="checkbox"` | `aria-pressed` |
| Settings toggles | Agree/select items | Formatting buttons |

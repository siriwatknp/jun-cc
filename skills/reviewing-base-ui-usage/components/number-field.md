# NumberField

Import: `import { NumberField } from '@base-ui/react/number-field'`

## Structure

```jsx
<NumberField.Root defaultValue={0} min={0} max={100}>
  <NumberField.ScrubArea>                       {/* optional drag-to-adjust */}
    <NumberField.ScrubAreaCursor />
    <label>Amount</label>
  </NumberField.ScrubArea>
  <NumberField.Group>                           {/* groups input + buttons */}
    <NumberField.Decrement>−</NumberField.Decrement>
    <NumberField.Input />
    <NumberField.Increment>+</NumberField.Increment>
  </NumberField.Group>
</NumberField.Root>
```

## Gotchas

- `NumberField.Group` required around Input + Increment/Decrement
- `format` prop accepts `Intl.NumberFormat` options for currency, percent, etc.
- `ScrubArea` + `ScrubAreaCursor` are optional (drag-to-adjust interaction)
- For form integration: wrap in `Field.Root` and use `Field.Control render={<NumberField.Input />}`

## Review Checklist

❌ `<NumberField.Input>` without `<NumberField.Group>` wrapper -- Group required
❌ `<input type="number">` inside NumberField -- use `<NumberField.Input>`
❌ `<NumberField.Increment>` / `<NumberField.Decrement>` outside Group -- must be inside Group
❌ `<NumberField.Root onChange={...}>` -- use `onValueChange`
❌ `<NumberField.ScrubAreaCursor>` without `<NumberField.ScrubArea>` -- ScrubAreaCursor must be inside ScrubArea

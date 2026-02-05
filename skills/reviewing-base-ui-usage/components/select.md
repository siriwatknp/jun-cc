# Select

Import: `import { Select } from '@base-ui/react/select'`

## Structure

```jsx
<Select.Root>
  <Select.Trigger>
    <Select.Value placeholder="Choose..." />
    <Select.Icon />
  </Select.Trigger>
  <Select.Portal>
    <Select.Backdrop />                         {/* optional */}
    <Select.Positioner>
      <Select.Popup>
        <Select.List>                           {/* required wrapper */}
          <Select.Group>
            <Select.GroupLabel>Category</Select.GroupLabel>
            <Select.Item value="a">
              <Select.ItemIndicator />          {/* check mark */}
              <Select.ItemText>Option A</Select.ItemText>
            </Select.Item>
          </Select.Group>
          <Select.Separator />
          <Select.ScrollUpArrow />
          <Select.ScrollDownArrow />
        </Select.List>
      </Select.Popup>
    </Select.Positioner>
  </Select.Portal>
</Select.Root>
```

## Gotchas

- `Select.List` required inside Popup -- wraps all items
- `Select.Value` displays selected text; `placeholder` prop for empty state
- `Select.ItemText` inside Item for display text; `Select.ItemIndicator` for check mark
- `alignItemWithTrigger` (default `true`) overlaps popup with trigger -- other positioning props (`side`, `align`) ignored unless set to `false`
- `Select.ScrollUpArrow` / `Select.ScrollDownArrow` for scroll indicators
- NOT filterable -- use Combobox/Autocomplete for large lists
- Supports `multiple` prop for multi-select
- `items` prop on Root for object value formatting

## Review Checklist

❌ `<Select.Popup>` without `<Select.Positioner>` -- Positioner required
❌ `<Select.Item>` directly in `<Select.Popup>` without `<Select.List>` -- List wrapper required
❌ `<Select.Option>` -- wrong part, use `<Select.Item>`
❌ `<Select.Content>` -- wrong part, use `<Select.Popup>`
❌ `<Select.Root>` with hundreds of items without filtering -- use Combobox instead
❌ `<Select.Trigger>` without `<Select.Value>` -- no display of selected value
❌ Using `side`/`align` props with `alignItemWithTrigger` still enabled -- set `alignItemWithTrigger={false}` first
❌ Missing `value` on `<Select.Item>` -- required for identification

## Disambiguation

| Select | Combobox |
|--------|----------|
| Click to pick from list | Type to filter + pick |
| No filtering | Built-in filtering |
| Small to medium lists | Any size list |
| `alignItemWithTrigger` overlay | Standard positioning |

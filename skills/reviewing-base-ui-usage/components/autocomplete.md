# Autocomplete

Import: `import { Autocomplete } from '@base-ui/react/autocomplete'`

## Structure

```jsx
<Autocomplete.Root>
  <Autocomplete.Value />                        {/* selected value display */}
  <Autocomplete.Input />
  <Autocomplete.Trigger>
    <Autocomplete.Icon />
  </Autocomplete.Trigger>
  <Autocomplete.Clear />
  <Autocomplete.Portal>
    <Autocomplete.Backdrop />
    <Autocomplete.Positioner>
      <Autocomplete.Popup>
        <Autocomplete.List>
          <Autocomplete.Group>
            <Autocomplete.GroupLabel>Suggestions</Autocomplete.GroupLabel>
            <Autocomplete.Item value="a">Option A</Autocomplete.Item>
          </Autocomplete.Group>
          <Autocomplete.Empty>No results</Autocomplete.Empty>
        </Autocomplete.List>
        <Autocomplete.Arrow />
      </Autocomplete.Popup>
    </Autocomplete.Positioner>
  </Autocomplete.Portal>
  <Autocomplete.Status />
</Autocomplete.Root>
```

## Gotchas

- Allows free-form text input (unlike Combobox which restricts to predefined items)
- `Autocomplete.useFilter()` hook for filtering (same API as Combobox)
- `Autocomplete.useFilteredItems()` for accessing filtered items
- `Autocomplete.Collection` for virtual lists, `Autocomplete.Row` for grid layout
- `mode` prop: `'list'`, `'both'`, `'inline'`, `'none'` (controls aria-autocomplete)
- `autoHighlight` / `keepHighlight` / `highlightItemOnHover` for highlight behavior
- `itemToStringValue` required when items are objects (not strings)
- For form integration: use `Field` with `nativeLabel={false}`

## Review Checklist

❌ `<Autocomplete.Popup>` without `<Autocomplete.Positioner>` -- Positioner required
❌ `<Autocomplete.Content>` -- wrong part, use `<Autocomplete.Popup>`
❌ `<Autocomplete.Option>` -- wrong part, use `<Autocomplete.Item>`
❌ Using Autocomplete when selection must be restricted -- use Combobox instead
❌ Missing `<Autocomplete.Empty>` -- no feedback when no matches found
❌ Object items without `itemToStringValue` -- required for display text
❌ Missing `<Autocomplete.Status>` -- screen readers won't announce result count

## Disambiguation

| Autocomplete | Combobox | Select |
|-------------|----------|--------|
| Free text + suggestions | Filter + restricted pick | Pick only |
| Allows arbitrary input | Items from list only | Items from list only |
| Search/suggest pattern | Dropdown filter pattern | Simple dropdown |

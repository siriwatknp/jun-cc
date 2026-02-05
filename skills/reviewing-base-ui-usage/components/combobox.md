# Combobox

Import: `import { Combobox } from '@base-ui/react/combobox'`

## Structure

```jsx
<Combobox.Root>
  <Combobox.Value />                            {/* selected value display */}
  <Combobox.Input />
  <Combobox.Trigger>                            {/* optional toggle button */}
    <Combobox.Icon />
  </Combobox.Trigger>
  <Combobox.Clear />                            {/* optional clear button */}
  <Combobox.Portal>
    <Combobox.Backdrop />
    <Combobox.Positioner>
      <Combobox.Popup>
        <Combobox.List>
          <Combobox.Group>
            <Combobox.GroupLabel>Category</Combobox.GroupLabel>
            <Combobox.Item value="a">
              <Combobox.ItemIndicator />
              Option A
            </Combobox.Item>
          </Combobox.Group>
          <Combobox.Separator />
          <Combobox.Empty>No results</Combobox.Empty>
        </Combobox.List>
        <Combobox.Arrow />
      </Combobox.Popup>
    </Combobox.Positioner>
  </Combobox.Portal>
  <Combobox.Status />                           {/* screen reader announcements */}
</Combobox.Root>
```

Multi-select with chips:
```jsx
<Combobox.Root multiple>
  <Combobox.Chips>
    {(chip) => (
      <Combobox.Chip key={chip.value}>
        {chip.label} <Combobox.ChipRemove />
      </Combobox.Chip>
    )}
  </Combobox.Chips>
  <Combobox.Input />
  ...
</Combobox.Root>
```

## Gotchas

- `Combobox.useFilter()` hook for filtering: returns `contains`, `startsWith`, `endsWith` (uses `Intl.Collator`)
- `Combobox.useFilteredItems()` hook for accessing filtered items list
- `Combobox.Collection` for virtual lists
- `Combobox.Row` for grid layout items
- NOT free-form input -- restricted to predefined items only (use Autocomplete for free text)
- `Combobox.Status` for screen reader result announcements
- `multiple` prop enables multi-select with chip support

## Review Checklist

❌ `<Combobox.Popup>` without `<Combobox.Positioner>` -- Positioner required
❌ `<Combobox.Item>` without `value` -- required for identification
❌ `<Combobox.Content>` -- wrong part, use `<Combobox.Popup>`
❌ `<Combobox.Option>` -- wrong part, use `<Combobox.Item>`
❌ Using Combobox for free-text search input -- use Autocomplete instead
❌ Missing `<Combobox.Empty>` -- no feedback when filter returns no results
❌ Custom filter without `Combobox.useFilter()` -- use the hook for proper locale-aware filtering
❌ Multi-select without `<Combobox.Chips>` -- no way to see/remove selected items

## Disambiguation

| Combobox | Autocomplete | Select |
|----------|-------------|--------|
| Filter + pick (restricted) | Filter + free text | Pick only (no filter) |
| Items from list only | Allows arbitrary input | Items from list only |
| Has Input + dropdown | Has Input + dropdown | Trigger + dropdown |

# Collapsible

Import: `import { Collapsible } from '@base-ui/react/collapsible'`

## Structure

```jsx
<Collapsible.Root>
  <Collapsible.Trigger>Show more</Collapsible.Trigger>
  <Collapsible.Panel>
    Content that can be shown/hidden
  </Collapsible.Panel>
</Collapsible.Root>
```

## Gotchas

- Single toggle section only -- use Accordion for multiple coordinated sections
- No Header wrapper needed (unlike Accordion)
- `open` / `defaultOpen` for state, `onOpenChange` for callback
- Panel height animated via `--collapsible-panel-height` CSS variable

## Review Checklist

❌ Multiple `<Collapsible.Panel>` inside one Root -- only one Panel per Root
❌ Using Collapsible for multiple coordinated sections -- use Accordion instead
❌ `<Collapsible.Header>` -- no Header part in Collapsible (that's Accordion)
❌ `<Collapsible.Root onToggle={...}>` -- use `onOpenChange`

## Disambiguation

| Collapsible | Accordion |
|-------------|-----------|
| Single section | Multiple sections |
| No Item/Header/value | Requires Item + Header + value |
| Independent toggle | Coordinated open/close |

# Accordion

Import: `import { Accordion } from '@base-ui/react/accordion'`

## Structure

```jsx
<Accordion.Root>
  <Accordion.Item value="section1">   {/* value required */}
    <Accordion.Header>                {/* required wrapper */}
      <Accordion.Trigger />
    </Accordion.Header>
    <Accordion.Panel />
  </Accordion.Item>
</Accordion.Root>
```

## Gotchas

- `multiple` prop to allow multiple open items (default: single open) -- NOT `openMultiple`
- `Accordion.Header` required around Trigger -- unlike Collapsible
- `value` on each Item is required, no auto-generated IDs

## Review Checklist

❌ `<Accordion.Item>` without `value` -- each Item needs unique value
❌ `<Accordion.Trigger>` not inside `<Accordion.Header>` -- Header wrapper required
❌ `<Accordion.Panel>` outside `<Accordion.Item>` -- must be inside its Item
❌ Using Accordion for single section -- use Collapsible instead
❌ `<Accordion.Root openMultiple>` -- prop is `multiple`

## Disambiguation

| Accordion | Collapsible |
|-----------|-------------|
| Multiple sections | Single section |
| Requires Item + Header + value | No Item/Header/value |
| `multiple` controls behavior | Always single toggle |

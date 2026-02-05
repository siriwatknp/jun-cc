# Tabs

Import: `import { Tabs } from '@base-ui/react/tabs'`

## Structure

```jsx
<Tabs.Root defaultValue="one">
  <Tabs.List>
    <Tabs.Tab value="one">Tab 1</Tabs.Tab>    {/* value required */}
    <Tabs.Tab value="two">Tab 2</Tabs.Tab>
    <Tabs.Indicator />                          {/* optional animated indicator */}
  </Tabs.List>
  <Tabs.Panel value="one">Content 1</Tabs.Panel>  {/* value must match Tab */}
  <Tabs.Panel value="two">Content 2</Tabs.Panel>
</Tabs.Root>
```

## Gotchas

- `value` required on both `Tabs.Tab` and `Tabs.Panel` -- must match
- `Tabs.Indicator` goes inside `Tabs.List`, auto-positions under selected tab
- Panels go outside `Tabs.List`, not inside

## Review Checklist

❌ `<Tabs.Tab>` without `value` -- each Tab needs unique value
❌ `<Tabs.Panel>` inside `<Tabs.List>` -- Panels go outside List
❌ `<Tabs.TabPanel>` -- wrong name, use `<Tabs.Panel>`
❌ Tab value `"one"` with Panel value `"1"` -- values must match exactly
❌ `<Tabs.Root>` without `defaultValue` or `value` -- no tab selected by default
❌ `<Tabs.Indicator>` outside `<Tabs.List>` -- must be inside List

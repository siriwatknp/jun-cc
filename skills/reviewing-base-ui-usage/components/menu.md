# Menu

Import: `import { Menu } from '@base-ui/react/menu'`

## Structure

```jsx
<Menu.Root>
  <Menu.Trigger>Actions</Menu.Trigger>
  <Menu.Portal>
    <Menu.Backdrop />                           {/* optional */}
    <Menu.Positioner>
      <Menu.Popup>
        <Menu.Item>Cut</Menu.Item>
        <Menu.LinkItem href="/help">Help</Menu.LinkItem>
        <Menu.Separator />
        <Menu.Group>
          <Menu.GroupLabel>Options</Menu.GroupLabel>
          <Menu.CheckboxItem>Show grid</Menu.CheckboxItem>
          <Menu.RadioGroup>
            <Menu.RadioItem value="sm">Small</Menu.RadioItem>
            <Menu.RadioItem value="lg">Large</Menu.RadioItem>
          </Menu.RadioGroup>
        </Menu.Group>
      </Menu.Popup>
    </Menu.Positioner>
  </Menu.Portal>
</Menu.Root>
```

Submenu:
```jsx
<Menu.SubmenuRoot>
  <Menu.SubmenuTrigger>More →</Menu.SubmenuTrigger>
  <Menu.Portal>
    <Menu.Positioner>
      <Menu.Popup>
        <Menu.Item>Sub item</Menu.Item>
      </Menu.Popup>
    </Menu.Positioner>
  </Menu.Portal>
</Menu.SubmenuRoot>
```

## Gotchas

- `Menu.Positioner` required between Portal and Popup
- `Menu.LinkItem` for navigation links (not `Menu.Item render={<a />}`)
- `Menu.SubmenuRoot` + `Menu.SubmenuTrigger` for nested menus -- each submenu needs its own Portal/Positioner
- `Menu.CheckboxItemIndicator` / `Menu.RadioItemIndicator` for visual check marks
- `Menu.createHandle()` for detached triggers / programmatic open
- Only top-level menus support detached triggers

## Review Checklist

❌ `<Menu.Popup>` without `<Menu.Positioner>` wrapper -- Positioner required
❌ `<Menu.Popup>` outside `<Menu.Portal>` -- must be inside Portal
❌ `<Menu.Item>` with `href` -- use `<Menu.LinkItem>` for navigation
❌ `<Menu.Item onClick={() => navigate(...)}>` for navigation -- use `<Menu.LinkItem>`
❌ Submenu using `<Menu.Root>` -- use `<Menu.SubmenuRoot>` + `<Menu.SubmenuTrigger>`
❌ `<Menu.Option>` -- wrong part name, use `<Menu.Item>`
❌ `<Menu.Content>` -- wrong part name, use `<Menu.Popup>`
❌ `<Menu.Arrow>` outside Popup -- must be inside Popup

## Disambiguation

| Menu | ContextMenu |
|------|-------------|
| Click trigger to open | Right-click trigger to open |
| `<Menu.Trigger>` is a button | `<ContextMenu.Trigger>` is a region |
| Has `Menu.Root` | Has `ContextMenu.Root` + `ContextMenu.Trigger` |

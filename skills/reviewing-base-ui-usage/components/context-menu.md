# ContextMenu

Import: `import { ContextMenu } from '@base-ui/react/context-menu'`

## Structure

```jsx
<ContextMenu.Root>
  <ContextMenu.Trigger>                         {/* right-click region */}
    <div>Right-click me</div>
  </ContextMenu.Trigger>
  <ContextMenu.Portal>
    <ContextMenu.Backdrop />
    <ContextMenu.Positioner>
      <ContextMenu.Popup>
        <ContextMenu.Item>Cut</ContextMenu.Item>
        <ContextMenu.LinkItem href="/help">Help</ContextMenu.LinkItem>
        <ContextMenu.Separator />
        <ContextMenu.Group>
          <ContextMenu.GroupLabel>View</ContextMenu.GroupLabel>
          <ContextMenu.CheckboxItem>Grid</ContextMenu.CheckboxItem>
        </ContextMenu.Group>
      </ContextMenu.Popup>
    </ContextMenu.Positioner>
  </ContextMenu.Portal>
</ContextMenu.Root>
```

Submenu:
```jsx
<ContextMenu.SubmenuRoot>
  <ContextMenu.SubmenuTrigger>More →</ContextMenu.SubmenuTrigger>
  <ContextMenu.Portal>
    <ContextMenu.Positioner>
      <ContextMenu.Popup>
        <ContextMenu.Item>Sub item</ContextMenu.Item>
      </ContextMenu.Popup>
    </ContextMenu.Positioner>
  </ContextMenu.Portal>
</ContextMenu.SubmenuRoot>
```

## Gotchas

- Same item parts as Menu: `Item`, `LinkItem`, `CheckboxItem`, `RadioItem`, `RadioGroup`, `Separator`, `Group`, `GroupLabel`, `CheckboxItemIndicator`, `RadioItemIndicator`
- `ContextMenu.Trigger` is a region (not a button) -- opens on right-click
- Submenu uses `ContextMenu.SubmenuRoot` + `ContextMenu.SubmenuTrigger`
- `Positioner` required between Portal and Popup

## Review Checklist

❌ `<ContextMenu.Popup>` without `<ContextMenu.Positioner>` -- Positioner required
❌ `<ContextMenu.Root>` without `<ContextMenu.Trigger>` -- Trigger defines the right-click region
❌ Using `<Menu.Root>` for right-click menu -- use `<ContextMenu.Root>`
❌ `<ContextMenu.Item>` with href -- use `<ContextMenu.LinkItem>`
❌ Submenu using `<ContextMenu.Root>` -- use `<ContextMenu.SubmenuRoot>`
❌ `<ContextMenu.Content>` -- wrong part, use `<ContextMenu.Popup>`

# Menubar

Import: `import { Menubar } from '@base-ui/react/menubar'`

## Structure

```jsx
<Menubar>                                       {/* not namespaced */}
  <Menu.Root>
    <Menu.Trigger>File</Menu.Trigger>
    <Menu.Portal>
      <Menu.Positioner>
        <Menu.Popup>
          <Menu.Item>New</Menu.Item>
          <Menu.Item>Open</Menu.Item>
          <Menu.Separator />
          <Menu.Item>Save</Menu.Item>
        </Menu.Popup>
      </Menu.Positioner>
    </Menu.Portal>
  </Menu.Root>
  <Menu.Root>
    <Menu.Trigger>Edit</Menu.Trigger>
    <Menu.Portal>
      <Menu.Positioner>
        <Menu.Popup>
          <Menu.Item>Undo</Menu.Item>
          <Menu.Item>Redo</Menu.Item>
        </Menu.Popup>
      </Menu.Positioner>
    </Menu.Portal>
  </Menu.Root>
</Menubar>
```

## Gotchas

- Not namespaced -- use `<Menubar>` directly
- Contains multiple `Menu.Root` as children
- Supports left/right arrow key navigation between menus
- Application menu bar pattern (not site navigation)

## Review Checklist

❌ `<Menubar.Root>` -- not namespaced, use `<Menubar>` directly
❌ `<Menubar>` with `NavigationMenu` children -- use `Menu.Root` children
❌ Using Menubar for site navigation -- use NavigationMenu instead
❌ Using separate `Menu.Root` components without Menubar wrapper -- loses arrow key navigation between menus

## Disambiguation

| Menubar | NavigationMenu | Menu |
|---------|----------------|------|
| App menu bar (File, Edit...) | Site nav with dropdowns | Single action menu |
| Multiple Menu.Root children | Links + Content | One menu |
| Arrow keys between menus | Hover-based | Click-based |

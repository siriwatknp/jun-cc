# NavigationMenu

Import: `import { NavigationMenu } from '@base-ui/react/navigation-menu'`

## Structure

```jsx
<NavigationMenu.Root>
  <NavigationMenu.List>
    <NavigationMenu.Item>
      <NavigationMenu.Trigger>
        Products
        <NavigationMenu.Icon />                 {/* dropdown indicator */}
      </NavigationMenu.Trigger>
      <NavigationMenu.Content>
        <NavigationMenu.Link href="/product-a">Product A</NavigationMenu.Link>
        <NavigationMenu.Link href="/product-b">Product B</NavigationMenu.Link>
      </NavigationMenu.Content>
    </NavigationMenu.Item>
    <NavigationMenu.Item>
      <NavigationMenu.Link href="/about">About</NavigationMenu.Link>
    </NavigationMenu.Item>
  </NavigationMenu.List>
  <NavigationMenu.Portal>
    <NavigationMenu.Backdrop />
    <NavigationMenu.Positioner>
      <NavigationMenu.Popup>
        <NavigationMenu.Viewport />             {/* renders active Content here */}
        <NavigationMenu.Arrow />
      </NavigationMenu.Popup>
    </NavigationMenu.Positioner>
  </NavigationMenu.Portal>
</NavigationMenu.Root>
```

## Gotchas

- `NavigationMenu.Link` for all navigation links (not `<a>` tags) -- use `render` prop for framework routing
- `NavigationMenu.Icon` for dropdown indicator arrow
- `NavigationMenu.Viewport` inside Popup renders the active `Content` from the triggered Item
- `NavigationMenu.Content` is defined inside `Item` but rendered in `Viewport` via portal
- Hover-based opening (not click)
- Nested submenus: nest another `NavigationMenu.Root` inside `Content`
- Large menus: use `max-height: var(--available-height)` + `overflow-y: auto`

## Review Checklist

❌ `<a>` tags inside NavigationMenu -- use `<NavigationMenu.Link>` (supports `render` for routing)
❌ `<NavigationMenu.Popup>` without `<NavigationMenu.Positioner>` -- Positioner required
❌ Missing `<NavigationMenu.Viewport>` inside Popup -- Content won't render
❌ `<NavigationMenu.Content>` outside `<NavigationMenu.Item>` -- must be defined inside Item
❌ Using Menu for site navigation -- use NavigationMenu instead (hover-based, link-focused)
❌ Missing `<NavigationMenu.Link>` with `render` prop for Next.js/React Router -- needed for client-side routing
❌ `<NavigationMenu.Content>` -- wrong part? No, it's correct; just ensure it's inside Item

## Disambiguation

| NavigationMenu | Menu | Menubar |
|----------------|------|---------|
| Site navigation | Action menu | App menu bar |
| Hover-based | Click-based | Click-based |
| Contains Links | Contains Items | Contains Menus |
| Mega menu support | Submenus | Multiple menus |

# Separator

Import: `import { Separator } from '@base-ui/react/separator'`

## Structure

```jsx
<Separator />
```

Not namespaced. Also re-exported as `Menu.Separator`, `Select.Separator`, `Toolbar.Separator`, etc.

## Gotchas

- `orientation` prop: `'horizontal'` (default) or `'vertical'`
- Inside Menu/Toolbar/Select, use the namespaced version (e.g. `<Menu.Separator />`)

## Review Checklist

❌ `<Separator.Root>` -- not namespaced, use `<Separator>` directly
❌ `<Separator>` inside `<Menu.Popup>` -- use `<Menu.Separator />` instead
❌ `<Separator>` inside `<Toolbar.Root>` -- use `<Toolbar.Separator />` instead

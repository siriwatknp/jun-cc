# Dialog

Import: `import { Dialog } from '@base-ui/react/dialog'`

## Structure

```jsx
<Dialog.Root>
  <Dialog.Trigger>Open</Dialog.Trigger>
  <Dialog.Portal>
    <Dialog.Backdrop />
    <Dialog.Viewport>                           {/* positioning container */}
      <Dialog.Popup>
        <Dialog.Title>Title</Dialog.Title>      {/* required for a11y */}
        <Dialog.Description>...</Dialog.Description>
        <Dialog.Close>Close</Dialog.Close>
      </Dialog.Popup>
    </Dialog.Viewport>
  </Dialog.Portal>
</Dialog.Root>
```

Detached trigger (trigger outside Root):
```jsx
const handle = Dialog.createHandle();
<Dialog.Trigger handle={handle}>Open</Dialog.Trigger>
<Dialog.Root handle={handle}>
  <Dialog.Portal>...</Dialog.Portal>
</Dialog.Root>
```

## Gotchas

- `Dialog.Viewport` is required between Portal and Popup -- it's the positioning container
- `Dialog.Title` required for accessibility (screen reader announcement)
- `Dialog.createHandle()` + `Handle` for programmatic open/close or detached triggers
- `payload` prop on Trigger to pass data; access via function-as-child on Root
- Nested dialogs: child Backdrop doesn't render; use `[data-nested-dialog-open]` selector
- `Popup` has `pointer-events: none` by default; inner content needs `pointer-events: auto`

## Review Checklist

❌ `<Dialog.Popup>` directly inside `<Dialog.Portal>` without `<Dialog.Viewport>` -- Viewport required
❌ `<Dialog.Root>` without `<Dialog.Title>` inside Popup -- required for accessibility
❌ `<Dialog.Popup>` outside `<Dialog.Portal>` -- Popup must be inside Portal
❌ `<Dialog.Backdrop>` outside `<Dialog.Portal>` -- must be inside Portal
❌ Using `<Dialog.Root open onClose={...}>` -- use `open` + `onOpenChange`
❌ Missing `<Dialog.Close>` and no other dismiss mechanism -- user can't close dialog
❌ `<Dialog.Content>` -- wrong part name, use `<Dialog.Popup>`
❌ Using AlertDialog when Dialog suffices -- AlertDialog prevents outside-click dismiss

## Disambiguation

| Dialog | AlertDialog |
|--------|-------------|
| General modal | Destructive confirmation |
| Dismissible by click outside | NOT dismissible by click outside |
| `role="dialog"` | `role="alertdialog"` |

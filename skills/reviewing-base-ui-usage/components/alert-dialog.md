# AlertDialog

Import: `import { AlertDialog } from '@base-ui/react/alert-dialog'`

## Structure

```jsx
<AlertDialog.Root>
  <AlertDialog.Trigger>Delete</AlertDialog.Trigger>
  <AlertDialog.Portal>
    <AlertDialog.Backdrop />
    <AlertDialog.Viewport>                      {/* positioning container */}
      <AlertDialog.Popup>
        <AlertDialog.Title>Confirm</AlertDialog.Title>
        <AlertDialog.Description>Are you sure?</AlertDialog.Description>
        <AlertDialog.Close>Cancel</AlertDialog.Close>
        <button onClick={handleDelete}>Delete</button>
      </AlertDialog.Popup>
    </AlertDialog.Viewport>
  </AlertDialog.Portal>
</AlertDialog.Root>
```

## Gotchas

- Same structure as Dialog but prevents dismiss by clicking outside (no `onClose` on backdrop click)
- `AlertDialog.Viewport` required between Portal and Popup
- `AlertDialog.Title` required for accessibility
- `AlertDialog.createHandle()` + `Handle` for detached triggers / programmatic control
- `payload` prop on Trigger; access via function-as-child on Root

## Review Checklist

❌ `<AlertDialog.Popup>` without `<AlertDialog.Viewport>` wrapper -- Viewport required
❌ `<AlertDialog.Root>` without `<AlertDialog.Title>` -- required for accessibility
❌ Using AlertDialog for non-destructive actions -- use Dialog instead
❌ `<AlertDialog.Content>` -- wrong part name, use `<AlertDialog.Popup>`
❌ Missing explicit confirm/cancel buttons -- AlertDialog needs clear action buttons
❌ `<AlertDialog.Popup>` outside Portal -- must be inside Portal

## Disambiguation

| AlertDialog | Dialog |
|-------------|--------|
| Destructive/critical confirmation | General modal |
| NOT dismissible by outside click | Dismissible by outside click |
| `role="alertdialog"` | `role="dialog"` |

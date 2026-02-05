# Toast

Import: `import { Toast } from '@base-ui/react/toast'`

## Structure

Setup (app root):
```jsx
const toastManager = Toast.createToastManager();

<Toast.Provider toastManager={toastManager}>
  {children}
  <Toast.Portal>
    <Toast.Viewport>
      {(toast) => (
        <Toast.Root toast={toast}>
          <Toast.Content>
            <Toast.Title>{toast.title}</Toast.Title>
            <Toast.Description>{toast.description}</Toast.Description>
            <Toast.Action>Undo</Toast.Action>
            <Toast.Close>×</Toast.Close>
          </Toast.Content>
        </Toast.Root>
      )}
    </Toast.Viewport>
  </Toast.Portal>
</Toast.Provider>
```

Usage:
```jsx
const toastManager = Toast.useToastManager();
toastManager.add({ title: 'Saved', description: 'Changes saved.' });
```

## Gotchas

- `Toast.createToastManager()` must be called outside components (module-level)
- `Toast.Provider` with `toastManager` prop required at app root
- `Toast.Viewport` renders toasts via function-as-child pattern
- `Toast.useToastManager()` hook returns `add`, `close`, `update`, `promise` methods
- `Toast.Content` wraps toast body content
- `Toast.Positioner` + `Toast.Arrow` available for anchored toasts
- CSS variables: `--toast-index`, `--toast-offset-y`, `--toast-swipe-movement-x/y`
- `data-swipe-ignore` on elements to prevent swipe-to-dismiss
- F6 key navigates to toast landmark region

## Review Checklist

❌ `Toast.createToastManager()` called inside a component -- must be module-level
❌ `<Toast.Root>` without `toast` prop -- required, comes from Viewport render function
❌ Missing `<Toast.Provider>` at app root -- required for toast system
❌ Missing `<Toast.Viewport>` -- required to render toasts
❌ `<Toast.Root>` outside `<Toast.Viewport>` -- must be rendered by Viewport's function-as-child
❌ Using `useState` to manage toast list -- use `Toast.useToastManager()` hook
❌ `<Toast.Content>` -- wrong? No, Content is correct; wraps toast body
❌ Missing `<Toast.Close>` -- no dismiss mechanism for user

# Form

Import: `import { Form } from '@base-ui/react/form'`

## Structure

```jsx
<Form onSubmit={handleSubmit}>                  {/* not namespaced */}
  <Field.Root name="email">
    <Field.Label>Email</Field.Label>
    <Field.Control type="email" required />
    <Field.Error />
  </Field.Root>
  <button type="submit">Submit</button>
</Form>
```

## Gotchas

- Not namespaced -- use `<Form>` directly
- `onFormSubmit` receives plain JS object of values (calls `preventDefault` automatically)
- `errors` / `onClearErrors` props for server-side validation error display
- Works with React Hook Form / TanStack Form via `errors` prop bridge

## Review Checklist

❌ `<Form.Root>` -- not namespaced, use `<Form>` directly
❌ `<form>` with Field components -- use `<Form>` for error integration
❌ `<Form>` without submit button -- no way to submit
❌ Server errors passed to individual fields instead of `<Form errors={...}>` -- use Form-level errors prop

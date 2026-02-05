# Button

Import: `import { Button } from '@base-ui/react/button'`

## Structure

```jsx
<Button />
```

Not namespaced -- use directly, not `Button.Root`.

## Gotchas

- `type="submit"` must be explicit -- unlike native `<button>`, Base UI Button does NOT default to submit
- `nativeButton={false}` required when using `render={<div />}` or non-button elements
- `focusableWhenDisabled` keeps focus on disabled button (useful for loading states)

## Review Checklist

❌ `<Button.Root>` -- not namespaced, use `<Button>` directly
❌ `<Button render={<div />}>` without `nativeButton={false}` -- required for non-button elements
❌ `<Button disabled>` in loading state without `focusableWhenDisabled` -- focus will be lost
❌ `<Button asChild>` -- Radix pattern, use `render` prop instead

# Toolbar

Import: `import { Toolbar } from '@base-ui/react/toolbar'`

## Structure

```jsx
<Toolbar.Root>
  <Toolbar.Group>
    <Toolbar.Button>Bold</Toolbar.Button>
    <Toolbar.Button>Italic</Toolbar.Button>
  </Toolbar.Group>
  <Toolbar.Separator />
  <Toolbar.Link href="/help">Help</Toolbar.Link>
  <Toolbar.Input placeholder="Search..." />     {/* use sparingly */}
</Toolbar.Root>
```

## Gotchas

- Use `Toolbar.Button` / `Toolbar.Link` / `Toolbar.Input` -- not raw HTML elements
- `Toolbar.Separator` -- not standalone `<Separator>`
- Arrow keys navigate items AND move text cursor in inputs -- avoid multiple inputs; place one input as last element
- For popup integration: `<Toolbar.Button render={<Menu.Trigger />}>` (pass Menu.Trigger to Toolbar.Button's render)

## Review Checklist

❌ `<button>` inside `<Toolbar.Root>` -- use `<Toolbar.Button>`
❌ `<a>` inside `<Toolbar.Root>` -- use `<Toolbar.Link>`
❌ `<Separator>` inside `<Toolbar.Root>` -- use `<Toolbar.Separator>`
❌ `<input>` inside `<Toolbar.Root>` -- use `<Toolbar.Input>`
❌ Multiple `<Toolbar.Input>` -- arrow keys conflict with text cursor; use one input max, as last element

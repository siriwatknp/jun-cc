# Avatar

Import: `import { Avatar } from '@base-ui/react/avatar'`

## Structure

```jsx
<Avatar.Root>
  <Avatar.Image src="/photo.jpg" alt="User name" />
  <Avatar.Fallback>JD</Avatar.Fallback>        {/* shown on load error or while loading */}
</Avatar.Root>
```

## Gotchas

- Fallback `delay` prop (in ms) prevents flash for fast-loading images -- not `delayMs`
- Image renders only when loaded; Fallback renders only when NOT loaded (or after delay)
- `onLoadingStatusChange` on Image for tracking load state

## Review Checklist

❌ `<Avatar.Image>` without `alt` -- needs accessible alt text
❌ `<Avatar.Image>` without sibling `<Avatar.Fallback>` -- no fallback for load errors
❌ `<Avatar.Fallback>` outside `<Avatar.Root>` -- must be inside Root
❌ `<Avatar.Fallback delayMs={500}>` -- prop is `delay`, not `delayMs`

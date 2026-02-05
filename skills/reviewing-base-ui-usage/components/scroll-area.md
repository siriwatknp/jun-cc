# ScrollArea

Import: `import { ScrollArea } from '@base-ui/react/scroll-area'`

## Structure

```jsx
<ScrollArea.Root>
  <ScrollArea.Viewport>
    <ScrollArea.Content>                        {/* optional, for auto-sizing */}
      {/* scrollable content */}
    </ScrollArea.Content>
  </ScrollArea.Viewport>
  <ScrollArea.Scrollbar orientation="vertical"> {/* orientation required */}
    <ScrollArea.Thumb />
  </ScrollArea.Scrollbar>
  <ScrollArea.Scrollbar orientation="horizontal">
    <ScrollArea.Thumb />
  </ScrollArea.Scrollbar>
  <ScrollArea.Corner />                         {/* when both scrollbars visible */}
</ScrollArea.Root>
```

## Gotchas

- `Viewport` is required -- content must be inside it
- `orientation` required on each `Scrollbar`
- `Thumb` must be inside `Scrollbar`
- `Corner` prevents overlap when both scrollbars are visible
- CSS overflow variables (`--scroll-area-overflow-y-start/end`) don't inherit -- set `inherit` manually on children

## Review Checklist

❌ Content directly in `<ScrollArea.Root>` without `<ScrollArea.Viewport>` -- Viewport required
❌ `<ScrollArea.Scrollbar>` without `orientation` -- must specify `"vertical"` or `"horizontal"`
❌ `<ScrollArea.Thumb>` outside `<ScrollArea.Scrollbar>` -- must be inside Scrollbar
❌ Both scrollbars without `<ScrollArea.Corner>` -- Corner prevents visual overlap
❌ `<ScrollArea.Scrollbar orientation="vertical">` without child `<ScrollArea.Thumb>` -- Thumb required

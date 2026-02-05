# PreviewCard

Import: `import { PreviewCard } from '@base-ui/react/preview-card'`

## Structure

```jsx
<PreviewCard.Root>
  <PreviewCard.Trigger href="/profile">         {/* renders as link */}
    @username
  </PreviewCard.Trigger>
  <PreviewCard.Portal>
    <PreviewCard.Backdrop />                    {/* optional */}
    <PreviewCard.Positioner>
      <PreviewCard.Popup>
        <PreviewCard.Viewport>                  {/* optional, direction-aware animations */}
          <PreviewCard.Arrow />
          <img src="/avatar.jpg" />
          <p>Profile info...</p>
        </PreviewCard.Viewport>
      </PreviewCard.Popup>
    </PreviewCard.Positioner>
  </PreviewCard.Portal>
</PreviewCard.Root>
```

## Gotchas

- Hover-triggered -- opens on hover like Tooltip but contains rich content
- `PreviewCard.Trigger` renders as a link (`href` required)
- `PreviewCard.Viewport` enables direction-aware animations (`data-activation-direction`)
- `PreviewCard.createHandle()` + `Handle` for programmatic control
- `payload` prop on Trigger; access via function-as-child on Root
- Can contain interactive content (unlike Tooltip)

## Review Checklist

❌ `<PreviewCard.Popup>` without `<PreviewCard.Positioner>` -- Positioner required
❌ `<PreviewCard.Trigger>` without `href` -- Trigger renders as link, needs href
❌ `<PreviewCard.Content>` -- wrong part, use `<PreviewCard.Popup>`
❌ Using PreviewCard for non-interactive text hints -- use Tooltip instead
❌ Using PreviewCard for click-triggered overlay -- use Popover instead
❌ `<PreviewCard.Arrow>` outside Popup -- must be inside Popup

## Disambiguation

| PreviewCard | Tooltip | Popover |
|-------------|---------|---------|
| Hover + rich preview | Hover + text only | Click-triggered |
| Link trigger | Any trigger | Button trigger |
| Rich content OK | Text only | Interactive content |
| Auto-dismiss on leave | Auto-dismiss | Manual close |

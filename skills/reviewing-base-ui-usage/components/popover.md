# Popover

Import: `import { Popover } from '@base-ui/react/popover'`

## Structure

```jsx
<Popover.Root>
  <Popover.Trigger>Info</Popover.Trigger>
  <Popover.Portal>
    <Popover.Backdrop />                        {/* optional */}
    <Popover.Positioner>
      <Popover.Popup>
        <Popover.Viewport>                      {/* optional, for direction-aware animations */}
          <Popover.Arrow />
          <Popover.Title>Details</Popover.Title>
          <Popover.Description>...</Popover.Description>
          <Popover.Close>×</Popover.Close>
        </Popover.Viewport>
      </Popover.Popup>
    </Popover.Positioner>
  </Popover.Portal>
</Popover.Root>
```

## Gotchas

- `Popover.Positioner` required between Portal and Popup
- `Popover.Viewport` enables direction-aware animations (`data-activation-direction`)
- `Popover.createHandle()` + `Handle` for detached triggers / programmatic control
- `openOnHover` + `delay` on Trigger for hover behavior
- `payload` prop on Trigger; access via function-as-child on Root
- Contains interactive content (unlike Tooltip)

## Review Checklist

❌ `<Popover.Popup>` without `<Popover.Positioner>` -- Positioner required
❌ `<Popover.Popup>` outside `<Popover.Portal>` -- must be inside Portal
❌ `<Popover.Content>` -- wrong part, use `<Popover.Popup>`
❌ Using Popover for non-interactive text hints -- use Tooltip instead
❌ Using Tooltip for interactive content -- use Popover instead
❌ `<Popover.Arrow>` outside Popup -- must be inside Popup

## Disambiguation

| Popover | Tooltip | PreviewCard |
|---------|---------|-------------|
| Click-triggered (default) | Hover/focus text | Hover-triggered rich preview |
| Interactive content | Non-interactive text | Interactive content |
| Has Close button | Auto-dismiss | Auto-dismiss + hover |
| `openOnHover` optional | Always hover | Always hover |

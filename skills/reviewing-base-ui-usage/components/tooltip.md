# Tooltip

Import: `import { Tooltip } from '@base-ui/react/tooltip'`

## Structure

```jsx
<Tooltip.Provider>                              {/* optional, coordinates multiple tooltips */}
  <Tooltip.Root>
    <Tooltip.Trigger aria-label="Settings">     {/* aria-label should match tooltip text */}
      <SettingsIcon />
    </Tooltip.Trigger>
    <Tooltip.Portal>
      <Tooltip.Positioner>
        <Tooltip.Popup>
          <Tooltip.Viewport>                    {/* optional, direction-aware animations */}
            Settings
          </Tooltip.Viewport>
          <Tooltip.Arrow />
        </Tooltip.Popup>
      </Tooltip.Positioner>
    </Tooltip.Portal>
  </Tooltip.Root>
</Tooltip.Provider>
```

## Gotchas

- Tooltip is supplementary only -- NOT accessible on touch devices
- Trigger MUST have `aria-label` matching tooltip content (tooltip is visual-only)
- `Tooltip.Provider` optional but coordinates delay across multiple tooltips
- `Tooltip.Viewport` enables direction-aware animations (`data-activation-direction`)
- `Tooltip.createHandle()` + `Handle` for programmatic control
- Non-interactive content only -- use Popover for interactive content

## Review Checklist

❌ `<Tooltip.Popup>` without `<Tooltip.Positioner>` -- Positioner required
❌ `<Tooltip.Trigger>` without `aria-label` -- tooltip text not accessible on touch/screen readers
❌ Interactive content inside Tooltip (buttons, links) -- use Popover instead
❌ `<Tooltip.Content>` -- wrong part, use `<Tooltip.Popup>`
❌ Tooltip as sole source of critical information -- not accessible on touch devices
❌ `<Tooltip.Arrow>` outside Popup -- must be inside Popup
❌ Missing `<Tooltip.Portal>` -- Popup should be in Portal for z-index

## Disambiguation

| Tooltip | Popover | PreviewCard |
|---------|---------|-------------|
| Hover/focus text label | Click + interactive | Hover + rich preview |
| Non-interactive | Buttons/links OK | Can contain links |
| `aria-label` required | Self-contained | Link trigger required |
| Disabled on touch | Works on touch | Works on touch |

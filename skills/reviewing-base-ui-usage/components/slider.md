# Slider

Import: `import { Slider } from '@base-ui/react/slider'`

## Structure

```jsx
<Slider.Root defaultValue={50}>
  <Slider.Value />                              {/* optional value display */}
  <Slider.Control>                              {/* interactive area */}
    <Slider.Track>
      <Slider.Indicator />                      {/* filled portion */}
      <Slider.Thumb />
    </Slider.Track>
  </Slider.Control>
</Slider.Root>
```

Range slider:
```jsx
<Slider.Root defaultValue={[20, 80]}>
  <Slider.Control>
    <Slider.Track>
      <Slider.Indicator />
      <Slider.Thumb index={0} />                {/* index required for SSR */}
      <Slider.Thumb index={1} />
    </Slider.Track>
  </Slider.Control>
</Slider.Root>
```

## Gotchas

- `Slider.Control` is required wrapper around Track -- handles pointer events
- `Slider.Thumb` must be inside `Slider.Track`
- Range slider: each Thumb needs `index` prop matching its value position (for SSR)
- `thumbAlignment="edge"` prevents thumb overflow past Control edges
- `onValueChange` fires during drag, `onValueChangeComplete` fires on release

## Review Checklist

❌ `<Slider.Track>` without `<Slider.Control>` wrapper -- Control required
❌ `<Slider.Thumb>` outside `<Slider.Track>` -- must be inside Track
❌ Range slider with `<Slider.Thumb />` without `index` -- each Thumb needs index for SSR
❌ `<Slider.Output>` -- wrong part name, use `<Slider.Value>`
❌ `<Slider.Root onChange={...}>` -- use `onValueChange`
❌ Missing `<Slider.Thumb>` entirely -- no drag handle rendered

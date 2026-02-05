# Meter

Import: `import { Meter } from '@base-ui/react/meter'`

## Structure

```jsx
<Meter.Root value={60} low={25} high={75} optimum={50}>
  <Meter.Label>Disk usage</Meter.Label>
  <Meter.Value />                               {/* displays formatted value */}
  <Meter.Track>
    <Meter.Indicator />                         {/* filled portion */}
  </Meter.Track>
</Meter.Root>
```

## Gotchas

- Has `low` / `high` / `optimum` threshold props -- determines `data-state` for styling
- `Indicator` must be inside `Track`
- CSS variable `--meter-value` available for styling (0-100)
- NOT for task completion -- use Progress instead

## Review Checklist

❌ `<Meter.Indicator>` outside `<Meter.Track>` -- must be inside Track
❌ Using Meter for file upload / loading progress -- use Progress instead
❌ `<Meter.Root>` without `value` -- value is required (Meter is always determinate)
❌ `<Meter.Bar>` -- wrong part name, use `<Meter.Indicator>`

## Disambiguation

| Meter | Progress |
|-------|----------|
| Static measurement | Task completion |
| Has low/high/optimum | No thresholds |
| Disk space, battery | File upload, loading |
| May fluctuate | Moves toward done |

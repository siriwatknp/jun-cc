# Progress

Import: `import { Progress } from '@base-ui/react/progress'`

## Structure

```jsx
<Progress.Root value={60}>
  <Progress.Label>Loading...</Progress.Label>
  <Progress.Value />                            {/* displays formatted value */}
  <Progress.Track>
    <Progress.Indicator />                      {/* filled portion */}
  </Progress.Track>
</Progress.Root>
```

## Gotchas

- `value={null}` for indeterminate progress (unknown completion)
- `Indicator` must be inside `Track`
- CSS variable `--progress-value` available for styling (0-100)
- `getValueLabel` for custom value formatting

## Review Checklist

❌ `<Progress.Indicator>` outside `<Progress.Track>` -- must be inside Track
❌ `<Progress.Root>` without `value` when determinate is intended -- defaults to indeterminate
❌ Using Progress for static measurements (disk space, battery) -- use Meter instead
❌ `<Progress.Bar>` -- wrong part name, use `<Progress.Indicator>`

## Disambiguation

| Progress | Meter |
|----------|-------|
| Task completion | Static measurement |
| Moves toward done | May fluctuate |
| No thresholds | Has low/high/optimum |
| File upload, loading | Disk space, battery |

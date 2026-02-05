# MUI X Charts Skill

## Core Guidelines

### BarChart

Always start with this configuration to remove the default margin and axis:

```tsx
import { BarChart } from "@mui/x-charts/BarChart";

<BarChart
  // ...
  margin={{
    left: 0,
    right: 0,
    top: 0,
    bottom: 0,
  }}
  xAxis={[
    {
      height: 0, // minimum 28 to display the label
      position: "none", // 'top' or 'bottom'
    },
  ]}
  yAxis={[
    {
      width: 0, // minimum 28 to display the label
      position: "none", // 'left' or 'right'
    },
  ]}
/>;
```

Then, you can adjust the spacing/padding of the chart to match the design analysis.

### PieChart

Common use cases:

- Hide the legend by using `slotProps.legend.sx.display = "none"`
- Format the value with `valueFormatter: (params) => `${params.value}%``
- Assign arc colors with `colors` prop with array of strings
- Remove spacing around the chart by setting `margin` to `{ left: 0, right: 0, top: 0, bottom: 0 }`

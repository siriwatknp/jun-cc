# RadioGroup & Radio

Import:
```
import { RadioGroup } from '@base-ui/react/radio-group'
import { Radio } from '@base-ui/react/radio'
```

## Structure

```jsx
<Fieldset.Root>
  <Fieldset.Legend>Choose size</Fieldset.Legend>
  <RadioGroup>                                  {/* not namespaced */}
    <Field.Item>
      <Radio.Root value="small">               {/* value required */}
        <Radio.Indicator />
      </Radio.Root>
      <Field.Label>Small</Field.Label>
    </Field.Item>
    <Field.Item>
      <Radio.Root value="large">
        <Radio.Indicator />
      </Radio.Root>
      <Field.Label>Large</Field.Label>
    </Field.Item>
  </RadioGroup>
</Fieldset.Root>
```

## Gotchas

- Two separate imports: `RadioGroup` and `Radio`
- `RadioGroup` is not namespaced -- not `RadioGroup.Root`
- Needs `Fieldset.Root` + `Fieldset.Legend` wrapper for group accessibility
- Each radio needs `Field.Item` + `Field.Label` for labeling
- `value` required on each `Radio.Root`
- Alternative: `<Fieldset.Root render={<RadioGroup />}>` merges Fieldset + RadioGroup

## Review Checklist

❌ `<RadioGroup.Root>` -- not namespaced, use `<RadioGroup>` directly
❌ `<RadioGroup.Item>` -- wrong, use `<Radio.Root>` (separate import)
❌ `<RadioGroup>` without `<Fieldset.Root>` -- needs Fieldset for group labeling
❌ `<Radio.Root>` without `value` -- required for identification
❌ `<Radio.Root>` without `<Field.Item>` + `<Field.Label>` -- needs accessible label
❌ `<Radio.Root>` without `<Radio.Indicator>` -- no visual feedback

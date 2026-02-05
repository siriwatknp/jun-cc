# Base UI Forms Integration

Guide for building forms with Base UI and integrating with form libraries.

## Field Component Structure

```tsx
<Field.Root name="fieldName">
  <Field.Label>Label text</Field.Label>
  <Field.Description>Help text</Field.Description>
  <Field.Control />
  <Field.Error />
</Field.Root>
```

### Field.Root Props

- `name` - Field name for form submission
- `invalid` - Mark field as invalid (boolean)
- `touched` - Mark field as touched (boolean)
- `dirty` - Mark field as dirty (boolean)
- `validationMode` - When to validate: `'onSubmit'` | `'onBlur'` | `'onChange'`
- `validationDebounceTime` - Debounce validation (ms)
- `validate` - Custom validation function

### Labeling Patterns

#### Standard Label

```tsx
<Field.Root>
  <Field.Label>Username</Field.Label>
  <Field.Control />
</Field.Root>
```

#### Implicit Label (Checkbox, Switch, Radio)

```tsx
<Field.Root>
  <Field.Label>
    <Switch.Root />
    Enable notifications
  </Field.Label>
</Field.Root>
```

#### Group Labeling (Fieldset)

```tsx
<Fieldset.Root render={<RadioGroup />}>
  <Fieldset.Legend>Select option</Fieldset.Legend>
  <Radio.Root value="a" />
  <Radio.Root value="b" />
</Fieldset.Root>
```

#### Group Item Labeling

```tsx
<Fieldset.Root render={<CheckboxGroup />}>
  <Fieldset.Legend>Select features</Fieldset.Legend>
  <Field.Item>
    <Checkbox.Root value="dark" />
    <Field.Label>Dark mode</Field.Label>
  </Field.Item>
  <Field.Item>
    <Checkbox.Root value="compact" />
    <Field.Label>Compact view</Field.Label>
  </Field.Item>
</Fieldset.Root>
```

## Validation

### Constraint Validation

Use native HTML validation attributes:

```tsx
<Field.Root name="email">
  <Field.Control
    type="email"
    required
    pattern="[a-z]+@[a-z]+\.[a-z]+"
    minLength={5}
    maxLength={100}
  />
  <Field.Error />
</Field.Root>
```

### Custom Validation

```tsx
<Field.Root
  name="username"
  validationMode="onChange"
  validationDebounceTime={300}
  validate={async (value) => {
    if (value === 'admin') {
      return 'Reserved username';
    }
    const available = await checkUsername(value);
    if (!available) {
      return `${value} is already taken`;
    }
    return null; // valid
  }}
>
  <Field.Control />
  <Field.Error />
</Field.Root>
```

### Custom Error Messages

```tsx
<Field.Error match="valueMissing">This field is required</Field.Error>
<Field.Error match="typeMismatch">Invalid email format</Field.Error>
<Field.Error match="tooShort">Too short</Field.Error>
<Field.Error match="patternMismatch">Invalid format</Field.Error>
```

## Form Component

```tsx
<Form
  onSubmit={(event) => {
    event.preventDefault();
    const formData = new FormData(event.currentTarget);
    // Process formData
  }}
>
  <Field.Root name="username">
    <Field.Control />
  </Field.Root>
</Form>
```

Or use `onFormSubmit` for convenience:

```tsx
<Form
  onFormSubmit={(values) => {
    // values is a plain object
    console.log(values.username);
  }}
>
```

### Server-side Validation

```tsx
const [errors, setErrors] = useState();

<Form
  errors={errors}
  onSubmit={async (event) => {
    event.preventDefault();
    const response = await submitToServer(/* data */);
    setErrors(response.errors);
  }}
>
  <Field.Root name="email">
    <Field.Control />
    <Field.Error />
  </Field.Root>
</Form>
```

## React Hook Form Integration

```tsx
import { useForm, Controller } from 'react-hook-form';
import { Field } from '@base-ui/react/field';

function MyForm() {
  const { control, handleSubmit } = useForm({
    defaultValues: { username: '' }
  });

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <Controller
        name="username"
        control={control}
        rules={{
          required: 'Required',
          minLength: { value: 3, message: 'Too short' }
        }}
        render={({
          field: { name, ref, value, onBlur, onChange },
          fieldState: { invalid, isTouched, isDirty, error }
        }) => (
          <Field.Root
            name={name}
            invalid={invalid}
            touched={isTouched}
            dirty={isDirty}
          >
            <Field.Label>Username</Field.Label>
            <Field.Control
              value={value}
              onBlur={onBlur}
              onValueChange={onChange}
              ref={ref}
            />
            <Field.Error match={!!error}>
              {error?.message}
            </Field.Error>
          </Field.Root>
        )}
      />
    </form>
  );
}
```

## TanStack Form Integration

```tsx
import { useForm } from '@tanstack/react-form';
import { Field } from '@base-ui/react/field';

function MyForm() {
  const form = useForm({
    defaultValues: { username: '' },
    onSubmit: async ({ value }) => {
      await submitData(value);
    }
  });

  return (
    <form onSubmit={(e) => { e.preventDefault(); form.handleSubmit(); }}>
      <form.Field
        name="username"
        children={(field) => (
          <Field.Root
            name={field.name}
            invalid={!field.state.meta.isValid}
            dirty={field.state.meta.isDirty}
            touched={field.state.meta.isTouched}
          >
            <Field.Label>Username</Field.Label>
            <Field.Control
              value={field.state.value}
              onValueChange={field.handleChange}
              onBlur={field.handleBlur}
            />
            <Field.Error match={!field.state.meta.isValid}>
              {field.state.meta.errors.join(', ')}
            </Field.Error>
          </Field.Root>
        )}
      />
    </form>
  );
}
```

## Common Review Points

### Accessibility Issues to Flag

1. **Missing Field.Label:**
```tsx
// ❌ No accessible label
<Field.Root>
  <Field.Control />
</Field.Root>

// ✅ Has label
<Field.Root>
  <Field.Label>Username</Field.Label>
  <Field.Control />
</Field.Root>
```

2. **Missing Fieldset for groups:**
```tsx
// ❌ Group without legend
<RadioGroup>
  <Radio.Root value="a" />
  <Radio.Root value="b" />
</RadioGroup>

// ✅ Proper fieldset structure
<Fieldset.Root render={<RadioGroup />}>
  <Fieldset.Legend>Select option</Fieldset.Legend>
  <Radio.Root value="a" />
  <Radio.Root value="b" />
</Fieldset.Root>
```

3. **Missing Field.Item for group items:**
```tsx
// ❌ Checkboxes without individual labels
<CheckboxGroup>
  <Checkbox.Root value="a" /> Option A
  <Checkbox.Root value="b" /> Option B
</CheckboxGroup>

// ✅ Proper item structure
<CheckboxGroup>
  <Field.Item>
    <Checkbox.Root value="a" />
    <Field.Label>Option A</Field.Label>
  </Field.Item>
  <Field.Item>
    <Checkbox.Root value="b" />
    <Field.Label>Option B</Field.Label>
  </Field.Item>
</CheckboxGroup>
```

### Integration Issues to Flag

1. **Not forwarding ref from Controller:**
```tsx
// ❌ Focus on error won't work
<Controller
  render={({ field }) => (
    <Field.Control value={field.value} />
  )}
/>

// ✅ Ref forwarded for focus management
<Controller
  render={({ field }) => (
    <Field.Control
      value={field.value}
      ref={field.ref}
    />
  )}
/>
```

2. **Not syncing validation state:**
```tsx
// ❌ Base UI doesn't know about validation state
<Controller
  render={({ field }) => (
    <Field.Root>
      <Field.Control value={field.value} />
    </Field.Root>
  )}
/>

// ✅ Validation state synced
<Controller
  render={({ field, fieldState }) => (
    <Field.Root
      invalid={fieldState.invalid}
      touched={fieldState.isTouched}
      dirty={fieldState.isDirty}
    >
      <Field.Control value={field.value} />
      <Field.Error match={!!fieldState.error}>
        {fieldState.error?.message}
      </Field.Error>
    </Field.Root>
  )}
/>
```

3. **Using wrong change handler:**
```tsx
// ❌ onChange gives event, not value
<Field.Control onChange={field.onChange} />

// ✅ Use onValueChange for direct value
<Field.Control onValueChange={field.onChange} />
```

# Base UI Render Prop Patterns

The `render` prop is Base UI's composition mechanism for element replacement and state-aware rendering.

## Two Forms

### Element Form (Static Replacement)

Replaces the default element with another element. Props are automatically merged.

```tsx
// Replace button with anchor
<Button render={<a href="/contact" />}>Contact</Button>

// Replace with custom component
<Dialog.Trigger render={<CustomButton variant="primary" />} />

// Replace with semantic element
<Menu.Item render={<a href="/settings" />}>Settings</Menu.Item>
```

**Props merging behavior:**
- Event handlers: Both called (component's first, then render element's)
- className: Concatenated (render element's first)
- style: Merged (render element's wins on conflict)
- ref: All refs merged
- Other props: Render element's override component's

### Callback Form (State Access)

Access component state and full control over rendered element.

```tsx
<Button render={(props, state) => (
  <button
    {...props}
    className={state.disabled ? 'opacity-50' : 'opacity-100'}
    aria-busy={state.disabled}
  >
    {state.disabled ? 'Loading...' : 'Submit'}
  </button>
)} />

<Dialog.Trigger render={(props, state) => (
  <button {...props}>
    {state.open ? 'Close' : 'Open'} Dialog
  </button>
)} />
```

**Critical rule:** Always spread `{...props}` to preserve:
- Accessibility attributes (aria-*, role)
- Event handlers (onClick, onKeyDown, etc.)
- Data attributes (data-disabled, data-open, etc.)
- Refs

## State-Aware className and style

Without using render prop, you can still access state:

```tsx
// className function
<Button
  disabled={loading}
  className={(state) => `btn ${state.disabled ? 'btn-disabled' : 'btn-active'}`}
/>

// style function
<Dialog.Trigger
  style={(state) => ({
    backgroundColor: state.open ? 'blue' : 'gray',
    transform: state.open ? 'rotate(180deg)' : 'none'
  })}
/>

// Combined
<Accordion.Trigger
  className={(state) => state.open ? 'expanded' : 'collapsed'}
  style={(state) => ({ fontWeight: state.open ? 'bold' : 'normal' })}
/>
```

## Available State by Component

| Component | State Properties |
|-----------|-----------------|
| Button | `disabled` |
| Dialog.Trigger | `disabled`, `open` |
| Dialog.Popup | `open`, `nested`, `modal` |
| Menu.Trigger | `disabled`, `open` |
| Menu.Item | `disabled`, `highlighted` |
| Popover.Trigger | `open` |
| Tooltip.Popup | `open`, `instant` |
| Select.Trigger | `disabled`, `open`, `valid`, `touched`, `dirty` |
| Select.Item | `disabled`, `selected`, `highlighted` |
| Combobox.Input | `open`, `valid`, `touched`, `dirty` |
| Combobox.Item | `disabled`, `selected`, `highlighted` |
| Tabs.Tab | `disabled`, `selected` |
| Accordion.Trigger | `disabled`, `open` |
| Checkbox.Root | `checked`, `disabled`, `indeterminate` |
| Switch.Root | `checked`, `disabled` |
| Slider.Thumb | `disabled`, `dragging`, `index`, `value` |
| Field.* | `disabled`, `valid`, `touched`, `dirty` |
| NumberField.* | `disabled`, `valid`, `touched`, `dirty`, `scrubbing` |

## Event Handler Prevention

Prevent Base UI's internal handler while keeping your own:

```tsx
<Button
  render={(props) => (
    <button
      {...props}
      onClick={(event) => {
        // Prevent Base UI's onClick handler
        event.preventBaseUIHandler();

        // Your custom logic runs
        doSomethingCustom();
      }}
    />
  )}
/>
```

**When to use:**
- Override default open/close behavior
- Add confirmation before action
- Conditional handling based on state

## Nested Composition

Render props can be nested arbitrarily:

```tsx
<Tooltip.Root>
  <Tooltip.Trigger render={
    <Dialog.Trigger render={
      <Button render={<a href="#" />} />
    } />
  }>
    Hover for tooltip, click for dialog
  </Tooltip.Trigger>
</Tooltip.Root>
```

## TypeScript Support

```tsx
// Types are inferred from component
<Button render={(props, state) => {
  // state is typed as { disabled: boolean }
  // props includes all button props
  return <button {...props} />;
}} />

// Explicit typing when needed
<Dialog.Trigger
  render={(
    props: React.ComponentPropsWithRef<'button'>,
    state: { disabled: boolean; open: boolean }
  ) => (
    <button {...props}>{state.open ? 'Close' : 'Open'}</button>
  )}
/>
```

## Common Mistakes

### 1. Forgetting to spread props

```tsx
// ❌ WRONG - loses accessibility and handlers
<Button render={(props, state) => (
  <button className={state.disabled ? 'dim' : ''}>Click</button>
)} />

// ✅ CORRECT
<Button render={(props, state) => (
  <button {...props} className={`${props.className} ${state.disabled ? 'dim' : ''}`}>
    Click
  </button>
)} />
```

### 2. Overwriting props instead of merging

```tsx
// ❌ WRONG - overwrites Base UI's onClick
<Button render={(props, state) => (
  <button {...props} onClick={() => console.log('click')}>Click</button>
)} />

// ✅ CORRECT - chain handlers
<Button render={(props, state) => (
  <button
    {...props}
    onClick={(e) => {
      console.log('click');
      props.onClick?.(e);
    }}
  >
    Click
  </button>
)} />

// ✅ OR use preventBaseUIHandler if you want to skip Base UI's handler
<Button render={(props, state) => (
  <button
    {...props}
    onClick={(e) => {
      e.preventBaseUIHandler();
      console.log('only my handler');
    }}
  >
    Click
  </button>
)} />
```

### 3. Using element form when callback is needed

```tsx
// ❌ Can't access state with element form
<Button render={<button className={/* how to check disabled? */} />} />

// ✅ Use callback form for state access
<Button render={(props, state) => (
  <button {...props} className={state.disabled ? 'dim' : ''} />
)} />
```

### 4. Duplicating state

```tsx
// ❌ Unnecessary state duplication
const [isOpen, setIsOpen] = useState(false);
<Dialog.Trigger
  className={isOpen ? 'open' : 'closed'}
  onClick={() => setIsOpen(!isOpen)}
/>

// ✅ Use component's state
<Dialog.Trigger className={(state) => state.open ? 'open' : 'closed'} />
```

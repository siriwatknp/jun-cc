# Base UI Anti-Patterns

Generic mistakes applicable across all Base UI components. Component-specific errors are in each component's Review Checklist.

## Import Issues

```tsx
// ❌ Wrong import paths
import { Button } from '@mui/base';
import { Button } from '@base-ui-components/react/button';

// ✅ Correct
import { Button } from '@base-ui/react/button';
```

## Render Prop Mistakes

### Using Radix asChild

```tsx
// ❌ asChild is Radix, not Base UI
<Button asChild><a href="/">Link</a></Button>

// ✅ Use render prop
<Button render={<a href="/" />}>Link</Button>
```

### Missing Props Spread

```tsx
// ❌ Loses accessibility and event handlers
<Button render={(props, state) => (
  <button>Click me</button>
)} />

// ✅ Spread props
<Button render={(props, state) => (
  <button {...props}>Click me</button>
)} />
```

### Overwriting Event Handlers

```tsx
// ❌ Overwrites Base UI's handler
<Dialog.Trigger render={(props) => (
  <button {...props} onClick={myHandler}>Open</button>
)} />

// ✅ Chain handlers
<Dialog.Trigger render={(props) => (
  <button
    {...props}
    onClick={(e) => {
      myHandler(e);
      props.onClick?.(e);
    }}
  >Open</button>
)} />

// ✅ Or prevent intentionally
<Dialog.Trigger render={(props) => (
  <button
    {...props}
    onClick={(e) => {
      e.preventBaseUIHandler();
      customLogic();
    }}
  >Open</button>
)} />
```

### Overwriting className

```tsx
// ❌ Loses Base UI's internal classes
<Button render={(props) => (
  <button {...props} className="my-button">Click</button>
)} />

// ✅ Use className function instead
<Button className={(state) => `my-button ${state.disabled ? 'dim' : ''}`}>
  Click
</Button>
```

## State Management

```tsx
// ❌ Maintaining separate state that mirrors component state
const [isOpen, setIsOpen] = useState(false);
<Dialog.Root open={isOpen} onOpenChange={setIsOpen}>
  <Dialog.Trigger className={isOpen ? 'open' : 'closed'}>

// ✅ Use state functions -- no separate state needed
<Dialog.Root>
  <Dialog.Trigger className={(state) => state.open ? 'open' : 'closed'}>
```

## Event Prevention

```tsx
// ❌ preventDefault doesn't stop Base UI's handler
e.preventDefault();

// ✅ Use preventBaseUIHandler
e.preventBaseUIHandler();
```

## Performance

```tsx
// ❌ New element every render
<Button render={<a href="/" />}>Link</Button>

// ✅ Stable reference
const linkEl = <a href="/" />;
<Button render={linkEl}>Link</Button>
```

# Base UI Styling & Animation

Guide for styling Base UI components and implementing animations.

## Styling Approaches

Base UI components are unstyled and compatible with any styling solution:
- Tailwind CSS
- CSS Modules
- CSS-in-JS (Emotion, styled-components)
- Plain CSS

### Style Hooks

#### className prop

```tsx
// Static className
<Switch.Thumb className="SwitchThumb" />

// State-aware className (function form)
<Switch.Thumb className={(state) => state.checked ? 'checked' : 'unchecked'} />
```

#### style prop

```tsx
// Static style
<Switch.Thumb style={{ height: '100px' }} />

// State-aware style (function form)
<Switch.Thumb style={(state) => ({ color: state.checked ? 'red' : 'blue' })} />
```

#### Data Attributes

All components expose data attributes for CSS targeting:

```css
.SwitchThumb[data-checked] {
  background-color: green;
}

[data-disabled] {
  opacity: 0.5;
  cursor: not-allowed;
}

[data-open] {
  display: block;
}

[data-state="open"] {
  background-color: blue;
}
```

#### CSS Variables

Popup components expose CSS variables for sizing:

```css
.Popup {
  max-height: var(--available-height);
  min-width: var(--anchor-width);
}
```

Common CSS variables:
- `--available-height` - Available viewport height
- `--available-width` - Available viewport width
- `--anchor-width` - Width of anchor element
- `--anchor-height` - Height of anchor element
- `--transform-origin` - Transform origin for animations

## Animation

### CSS Transitions (Recommended)

Use `[data-starting-style]` and `[data-ending-style]` for smooth transitions:

```css
.Popup {
  transform-origin: var(--transform-origin);
  transition: transform 150ms, opacity 150ms;

  &[data-starting-style],
  &[data-ending-style] {
    opacity: 0;
    transform: scale(0.9);
  }
}
```

**Advantage:** Transitions can be smoothly cancelled midway (e.g., closing popup before it finishes opening).

### CSS Animations

Use `[data-open]` and `[data-closed]` for keyframe animations:

```css
@keyframes scaleIn {
  from { opacity: 0; transform: scale(0.9); }
  to { opacity: 1; transform: scale(1); }
}

@keyframes scaleOut {
  from { opacity: 1; transform: scale(1); }
  to { opacity: 0; transform: scale(0.9); }
}

.Popup[data-open] {
  animation: scaleIn 250ms ease-out;
}

.Popup[data-closed] {
  animation: scaleOut 250ms ease-in;
}
```

### JavaScript Animations (Motion/Framer Motion)

#### Unmounted components (default)

For popups that unmount when closed:

```tsx
function AnimatedPopover() {
  const [open, setOpen] = useState(false);

  return (
    <Popover.Root open={open} onOpenChange={setOpen}>
      <Popover.Trigger>Trigger</Popover.Trigger>
      <AnimatePresence>
        {open && (
          <Popover.Portal keepMounted>
            <Popover.Positioner>
              <Popover.Popup
                render={
                  <motion.div
                    initial={{ opacity: 0, scale: 0.8 }}
                    animate={{ opacity: 1, scale: 1 }}
                    exit={{ opacity: 0, scale: 0.8 }}
                  />
                }
              >
                Content
              </Popover.Popup>
            </Popover.Positioner>
          </Popover.Portal>
        )}
      </AnimatePresence>
    </Popover.Root>
  );
}
```

Key points:
- Make component controlled with `open` prop
- Add `keepMounted` to Portal
- Use `render` prop with `motion.div`
- Wrap in `AnimatePresence`

#### Kept mounted components

For components with `keepMounted` that stay in DOM:

```tsx
<Popover.Root>
  <Popover.Trigger>Trigger</Popover.Trigger>
  <Popover.Portal keepMounted>
    <Popover.Positioner>
      <Popover.Popup
        render={(props, state) => (
          <motion.div
            {...(props as HTMLMotionProps<'div'>)}
            initial={false}
            animate={{
              opacity: state.open ? 1 : 0,
              scale: state.open ? 1 : 0.8,
            }}
          />
        )}
      >
        Content
      </Popover.Popup>
    </Popover.Positioner>
  </Popover.Portal>
</Popover.Root>
```

Key points:
- No `AnimatePresence` needed
- Use callback render prop to access `state.open`
- Animate based on state

#### Manual unmounting

For full control:

```tsx
const actionsRef = useRef(null);

<Popover.Root actionsRef={actionsRef}>
  <Popover.Popup
    render={
      <motion.div
        exit={{ scale: 0 }}
        onAnimationComplete={() => {
          if (!open) {
            actionsRef.current.unmount();
          }
        }}
      />
    }
  />
</Popover.Root>
```

## Common Review Points

### Styling Issues to Flag

1. **Not using state functions when needed:**
```tsx
// ❌ Doesn't respond to state changes
<Button className="my-button" disabled={loading} />

// ✅ Responds to component state
<Button className={(state) => `my-button ${state.disabled ? 'dim' : ''}`} />
```

2. **Missing data attribute selectors:**
```tsx
// ❌ Manual class toggling
<Dialog.Popup className={isOpen ? 'open' : 'closed'} />

// ✅ Use automatic data attributes
// CSS: .Popup[data-open] { ... }
<Dialog.Popup className="Popup" />
```

3. **Not using CSS variables:**
```tsx
// ❌ Hardcoded max-height
.Popup { max-height: 400px; }

// ✅ Dynamic based on available space
.Popup { max-height: var(--available-height); }
```

### Animation Issues to Flag

1. **Using CSS animations instead of transitions:**
```css
/* ❌ Can't cancel mid-animation */
.Popup[data-open] { animation: fadeIn 200ms; }

/* ✅ Smooth cancellation */
.Popup {
  transition: opacity 200ms;
  &[data-starting-style],
  &[data-ending-style] { opacity: 0; }
}
```

2. **Missing keepMounted for Motion animations:**
```tsx
// ❌ Exit animation won't play
<AnimatePresence>
  {open && (
    <Popover.Portal> {/* Missing keepMounted */}
      <Popover.Popup render={<motion.div exit={{ opacity: 0 }} />} />
    </Popover.Portal>
  )}
</AnimatePresence>

// ✅ Exit animation works
<AnimatePresence>
  {open && (
    <Popover.Portal keepMounted>
      <Popover.Popup render={<motion.div exit={{ opacity: 0 }} />} />
    </Popover.Portal>
  )}
</AnimatePresence>
```

3. **Wrong data attributes for animation state:**
```css
/* ❌ Not for animation */
[data-open] { display: block; }

/* ✅ For transitions */
[data-starting-style] { opacity: 0; }
[data-ending-style] { opacity: 0; }
```

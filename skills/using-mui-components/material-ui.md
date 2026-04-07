## Components

### Button vs IconButton

- If the mockup shows a button with high contrast background color, use `Button` component with customized border radius (if necessary) because the `IconButton` doesn't support variant prop.

  For example:

  ```jsx
  <Button variant="contained" sx={{ borderRadius: 99 }}>
    <AddIcon />
  </Button>
  ```

  Only use `IconButton` for secondary actions, or list of buttons with same size that show only icons.

- There is no need to use `textTransform: "none"` on the button. The [built-in theme](#built-in-theme) already has this style.
- DO NOT customize the button with `grey` tokens. Instead, use the `primary` color of the theme.

### Chip

- For subtle background, ALWAYS use `<Chip variant="filled" color="success|error|info|warning|secondary">`.

### Icon

- `@mui/icons-material` should be the first resource to search for icons. If not possible, use `lucide-react` as a second option.
- In case both are not possible, use `<Box sx={{ display: 'inline-block', width: size, height: size, bgcolor: 'text.icon', borderRadius: '50%', }} />` to display the icon.

### TextField and Form Best Practices

1. **Label Integration**:

   - **ALWAYS use built-in `label` prop** instead of separate Typography components
   - Ensures proper accessibility and screen reader support
   - Maintains semantic HTML structure

2. **Modern API Usage**:

   - Use `slotProps` instead of deprecated `InputProps`, `InputLabelProps`
   - Proper slot configuration: `slotProps.input`, `slotProps.inputLabel`, `slotProps.htmlInput`
   - Never use deprecated props that trigger TypeScript warnings

3. **Form State Management**:

   - Implement controlled components with proper state handling
   - Add real-time validation with error states
   - Clear errors on user interaction
   - Use proper TypeScript types for form data

4. **Accessibility Requirements**:

   - Include `required` prop for mandatory fields
   - Provide `error` and `helperText` for validation feedback
   - Ensure proper ARIA attributes
   - Support full keyboard navigation

5. **Input Constraints & Validation**:

   ```tsx
   // ✅ CORRECT: Proper TextField with all best practices
   <TextField
     fullWidth
     required
     label="Card Number"
     placeholder="1234 5678 9012 3456"
     variant="outlined"
     value={formData.cardNumber}
     onChange={handleInputChange("cardNumber")}
     error={!!errors.cardNumber}
     helperText={errors.cardNumber || "Enter 16-digit card number"}
   />

   // ❌ INCORRECT: Poor accessibility and deprecated API
   <Box>
     <Typography variant="body2">CARD NUMBER</Typography>
     <TextField
       fullWidth
       placeholder="1234..."
       InputProps={{ /* deprecated */ }}
     />
   </Box>
   ```

### Typography

- DO NOT use variant `h5` and `h6`. The lowest heading variant is `h4`.
- When using `h*` variant, consider specifying proper `fontSize` value in `sx` prop.

### TextField and Form Best Practices

1. **Label Integration**:

   - **ALWAYS use built-in `label` prop** instead of separate Typography components
   - Ensures proper accessibility and screen reader support
   - Maintains semantic HTML structure

2. **Modern API Usage**:

   - Use `slotProps` instead of deprecated `InputProps`, `InputLabelProps`
   - Proper slot configuration: `slotProps.input`, `slotProps.inputLabel`, `slotProps.htmlInput`
   - Never use deprecated props that trigger TypeScript warnings

3. **Form State Management**:

   - Implement controlled components with proper state handling
   - Add real-time validation with error states
   - Clear errors on user interaction
   - Use proper TypeScript types for form data

4. **Accessibility Requirements**:

   - Include `required` prop for mandatory fields
   - Provide `error` and `helperText` for validation feedback
   - Ensure proper ARIA attributes
   - Support full keyboard navigation

5. **Input Constraints & Validation**:

   ```tsx
   // ✅ CORRECT: Proper TextField with all best practices
   <TextField
     fullWidth
     required
     label="Card Number"
     placeholder="1234 5678 9012 3456"
     variant="outlined"
     value={formData.cardNumber}
     onChange={handleInputChange("cardNumber")}
     error={!!errors.cardNumber}
     helperText={errors.cardNumber || "Enter 16-digit card number"}
   />

   // ❌ INCORRECT: Poor accessibility and deprecated API
   <Box>
     <Typography variant="body2">CARD NUMBER</Typography>
     <TextField
       fullWidth
       placeholder="1234..."
       InputProps={{ /* deprecated */ }}
     />
   </Box>
   ```

## Polymorphic Component Pattern (OverridableComponent)

When a component needs a `component` prop to swap the root element (and get type-safe props for it), use the `OverridableComponent` type below. Works with any React component — styled or not.

Simplified alternative to MUI's `OverridableComponent` + `TypeMap` — no `TypeMap` needed. If the project doesn't have this type yet, create it in a shared types file.

### The type

```typescript
// types.ts — shared, reusable across all components
export type OverridableComponent<
  Props extends { component?: React.ElementType },
  DefaultComponent extends React.ElementType = 'button',
> = <C extends React.ElementType = DefaultComponent>(
  props: Omit<Props, 'component'> &
    Omit<React.ComponentPropsWithoutRef<C>, keyof Props> & {
      component?: C;
    } & React.RefAttributes<React.ElementRef<C>>
) => React.JSX.Element;
```

### Usage

1. **Props interface** — simple, non-generic. Must include `component?: React.ElementType`.

2. **forwardRef + cast** — type forwardRef with default component's element/props, cast with `OverridableComponent`:

```typescript
const MyComponent = React.forwardRef<
  HTMLDivElement,
  MyComponentProps & React.ComponentPropsWithoutRef<typeof DefaultRoot>
>(function MyComponent({ component, children, ...props }, ref) {
  const Root = component ?? DefaultRoot;
  return <Root ref={ref} {...props}>{children}</Root>;
}) as OverridableComponent<MyComponentProps, typeof DefaultRoot>;
```

3. **Can wrap with `React.memo`**:

```typescript
const MyComponent = React.memo(React.forwardRef<
  HTMLDivElement,
  MyComponentProps & React.ComponentPropsWithoutRef<typeof DefaultRoot>
>(function MyComponent({ component, children, ...props }, ref) {
  const Root = component ?? DefaultRoot;
  return <Root ref={ref} {...props}>{children}</Root>;
})) as OverridableComponent<MyComponentProps, typeof DefaultRoot>;
```

4. **(Optional) For styled components**, pass `component` via the `as` prop instead of rendering `Root`:

```typescript
return <StyledRoot ref={ref} as={component} {...props}>{children}</StyledRoot>;
```

Use `Pick<Props, ...>` for styled component's `ownerState` typing (no separate OwnProps interface).

Key rules:
- Never `React.forwardRef<any, any>` — always use the default component's HTMLElement + props
- `ref` type auto-derives from `component` (e.g. `HTMLAnchorElement` for `Link`)


## Mockup images or videos

- Don't use fake divs to replicate images from the mockup. Instead, use `<Box component="img" />` with empty `src` and proper `alt`, style it via the `sx` prop with proper `aspectRatio` and other CSS that is needed.
- When real images or videos are not provided or could not be found, use [placeholder](https://placehold.co/) to generate a placeholder image or video. Make sure to use the correct aspect ratio and proper size, for example, if the mockup is 3:4, the src should be `https://placehold.co/600x400` or for square, use `https://placehold.co/400`.

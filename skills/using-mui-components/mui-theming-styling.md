## Rules

1. **Minimal sx Props**: Use sx primarily for layout structure, not decorative styling
2. **Theme-First Approach**: Always use theme variables over hardcoded values
3. **Proper Token Usage**: Use alias tokens, never direct static tokens
4. **Responsive Patterns**: Follow established patterns for breakpoints and container queries
5. **Dark Mode Compliance**: Use `theme.applyStyles('dark', styles)` exclusively
6. **No Unnecessary Comments**: Keep code clean unless documentation is explicitly requested
7. **TypeScript**: Ensure there are no type errors after on changed files.

## Theming

## Styling

### Visual Accuracy Methodology

1. **Spacing Precision**:
   - Use 0.5 step increments (0.5, 1, 1.5, 2, etc.)
   - Text/icon spacing: 0.5-1.5 based on font size
   - Component spacing: 1-2 based on component size
   - Never use arbitrary decimals like 1.2

2. **Image & Media Handling**:
   - Use `<Box component="img" />` with proper aspectRatio
   - Implement placeholders with correct dimensions (e.g., https://placehold.co/600x400) WITHOUT using any query params
   - Never use fake divs to simulate images

3. **Container & Media Queries**:

   ```tsx
   sx={theme => ({
     // Container queries with proper fallbacks
     [theme.containerQueries?.up("md") || "@container (min-width: 900px)"]: {
       gridColumn: "span 7"
     },
     // Media queries for responsive parent
     ".responsive-media &": {
       [theme.breakpoints.up("md")]: {
         width: "50%"
       }
     }
   })}
   ```

   For components that will be filled to a layout, e.g. cards, button, or form inputs, DO NOT set `maxWidth` or `width` on them. Let the them flow naturally.
   Instead, control the width from the preview page instead for demo purpose.

### Colors

- For text or typography that represent `error`, `success`, `info` or `warning`, use `<palette>.text` token to produce better contrast.

  ```tsx
  // with sx prop
  <Typography sx={{ color: "error.text" }}>Error</Typography>

  // with theme
  <Box sx={theme => ({
    color: (theme.vars || theme).palette.success.text,
  })}>
    Error
  </Box>
  ```

### `sx` prop

- Keep `sx` props to a minimum. The `sx` prop should be used for structuring layout when composing elements to form a bigger component.
- Don't overuse custom padding, margin, border, box-shadow, etc. Leave it to the theme, unless explicitly asked to do so.
- Don't hardcode colors, spacing, etc. Use the theme variables instead. For colors, try to replicate the color from the mockup by using `color` prop on the component that matches the most, if not, fallback to the `primary` color of the theme (usually don't need to specify the color prop). However, some cases can be allowed, for example, a CTA button with solid background color.
- Avoid setting explicit `height` on components - let the padding and line-height determine the natural height
- Avoid direct access static tokens (palette, spacing, borderRadius, shadows) from the theme, use alias tokens as much as possible.

  ```diff
  - sx={theme => ({ borderRadius: (theme) => (theme.vars || theme).shape.borderRadius * 3 })}
  + sx={{ borderRadius: 3 }}

  - sx={theme => ({ color: (theme.vars || theme).palette.primary.main })}
  + sx={{ color: "primary.main" }}
  ```

- To access the theme, use callback as a value (recommended) or as an array item (DON'T use callback within an object) THIS RULES IS MANDATORY, you MUST ALWAYS do this WITHOUT EXCEPTION:

  ```js
  // ✅ Correct, use callback as a value
  sx={theme => ({
    color: (theme.vars || theme).palette.primary.main,
  })}

  // ✅ Correct, use callback as an array item
  sx={[
    {
      borderRadius: 2,
    },
    theme => ({
      color: (theme.vars || theme).palette.primary.main,
    })
  ]}

  // ❌ Incorrect, DO NOT EVER EVER use callback within an object as spread operator
  sx={{
    borderRadius: 2,
    ...theme => ({
      color: (theme.vars || theme).palette.primary.main,
    })
  }}
  ```

- For responsive design, if it's a single field that needs to be responsive, use `sx={{ width: { xs: "100%", md: "50%" } }}`. For multiple fields, use `theme.breakpoints.up` to create a responsive layout.

  ```tsx
  <Box sx={theme => ({
    width: "100%",
    fontSize: 16,
    [theme.breakpoints.up("md")]: {
      width: "50%",
      fontSize: 14,
    },
  })}>
  ```

- For container queries, use `theme.containerQueries.up()` instead of hardcoded pixel values:

  ```tsx
  <Box sx={theme => ({
    // Use theme.containerQueries.up() for container queries
    [theme.containerQueries?.up("sm") || "@container (min-width: 600px)"]: {
      gridColumn: "span 6",
    },
    [theme.containerQueries?.up("md") || "@container (min-width: 900px)"]: {
      gridColumn: "span 7",
    },
  })}>
  ```

- When supporting both container and media queries, use class selectors for conditional styling:

  ```tsx
  <Box sx={theme => ({
    // Default container query styles
    [theme.containerQueries?.up("md") || "@container (min-width: 900px)"]: {
      width: "50%",
    },
    // Media query styles when parent has specific class
    ".responsive-media &": {
      [theme.breakpoints.up("md")]: {
        width: "50%",
      },
    },
  })}>
  ```

- IMPORTANT! When merging `sx` props (usually building component on top of Material UI), use array syntax instead of object spread:

  ```tsx
  function CodeBlockCopyButton({ sx, ...props }: CodeBlockCopyButtonProps) {
    return (
      <IconButton
        sx={[
          // Base styles could be object or callback to access theme
          {
            color: "text.secondary",
            "&:hover": {
              color: "text.primary",
            },
          },
          ...(Array.isArray(sx) ? sx : [sx]), // ALWAYS DO THIS!
        ]}
        {...props}
      >
        <CopyIcon />
      </IconButton>
    );
  }
  ```

- Hover styles for focusable components like `Button`, `Radio`, `Checkbox`, `Tab` MUST be wrapped in `@media (hover: hover)` to avoid issues on touch devices:

  ```tsx
  sx={theme => ({
    // Base styles
    bgcolor: "background.paper",
    // Hover styles wrapped in media query
    "@media (hover: hover)": {
      "&:hover": {
        bgcolor: "action.hover",
      },
    },
  })}
  ```

### Theme usage

- Use callback functions with `theme.vars` instead of raw CSS variable strings for type safety
- When using `theme.vars` for getting `palette|shape`, always fallback to the theme like this `(theme.vars || theme).*`.
- For typography properties, use `theme.typography` directly (NOT `theme.vars.typography` or `(theme.vars || theme).typography`).
- Finally, there should be no type errors after created/updated the component theme file.

```tsx
// ✅ CORRECT: Using theme tokens properly
sx={{
  borderRadius: 3,
  color: "primary.main",
  p: 2,
  ...theme.applyStyles('dark', {
    bgcolor: "grey.900"
  })
}}

// ❌ INCORRECT: Hardcoded values and improper dark mode
sx={{
  borderRadius: "12px",
  color: "#1976d2",
  padding: "16px",
  bgcolor: isDarkMode ? "grey.900" : "white"
}}
```

### Spacing guidelines

When using `Stack` component or `Box` component with `display: flex`, the spacing should follow:

- Spacing value should be 0.5 step. Don't use random decimal like `1.2` just to match the mockup.
- For texts and icons, the spacing should be between 0.5 and 1.5 depending on the font size of the texts.
- For components, the spacing should be between 1 and 2 depending on the size of the components.
- When using `Box` component to create flexbox layout, it's the default to add `gap` at least `1` to the `sx` prop to support edge cases when the component shrink UNLESS the design analysis explicitly says otherwise.

### Dark mode

- If the provided mockup comes with dark styles, don't try to replicate the mockup with dark palette. Instead, build the component as if it's in light mode.
- Don't ever import the them from `useTheme` hook to check dark mode. Instead, use `theme.applyStyles('dark', styles)` to apply dark mode styles.

  ```diff
  - const theme = useTheme();
  - const isDarkMode = theme.palette.mode === "dark";

    <Card
      sx={theme => ({
        mx: "auto",
        borderRadius: 2,
  -     bgcolor: isDarkMode ? "grey.900" : "background.paper",
  +     bgcolor: "background.paper",
  +     ...theme.applyStyles('dark', {
  +       bgcolor: "grey.900",
  +     }),
      })}
    >
  ```

  ```js
  // ✅ Correct, use callback as a value
  <Card
    sx={theme => ({
      mx: "auto",
      borderRadius: 2,
      bgcolor: "background.paper",
      ...theme.applyStyles('dark', {
        bgcolor: "grey.900",
      }),
    })}
  >
  ```

  ```js
  // ❌ Incorrect, use callback within an object
  <Card
    sx={{
      mx: "auto",
      borderRadius: 2,
      bgcolor: "background.paper",
      ...theme => theme.applyStyles('dark', {
        bgcolor: "grey.900",
      }),
    }}
  >
  ```

## Custom component

- always wrap the component with `forwardRef` and pass the `ref` to the root element of the custom component.
- pass `sx` prop with `...(Array.isArray(sx) ? sx : [sx]),` when building on top of Material UI components to allow users to override styles with `sx` prop.

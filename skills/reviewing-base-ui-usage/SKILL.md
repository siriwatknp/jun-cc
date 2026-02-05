---
name: reviewing-base-ui-usage
description: Reviews Base UI component usage in codebases. Use when asked to review, audit, or check code using @base-ui/react components. Identifies incorrect patterns, accessibility issues, and suggests improvements based on official Base UI conventions.
---

# Base UI Usage Review

Review Base UI (`@base-ui/react`) component usage for correctness, accessibility, and adherence to official patterns.

## Quick Reference

- **Package name**: `@base-ui/react` (NOT `@base-ui-components/react` or `@mui/base`)
- **Import pattern**: `import { Button } from '@base-ui/react/button'`
- **Render prop pattern**: `render={<a />}` or `render={(props, state) => <button {...props} />}`
- **State functions**: `className={(state) => ...}`, `style={(state) => ...}`
- **Data attributes**: Components expose `data-*` attributes for styling (e.g., `data-disabled`, `data-open`)
- **Event prevention**: Use `event.preventBaseUIHandler()` to skip component's internal handler

## Review Process

1. **Verify import paths** - Must be `@base-ui/react/*`
2. **Check render prop usage** - Verify correct element/callback form, props spread
3. **Verify component structure** - See each component's Structure section
4. **Run component checklist** - Each component file has error patterns to flag
5. **Audit accessibility** - Check for required semantic components (Title, Label, etc.)
6. **Review styling approach** - Confirm state-aware styling patterns

## Reference Files

- [Render Prop Patterns](./render-prop-patterns.md) - Deep dive on render prop usage
- [Anti-Patterns](./anti-patterns.md) - Generic mistakes and fixes
- [Styling & Animation](./styling-animation.md) - CSS/JS animation patterns and styling approaches
- [Forms Integration](./forms-integration.md) - Form building and library integration

## Component Reference

Each component file contains: **Structure** (required nesting), **Gotchas** (traps), **Review Checklist** (error patterns to flag).

### Layout & Navigation

- [Accordion](./components/accordion.md) - Collapsible content sections
- [Collapsible](./components/collapsible.md) - Single show/hide section
- [Tabs](./components/tabs.md) - Tabbed interface
- [NavigationMenu](./components/navigation-menu.md) - Site navigation with dropdowns
- [Menubar](./components/menubar.md) - Application menu bar
- [Toolbar](./components/toolbar.md) - Toolbar with keyboard navigation
- [ScrollArea](./components/scroll-area.md) - Custom scrollbars

### Overlays & Popups

- [Dialog](./components/dialog.md) - Modal dialog
- [AlertDialog](./components/alert-dialog.md) - Confirmation dialog
- [Menu](./components/menu.md) - Dropdown menu
- [ContextMenu](./components/context-menu.md) - Right-click menu
- [Popover](./components/popover.md) - Floating content panel
- [Tooltip](./components/tooltip.md) - Hover text hints
- [PreviewCard](./components/preview-card.md) - Hover preview cards
- [Toast](./components/toast.md) - Notification toasts

### Form Controls

- [Field](./components/field.md) - Form field wrapper with validation
- [Fieldset](./components/fieldset.md) - Form field grouping
- [Form](./components/form.md) - Form container
- [Button](./components/button.md) - Button component
- [Input](./components/input.md) - Text input
- [Checkbox](./components/checkbox.md) - Checkbox control
- [CheckboxGroup](./components/checkbox-group.md) - Multiple checkboxes
- [RadioGroup](./components/radio-group.md) - Radio button group
- [Switch](./components/switch.md) - Toggle switch
- [Select](./components/select.md) - Dropdown select
- [Combobox](./components/combobox.md) - Filterable dropdown (restricted)
- [Autocomplete](./components/autocomplete.md) - Text autocomplete (free input)
- [NumberField](./components/number-field.md) - Numeric input with stepper
- [Slider](./components/slider.md) - Range slider
- [Toggle](./components/toggle.md) - Toggle button
- [ToggleGroup](./components/toggle-group.md) - Toggle button group

### Feedback & Status

- [Progress](./components/progress.md) - Task progress indicator
- [Meter](./components/meter.md) - Static measurement display

### Miscellaneous

- [Avatar](./components/avatar.md) - User avatar with fallback
- [Separator](./components/separator.md) - Visual divider
- [Composite](./components/composite.md) - Internal keyboard navigation (not for direct use)

# CSS & Styling

Principles for maintainable, scalable styling systems.

## Core Principles

### 1. Predictability
Styles should be predictable and easy to reason about.

- Avoid deep specificity chains
- Minimize use of !important
- Prefer explicit over inherited styles

### 2. Modularity
Styles should be scoped and composable.

- Co-locate styles with components
- Avoid global style pollution
- Use design tokens for consistency

### 3. Performance
Styles should not impede performance.

- Minimize layout thrashing
- Use efficient selectors
- Avoid expensive properties in animations

### 4. Maintainability
Styles should be easy to understand and modify.

- Use semantic naming
- Document non-obvious decisions
- Organize logically

## Design Tokens

Centralize design decisions as tokens:

| Token Type | Examples |
|------------|----------|
| Colors | `--color-primary`, `--color-error` |
| Spacing | `--space-sm`, `--space-md`, `--space-lg` |
| Typography | `--font-size-base`, `--line-height-tight` |
| Borders | `--radius-sm`, `--border-width` |
| Shadows | `--shadow-sm`, `--shadow-lg` |
| Motion | `--duration-fast`, `--easing-standard` |

## Detailed Patterns

For implementation-specific patterns, see:
- [Styling Patterns](../../skills/standards-frontend/resources/styling.md)

## Naming Conventions

- Use lowercase with hyphens: `button-primary`
- Be descriptive: `card-header` not `ch`
- Indicate state: `is-active`, `has-error`
- Indicate variants: `button--large`, `card--featured`

## Quick Reference

| Practice | Do | Avoid |
|----------|-----|-------|
| Specificity | Low, flat | Deep nesting |
| Units | rem/em for text | px for text |
| Colors | Design tokens | Hardcoded values |
| Layout | Flexbox/Grid | Float hacks |
| Responsive | Mobile-first | Desktop-first |
| Z-index | Token scale | Magic numbers |

## Performance Checklist

- [ ] No unused styles shipped
- [ ] Critical CSS identified
- [ ] Animations use transform/opacity
- [ ] No layout shifts (CLS)
- [ ] Styles are minified in production

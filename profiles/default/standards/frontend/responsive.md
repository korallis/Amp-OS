# Responsive Design

Principles for building interfaces that work across all devices and contexts.

## Core Principles

### 1. Mobile-First
Start with mobile constraints, enhance for larger screens.

- Design for smallest viewport first
- Add complexity as space allows
- Ensures core experience works everywhere

### 2. Fluid Over Fixed
Use flexible units and layouts.

- Percentage widths over fixed pixels
- Relative typography (rem/em)
- Fluid spacing scales

### 3. Content-Driven Breakpoints
Let content determine breakpoints, not devices.

- Break when the design breaks
- Avoid device-specific assumptions
- Test with real content

### 4. Touch-Friendly
Design for touch as the primary input.

- Minimum 44px touch targets
- Adequate spacing between interactive elements
- Consider thumb reach zones

## Breakpoint Strategy

| Name | Purpose | Typical Range |
|------|---------|---------------|
| Base | Mobile phones | 0 - 639px |
| sm | Large phones | 640px+ |
| md | Tablets | 768px+ |
| lg | Laptops | 1024px+ |
| xl | Desktops | 1280px+ |

## Responsive Patterns

| Pattern | Use Case |
|---------|----------|
| Stack → Row | Navigation, cards |
| Sidebar collapse | Dashboards |
| Progressive disclosure | Complex forms |
| Responsive tables | Data grids |
| Adaptive images | Media content |

## Detailed Patterns

For implementation-specific patterns, see:
- [Component Patterns](../../skills/standards-frontend/resources/component-patterns.md)
- [Styling Patterns](../../skills/standards-frontend/resources/styling.md)

## Quick Reference

```css
/* Mobile-first media query pattern */
.element {
  /* Base: mobile styles */
  flex-direction: column;
}

@media (min-width: 768px) {
  .element {
    /* Enhanced: tablet+ styles */
    flex-direction: row;
  }
}
```

## Testing Checklist

- [ ] Works without horizontal scroll at 320px
- [ ] Touch targets are minimum 44px
- [ ] Text remains readable at all sizes
- [ ] Images scale appropriately
- [ ] Navigation is accessible on mobile
- [ ] Forms are usable on small screens
- [ ] No content is hidden unintentionally

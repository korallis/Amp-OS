---
name: amp-os-standards-frontend
description: Frontend component and UI development standards. Load when implementing React/UI components, state management, or styling to ensure consistent patterns, accessibility, and user experience.
---

# Frontend Standards

Standards for components, state management, and UI patterns.

## When to Use
- Building UI components
- Implementing state management
- Adding styles or layouts
- Handling user interactions

## Standards Reference

See [component-patterns.md](resources/component-patterns.md) for complete guidelines.

## Quick Reference

### Component Structure
```tsx
// Props interface first
interface ButtonProps {
  variant: 'primary' | 'secondary';
  onClick: () => void;
  children: React.ReactNode;
}

// Named export
export function Button({ variant, onClick, children }: ButtonProps) {
  return <button className={styles[variant]} onClick={onClick}>{children}</button>;
}
```

### State Guidelines
- Local state for UI-only concerns
- Context for shared app state
- Server state with React Query/SWR
- URL state for shareable views

### Accessibility
- Semantic HTML always
- ARIA labels on interactive elements
- Keyboard navigation support
- Color contrast compliance

### Performance
- Lazy load routes
- Memoize expensive renders
- Virtualize long lists
- Optimize images

## Amp Tools to Use
- `finder` - Find existing component patterns
- `Read` - Check component library conventions

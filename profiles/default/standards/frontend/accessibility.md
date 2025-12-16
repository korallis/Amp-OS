# Accessibility

Principles for building accessible user interfaces that work for all users.

## Core Principles

### 1. Perceivable
All content must be presentable to users in ways they can perceive.

- **Text alternatives**: Provide alt text for non-text content
- **Captions**: Include captions for audio/video content
- **Adaptable**: Content should work with assistive technologies
- **Distinguishable**: Ensure sufficient color contrast (4.5:1 minimum)

### 2. Operable
All interface components must be operable by all users.

- **Keyboard accessible**: All functionality available via keyboard
- **Time adjustable**: Provide enough time to read and use content
- **Seizure safe**: No content that flashes more than 3 times/second
- **Navigable**: Provide ways to navigate, find content, and determine location

### 3. Understandable
Content and interface operation must be understandable.

- **Readable**: Text content is readable and understandable
- **Predictable**: Pages appear and operate in predictable ways
- **Input assistance**: Help users avoid and correct mistakes

### 4. Robust
Content must be robust enough for reliable interpretation by assistive technologies.

- **Compatible**: Maximize compatibility with current and future tools
- **Valid markup**: Use semantically correct HTML
- **ARIA when needed**: Use ARIA only when native HTML is insufficient

## Detailed Patterns

For implementation-specific patterns, see:
- [Component Patterns](../../skills/standards-frontend/resources/component-patterns.md)

## Quick Reference

| Element | Requirement |
|---------|-------------|
| Images | Alt text describing content/function |
| Forms | Labels associated with inputs |
| Buttons | Descriptive text or aria-label |
| Links | Clear destination indication |
| Headings | Logical hierarchy (h1 → h2 → h3) |
| Color | Not sole means of conveying info |
| Focus | Visible focus indicator |
| Motion | Respect prefers-reduced-motion |

## Testing Checklist

- [ ] Keyboard navigation works for all interactions
- [ ] Screen reader announces content correctly
- [ ] Color contrast meets WCAG AA (4.5:1)
- [ ] Focus order is logical
- [ ] Error messages are announced
- [ ] No keyboard traps exist

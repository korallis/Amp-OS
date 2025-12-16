# Components

Principles for building maintainable, reusable component architectures.

## Core Principles

### 1. Single Responsibility
Each component should do one thing well.

- One primary purpose per component
- Extract sub-components when complexity grows
- Separate logic from presentation when beneficial

### 2. Composition Over Inheritance
Build complex UIs by composing simple components.

- Favor small, composable building blocks
- Use slots/children for flexible content injection
- Avoid deep component hierarchies

### 3. Explicit Dependencies
Components should clearly declare what they need.

- Props define the component's public API
- Avoid implicit global state dependencies
- Document required vs optional props

### 4. Encapsulation
Components should hide internal implementation details.

- Internal state is private
- Expose controlled interfaces
- Style scoping prevents leakage

### 5. Predictability
Components should behave consistently.

- Same props → same output
- Minimize side effects
- Handle edge cases gracefully

## Component Categories

| Type | Purpose | State |
|------|---------|-------|
| Presentational | Display UI | Minimal/none |
| Container | Manage data/logic | Yes |
| Layout | Structure/spacing | None |
| Utility | Shared behavior | Varies |

## Detailed Patterns

For implementation-specific patterns, see:
- [Component Patterns](../../skills/standards-frontend/resources/component-patterns.md)

## Props Design Guidelines

- Use descriptive, consistent naming
- Prefer primitives over complex objects
- Provide sensible defaults
- Validate prop types
- Document expected values

## Quick Reference

```
Good Component:
├── Clear, single purpose
├── Well-defined props API
├── Handles loading/error states
├── Accessible by default
└── Tested in isolation

Avoid:
├── God components (too many responsibilities)
├── Prop drilling through many levels
├── Tight coupling to parent context
└── Side effects in render
```

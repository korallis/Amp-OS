---
name: amp-os-standards-global
description: Global coding conventions and best practices. Load when implementing any code to ensure consistent naming, error handling, file organization, and code style across the entire codebase.
---

# Global Standards

Universal coding conventions that apply to all code in the project.

## When to Use
- Starting any implementation task
- Reviewing code for consistency
- Setting up new files or modules

## Standards Reference

See [coding-conventions.md](resources/coding-conventions.md) for complete guidelines.

## Quick Reference

### Naming
- Files: `kebab-case.ts`, `kebab-case.tsx`
- Functions: `camelCase`
- Classes/Types: `PascalCase`
- Constants: `SCREAMING_SNAKE_CASE`
- Booleans: prefix with `is`, `has`, `should`, `can`

### Code Organization
- One component/class per file
- Group imports: external → internal → relative
- Keep files under 300 lines
- Extract when function exceeds 50 lines

### Error Handling
- Never swallow errors silently
- Use typed errors where possible
- Log with context (what, where, why)
- Fail fast, recover gracefully

### Comments
- Code should be self-documenting
- Comment the "why", not the "what"
- Keep comments up to date or remove them

## Amp Tools to Use
- `finder` - Find existing patterns to follow
- `Read` - Check neighboring files for conventions

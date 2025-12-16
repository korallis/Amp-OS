# Coding Style

Core conventions for code style and formatting across all projects.

## Principles

1. **Consistency over preference** - Follow established patterns in the codebase
2. **Readability first** - Code is read more than written
3. **Self-documenting code** - Names should reveal intent
4. **Minimal cognitive load** - Reduce mental overhead for readers

## Style Rules

### Formatting
- Use consistent indentation (2 or 4 spaces, match project)
- Keep lines under 100 characters
- One statement per line
- Blank lines separate logical sections

### Naming
| Type | Convention | Example |
|------|------------|---------|
| Variables | camelCase | `userName`, `isActive` |
| Constants | UPPER_SNAKE | `MAX_RETRIES`, `API_URL` |
| Functions | camelCase (verb) | `getUserById`, `validateInput` |
| Classes | PascalCase | `UserService`, `HttpClient` |
| Files | kebab-case | `user-service.ts`, `api-client.js` |
| Booleans | is/has/can prefix | `isValid`, `hasPermission` |

### Function Guidelines
- Functions should do one thing
- Keep under 50 lines
- Limit parameters to 3-4 (use objects for more)
- Use early returns to reduce nesting

### File Organization
- Keep files under 300 lines
- Group related code together
- Imports at top, exports at bottom
- Co-locate related files in feature folders

## Detailed Patterns

For implementation-specific patterns, see:
- [Coding Conventions](../../skills/standards-global/resources/coding-conventions.md)
- [Common Patterns](../../skills/standards-global/resources/common-patterns.md)

## Quick Reference

```
✅ DO                          ❌ AVOID
─────────────────────────────────────────
Early returns                   Deep nesting
Descriptive names               Abbreviations
Small functions                 God functions
Parameter objects               Many parameters
Immutable operations            Direct mutation
```

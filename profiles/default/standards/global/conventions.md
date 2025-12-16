# Project Conventions

Standard conventions for project organization and structure.

## Principles

1. **Predictability** - Developers should know where to find things
2. **Co-location** - Related code lives together
3. **Explicit over implicit** - Prefer clear structure to magic
4. **Scale gracefully** - Conventions should work for small and large projects

## File Organization

### Feature-Based Structure
```
src/
├── features/
│   └── auth/
│       ├── components/
│       ├── hooks/
│       ├── actions/
│       ├── types.ts
│       └── index.ts
├── components/ui/     # Shared UI components
├── lib/               # Utilities and helpers
└── types/             # Global type definitions
```

### Naming Conventions
| Item | Convention | Example |
|------|------------|---------|
| Folders | kebab-case | `user-management/` |
| Components | PascalCase | `UserCard.tsx` |
| Utilities | kebab-case | `format-date.ts` |
| Types | PascalCase | `UserProfile.ts` |
| Tests | `.test.` suffix | `user-service.test.ts` |
| Styles | `.module.` suffix | `button.module.css` |

## Module Exports

### Barrel Exports
```typescript
// features/auth/index.ts
export { LoginForm } from './components/login-form';
export { useAuth } from './hooks/use-auth';
export type { User, Session } from './types';
```

### Import Order
1. External packages
2. Internal aliases (`@/`)
3. Relative imports
4. Type imports

## Configuration

- Centralize in `config/` or `lib/config.ts`
- Validate at application startup
- Use environment variables for secrets
- Type all configuration objects

## Detailed Patterns

For implementation-specific patterns, see:
- [Coding Conventions](../../skills/standards-global/resources/coding-conventions.md)
- [Common Patterns](../../skills/standards-global/resources/common-patterns.md)

## Quick Reference

```
✅ DO                          ❌ AVOID
─────────────────────────────────────────
Feature folders                 Type-based folders
Barrel exports                  Deep import paths
Explicit dependencies           Hidden coupling
Typed configuration             Magic strings
```

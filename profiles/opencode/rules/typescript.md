---
description: TypeScript coding standards
globs: ["**/*.ts", "**/*.tsx", "!**/node_modules/**", "!**/dist/**", "!**/build/**", "!**/.next/**", "!**/coverage/**"]
---

# TypeScript Standards

> **Rule Precedence**: Security > Correctness/Types > Testing > Performance > Style

## Type Safety

- **NO** `any` type - use `unknown` and narrow with type guards
- **NO** `@ts-ignore` or `@ts-expect-error` - fix the underlying issue
- **NO** non-null assertions (`!`) - use proper null checks
- Prefer `interface` for object shapes, `type` for unions/aliases
- Use `satisfies` for type checking without widening

## Patterns

```typescript
// Discriminated unions for state
type State = 
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: Data }
  | { status: 'error'; error: Error };

// Type guards
function isError(state: State): state is { status: 'error'; error: Error } {
  return state.status === 'error';
}

// Branded types for IDs
type UserId = string & { readonly __brand: 'UserId' };
const createUserId = (id: string): UserId => id as UserId;
```

## Imports

- Use path aliases (`@/`) for internal imports
- Group: external libs → internal modules → relative imports
- Avoid barrel exports in large codebases (performance)

## Async/Await

- Always handle errors with try/catch or `.catch()`
- Use `Promise.allSettled()` when failures should not block others
- Prefer `async/await` over `.then()` chains

## Validation

- Use Zod schemas at boundaries (API, forms, env)
- Infer types from schemas: `type User = z.infer<typeof userSchema>`
- Validate early, fail fast

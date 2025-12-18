# Global Coding Standards

These standards apply to ALL code in this project. They are automatically loaded via OpenCode's instructions system.

## TypeScript Configuration

### Required Compiler Options

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true
  }
}
```

## Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Files | kebab-case | `user-service.ts` |
| Classes | PascalCase | `UserService` |
| Functions | camelCase | `getUserById` |
| Constants | SCREAMING_SNAKE_CASE | `MAX_RETRIES` |
| Interfaces | PascalCase (no I prefix) | `User`, not `IUser` |
| Types | PascalCase | `UserResponse` |
| Enums | PascalCase | `UserRole` |
| Enum members | PascalCase | `UserRole.Admin` |

## Type Safety Rules

### NEVER Use Type Suppressions

```typescript
// FORBIDDEN - Never do these
const data = response as any;           // NO
// @ts-ignore                           // NO
// @ts-expect-error                     // NO
const items = data as unknown as Item[]; // NO - double assertion
```

### Use Proper Type Narrowing

```typescript
// Use type guards
function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    'email' in value
  );
}

// Use Zod for runtime validation
const UserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
});

type User = z.infer<typeof UserSchema>;
```

### Prefer Discriminated Unions

```typescript
// Good: Discriminated union for state
type AsyncState<T> = 
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error };
```

## Function Patterns

### Use Parameter Objects for 3+ Parameters

```typescript
// Bad
function createUser(name: string, email: string, role: string, dept: string) {}

// Good
interface CreateUserInput {
  name: string;
  email: string;
  role: UserRole;
  department: string;
}

function createUser(input: CreateUserInput) {}
```

### Use Early Returns

```typescript
// Bad - deeply nested
function process(order: Order | null) {
  if (order) {
    if (order.items.length > 0) {
      if (order.status === 'pending') {
        // process
      }
    }
  }
}

// Good - guard clauses
function process(order: Order | null) {
  if (!order) return;
  if (order.items.length === 0) return;
  if (order.status !== 'pending') return;
  
  // process - now at low nesting level
}
```

### Keep Functions Small

- Maximum 50 lines per function
- Single responsibility
- Extract complex logic to helpers

## Error Handling

### Use Typed Error Classes

```typescript
export class AppError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    public readonly statusCode: number = 500
  ) {
    super(message);
    this.name = this.constructor.name;
  }
}

export class ValidationError extends AppError {
  constructor(message: string) {
    super(message, 'VALIDATION_ERROR', 400);
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string, id: string) {
    super(`${resource} not found: ${id}`, 'NOT_FOUND', 404);
  }
}
```

### Never Swallow Errors

```typescript
// FORBIDDEN - empty catch
try {
  await doSomething();
} catch (e) {} // NO!

// Good - handle or rethrow
try {
  await doSomething();
} catch (error) {
  if (error instanceof ValidationError) {
    return { error: error.message };
  }
  logger.error('Unexpected error', { error });
  throw error;
}
```

## File Organization

### Maximum File Size

- Keep files under 300 lines
- Split large files into modules
- Co-locate related code

### Module Structure

```
features/
└── auth/
    ├── components/
    ├── hooks/
    ├── actions/
    ├── types.ts
    └── index.ts
```

### Barrel Exports

```typescript
// components/ui/index.ts
export { Button } from './button';
export { Input } from './input';
export { Card } from './card';
```

## Code Review Checklist

Before considering code complete:

- [ ] Types are strict (no `any`, proper inference)
- [ ] Error handling is comprehensive
- [ ] No magic numbers or strings
- [ ] Functions are < 50 lines
- [ ] Files are < 300 lines
- [ ] Naming is clear and consistent
- [ ] No console.log in production code
- [ ] Tests cover edge cases

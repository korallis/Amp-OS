# Global Coding Conventions

Comprehensive coding standards for modern TypeScript full-stack development.

## TypeScript Configuration

### Recommended tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["dom", "dom.iterable", "ES2022"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "alwaysStrict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
```

## Type Patterns

### Discriminated Unions

```typescript
// ✅ Preferred: Discriminated unions for state
type AsyncState<T> = 
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error };

function handleState<T>(state: AsyncState<T>) {
  switch (state.status) {
    case 'idle':
      return 'Ready to load';
    case 'loading':
      return 'Loading...';
    case 'success':
      return state.data; // TypeScript knows data exists
    case 'error':
      return state.error.message; // TypeScript knows error exists
  }
}
```

### Type Guards

```typescript
// ✅ Custom type guards for runtime checks
function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    'email' in value
  );
}

// ✅ Zod for complex validation
const UserSchema = z.object({
  id: z.string(),
  email: z.string().email(),
});

function isValidUser(value: unknown): value is User {
  return UserSchema.safeParse(value).success;
}
```

### Generic Constraints

```typescript
// ✅ Constrained generics
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

// ✅ Conditional types
type NonNullableFields<T> = {
  [K in keyof T]: NonNullable<T[K]>;
};

// ✅ Infer keyword
type UnwrapPromise<T> = T extends Promise<infer U> ? U : T;
```

### Utility Types

```typescript
// Common utility type patterns
type Nullable<T> = T | null;
type Optional<T> = T | undefined;
type Maybe<T> = T | null | undefined;

// API response types
type ApiResponse<T> = {
  data: T;
  meta?: {
    page: number;
    total: number;
    hasMore: boolean;
  };
};

// Action result
type ActionResult<T = void> = 
  | { success: true; data: T }
  | { success: false; error: string };
```

## Function Patterns

### Parameter Objects

```typescript
// ❌ Too many parameters
function createUser(
  name: string,
  email: string,
  role: string,
  department: string,
  manager: string
) { /* ... */ }

// ✅ Parameter object
interface CreateUserInput {
  name: string;
  email: string;
  role: UserRole;
  department: string;
  managerId?: string;
}

function createUser(input: CreateUserInput) {
  const { name, email, role, department, managerId } = input;
  // ...
}
```

### Early Returns

```typescript
// ❌ Nested conditionals
function processOrder(order: Order) {
  if (order) {
    if (order.items.length > 0) {
      if (order.status === 'pending') {
        // Process order
      }
    }
  }
}

// ✅ Early returns (guard clauses)
function processOrder(order: Order | null) {
  if (!order) return;
  if (order.items.length === 0) return;
  if (order.status !== 'pending') return;
  
  // Process order - now at a low nesting level
}
```

### Async Function Patterns

```typescript
// ✅ Async function with proper error handling
async function fetchUserData(userId: string): Promise<Result<UserData>> {
  try {
    const response = await fetch(`/api/users/${userId}`);
    
    if (!response.ok) {
      return {
        success: false,
        error: new AppError(
          `Failed to fetch user: ${response.statusText}`,
          'FETCH_ERROR',
          response.status
        ),
      };
    }
    
    const data = await response.json();
    const validated = UserDataSchema.parse(data);
    
    return { success: true, data: validated };
  } catch (error) {
    if (error instanceof z.ZodError) {
      return {
        success: false,
        error: new AppError('Invalid response data', 'VALIDATION_ERROR', 500),
      };
    }
    throw error; // Re-throw unexpected errors
  }
}
```

## Module Organization

### Barrel Exports

```typescript
// components/ui/index.ts
export { Button } from './button';
export { Input } from './input';
export { Card } from './card';

// Usage
import { Button, Input, Card } from '@/components/ui';
```

### Co-location

```
features/
└── auth/
    ├── components/
    │   ├── login-form.tsx
    │   └── signup-form.tsx
    ├── hooks/
    │   └── use-auth.ts
    ├── actions/
    │   └── auth-actions.ts
    ├── types.ts
    └── index.ts
```

## Constants and Configuration

```typescript
// lib/constants.ts
export const APP_CONFIG = {
  name: 'MyApp',
  version: '1.0.0',
  api: {
    baseUrl: process.env.NEXT_PUBLIC_API_URL,
    timeout: 30_000,
    retries: 3,
  },
  pagination: {
    defaultPageSize: 20,
    maxPageSize: 100,
  },
} as const;

// Numeric constants with underscores for readability
const MAX_FILE_SIZE = 10_000_000; // 10MB
const CACHE_TTL = 60 * 60 * 1000; // 1 hour in ms
```

## Error Handling Patterns

### Error Classes

```typescript
// lib/errors.ts
export class AppError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    public readonly statusCode: number = 500,
    public readonly isOperational: boolean = true,
    public readonly context?: Record<string, unknown>
  ) {
    super(message);
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }
}

export class ValidationError extends AppError {
  constructor(message: string, context?: Record<string, unknown>) {
    super(message, 'VALIDATION_ERROR', 400, true, context);
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string, id: string) {
    super(`${resource} not found: ${id}`, 'NOT_FOUND', 404, true, { resource, id });
  }
}

export class UnauthorizedError extends AppError {
  constructor(message = 'Unauthorized') {
    super(message, 'UNAUTHORIZED', 401, true);
  }
}
```

### Try-Catch Patterns

```typescript
// ✅ Specific error handling
try {
  await createUser(data);
} catch (error) {
  if (error instanceof ValidationError) {
    // Handle validation error
    return { error: error.message };
  }
  if (error instanceof DatabaseError) {
    // Handle database error
    logger.error('Database error', { error });
    return { error: 'An unexpected error occurred' };
  }
  // Re-throw unknown errors
  throw error;
}
```

## Logging Best Practices

```typescript
// lib/logger.ts
import pino from 'pino';

export const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  formatters: {
    level: (label) => ({ level: label }),
  },
});

// Usage with context
logger.info({ userId, action: 'login' }, 'User logged in');
logger.error({ error, requestId }, 'Request failed');
logger.warn({ threshold, current }, 'Rate limit approaching');
```

## Git Commit Conventions

```
type(scope): description

Types:
- feat: New feature
- fix: Bug fix
- docs: Documentation
- style: Formatting (no code change)
- refactor: Code restructuring
- test: Tests
- chore: Maintenance

Examples:
- feat(auth): add OAuth2 login support
- fix(api): handle null user in response
- docs(readme): update installation steps
```

## Code Review Checklist

- [ ] Types are strict (no `any`, proper inference)
- [ ] Error handling is comprehensive
- [ ] No magic numbers or strings
- [ ] Functions are < 50 lines
- [ ] Files are < 300 lines
- [ ] Naming is clear and consistent
- [ ] No console.log in production code
- [ ] Secrets are properly handled
- [ ] Tests cover edge cases
- [ ] Accessibility considered (if UI)

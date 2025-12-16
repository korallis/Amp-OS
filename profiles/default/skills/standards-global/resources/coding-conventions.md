# Coding Conventions

## 1. Naming Conventions

### Files & Directories
```
components/user-profile.tsx    # kebab-case for files
utils/format-date.ts           # descriptive, single-purpose
hooks/use-auth.ts              # hooks prefixed with 'use'
types/user.types.ts            # type files suffixed with '.types'
constants/api-endpoints.ts     # constants in dedicated files
```

### Variables & Functions
```typescript
// Functions: camelCase, verb-first
function getUserById(id: string) {}
function validateEmail(email: string) {}
function handleSubmit(event: Event) {}

// Booleans: is/has/should/can prefix
const isLoading = true;
const hasPermission = false;
const shouldRefetch = true;
const canEdit = user.role === 'admin';

// Constants: SCREAMING_SNAKE_CASE
const MAX_RETRY_COUNT = 3;
const API_BASE_URL = '/api/v1';
```

### Types & Interfaces
```typescript
// PascalCase for types/interfaces
interface UserProfile {}
type ApiResponse<T> = {}
enum UserRole { Admin, User, Guest }

// Props suffixed with Props
interface ButtonProps {}
interface UserCardProps {}
```

## 2. File Organization

### Import Order
```typescript
// 1. External libraries
import React from 'react';
import { useQuery } from '@tanstack/react-query';

// 2. Internal absolute imports
import { Button } from '@/components/ui';
import { useAuth } from '@/hooks';

// 3. Relative imports
import { formatDate } from './utils';
import type { UserProps } from './types';
```

### File Structure
```typescript
// 1. Imports
// 2. Types/Interfaces
// 3. Constants
// 4. Helper functions (if small)
// 5. Main export (component/function)
// 6. Sub-components (if any)
```

### Size Guidelines
- Files: < 300 lines (split if larger)
- Functions: < 50 lines (extract if larger)
- Components: < 200 lines (compose if larger)

## 3. Error Handling

### Do
```typescript
// Typed errors
class ValidationError extends Error {
  constructor(public field: string, message: string) {
    super(message);
    this.name = 'ValidationError';
  }
}

// Contextual logging
logger.error('Failed to fetch user', { 
  userId, 
  error: err.message,
  stack: err.stack 
});

// Graceful degradation
const user = await fetchUser(id).catch(() => null);
if (!user) return <FallbackUI />;
```

### Don't
```typescript
// Silent swallowing
try { doThing(); } catch (e) {}

// Generic messages
throw new Error('Something went wrong');

// Unhandled promises
fetchData(); // missing await or .catch()
```

## 4. Code Style

### Prefer
```typescript
// Early returns
function process(data) {
  if (!data) return null;
  if (!data.valid) return { error: 'invalid' };
  return transform(data);
}

// Destructuring
const { name, email } = user;
const [first, ...rest] = items;

// Optional chaining
const city = user?.address?.city;

// Nullish coalescing
const name = user.name ?? 'Anonymous';
```

### Avoid
```typescript
// Nested conditionals
if (a) {
  if (b) {
    if (c) {
      // deep nesting
    }
  }
}

// Magic numbers
setTimeout(fn, 86400000); // what is this?

// Abbreviations
const usrNm = user.name; // unclear
const btn = document.querySelector('button'); // use full words
```

## 5. Comments

### Good Comments
```typescript
// Explain WHY, not WHAT
// Using setTimeout to debounce rapid clicks that cause race conditions
setTimeout(handleClick, 100);

// Document non-obvious business logic
// Tax exempt if: non-profit org OR order total < $10 (company policy #123)
const isTaxExempt = org.isNonProfit || total < 10;

// TODO with context
// TODO(username): Migrate to new API after v2 release (ETA: Q2)
```

### Bad Comments
```typescript
// Obvious comments
i++; // increment i

// Outdated comments
// Returns user name (actually returns full user object now)
function getUser() {}

// Commented-out code
// const oldImplementation = () => {};
```

## 6. Async Patterns

### Promises
```typescript
// Prefer async/await
async function fetchData() {
  try {
    const response = await api.get('/data');
    return response.data;
  } catch (error) {
    handleError(error);
    throw error;
  }
}

// Parallel when independent
const [users, posts] = await Promise.all([
  fetchUsers(),
  fetchPosts()
]);
```

### Error Boundaries
```typescript
// Always handle async errors
await doThing().catch(handleError);

// Or use try/catch
try {
  await doThing();
} catch (error) {
  handleError(error);
}
```

## 7. Security

### Never
- Commit secrets, keys, or credentials
- Log sensitive data (passwords, tokens, PII)
- Use `eval()` or `dangerouslySetInnerHTML` without sanitization
- Trust user input without validation

### Always
- Validate and sanitize inputs
- Use parameterized queries
- Implement proper authentication checks
- Follow principle of least privilege

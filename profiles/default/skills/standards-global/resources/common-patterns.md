# Common Coding Patterns

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Variables | camelCase | `userName`, `isActive` |
| Constants | UPPER_SNAKE | `MAX_RETRIES`, `API_URL` |
| Functions | camelCase (verb) | `getUserById`, `validateInput` |
| Classes | PascalCase | `UserService`, `HttpClient` |
| Files | kebab-case | `user-service.ts`, `api-client.js` |
| Booleans | is/has/can prefix | `isValid`, `hasPermission`, `canEdit` |

## Guard Clauses

**Prefer early returns over nested conditionals**:

```javascript
// Good
function processUser(user) {
  if (!user) return null;
  if (!user.isActive) return null;
  
  return doExpensiveOperation(user);
}

// Avoid
function processUser(user) {
  if (user) {
    if (user.isActive) {
      return doExpensiveOperation(user);
    }
  }
  return null;
}
```

## Error Handling

```javascript
// Use typed errors
class ValidationError extends Error {
  constructor(field, message) {
    super(message);
    this.field = field;
    this.name = 'ValidationError';
  }
}

// Handle errors at appropriate boundaries
async function handleRequest(req) {
  try {
    return await processRequest(req);
  } catch (error) {
    if (error instanceof ValidationError) {
      return { status: 400, error: error.message };
    }
    logger.error('Unexpected error', { error });
    return { status: 500, error: 'Internal server error' };
  }
}
```

## Null Safety

```javascript
// Use optional chaining
const city = user?.address?.city;

// Use nullish coalescing for defaults
const name = user.name ?? 'Anonymous';

// Prefer explicit checks for critical paths
if (user === null || user === undefined) {
  throw new Error('User is required');
}
```

## Configuration

```javascript
// Centralize configuration
const config = {
  api: {
    baseUrl: process.env.API_URL || 'http://localhost:3000',
    timeout: parseInt(process.env.API_TIMEOUT, 10) || 5000,
  },
  features: {
    darkMode: process.env.FEATURE_DARK_MODE === 'true',
  },
};

// Validate at startup
function validateConfig(config) {
  const required = ['api.baseUrl'];
  for (const key of required) {
    if (!get(config, key)) {
      throw new Error(`Missing required config: ${key}`);
    }
  }
}
```

## Immutability

```javascript
// Prefer immutable operations
const newArray = [...existingArray, newItem];
const newObject = { ...existingObject, updatedField: newValue };

// Use Object.freeze for constants
const STATUSES = Object.freeze({
  PENDING: 'pending',
  ACTIVE: 'active',
  CLOSED: 'closed',
});
```

## Async Patterns

```javascript
// Use Promise.all for parallel operations
const [users, orders] = await Promise.all([
  fetchUsers(),
  fetchOrders(),
]);

// Use for...of for sequential async
for (const item of items) {
  await processItem(item);
}
```

# Backend Standards

Standards for API design, database patterns, and server-side development.

## API Design

### RESTful Conventions

| Action | HTTP Method | URL Pattern | Response |
|--------|-------------|-------------|----------|
| List | GET | `/resources` | 200 + array |
| Get | GET | `/resources/:id` | 200 or 404 |
| Create | POST | `/resources` | 201 + created |
| Update | PUT | `/resources/:id` | 200 + updated |
| Partial Update | PATCH | `/resources/:id` | 200 + updated |
| Delete | DELETE | `/resources/:id` | 204 or 200 |

### Response Structure

```typescript
// Success response
interface ApiResponse<T> {
  data: T;
  meta?: {
    page?: number;
    pageSize?: number;
    total?: number;
    hasMore?: boolean;
  };
}

// Error response
interface ApiError {
  error: {
    code: string;
    message: string;
    details?: Record<string, unknown>;
  };
}
```

### Status Codes

| Code | When to Use |
|------|-------------|
| 200 | Success with body |
| 201 | Created new resource |
| 204 | Success, no body |
| 400 | Bad request / validation error |
| 401 | Not authenticated |
| 403 | Not authorized |
| 404 | Resource not found |
| 409 | Conflict (duplicate, etc.) |
| 422 | Unprocessable entity |
| 500 | Server error |

### Pagination

```typescript
// Request
GET /users?page=2&pageSize=20

// Response
{
  "data": [...],
  "meta": {
    "page": 2,
    "pageSize": 20,
    "total": 157,
    "hasMore": true
  }
}
```

## Database Patterns

### Schema Conventions

```typescript
// Primary keys: UUID
id: uuid('id').primaryKey().defaultRandom()

// Timestamps
createdAt: timestamp('created_at').defaultNow().notNull()
updatedAt: timestamp('updated_at').defaultNow().notNull()

// Soft deletes
deletedAt: timestamp('deleted_at')

// Column naming: snake_case
userId: uuid('user_id').references(() => users.id)
```

### Soft Deletes

```typescript
// Always use soft deletes for user data
async function deleteUser(id: string) {
  return db.update(users)
    .set({ deletedAt: new Date() })
    .where(eq(users.id, id));
}

// Filter out deleted in queries
const activeUsers = await db.select()
  .from(users)
  .where(isNull(users.deletedAt));
```

### Query Patterns

```typescript
// Use transactions for related operations
await db.transaction(async (tx) => {
  const order = await tx.insert(orders).values(orderData).returning();
  await tx.insert(orderItems).values(
    items.map(item => ({ ...item, orderId: order.id }))
  );
  return order;
});

// Use proper indexing
// Add index for frequently queried columns
// Add composite index for common query patterns
```

### Migrations

```typescript
// Always include down migration
export async function up(db: Database) {
  await db.schema.createTable('users')
    .addColumn('id', 'uuid', col => col.primaryKey())
    .addColumn('email', 'varchar(255)', col => col.notNull().unique())
    .execute();
}

export async function down(db: Database) {
  await db.schema.dropTable('users').execute();
}
```

## Authentication & Authorization

### Auth Patterns

```typescript
// Middleware pattern
export async function requireAuth(req: Request): Promise<User> {
  const token = req.headers.get('Authorization')?.replace('Bearer ', '');
  
  if (!token) {
    throw new UnauthorizedError('No token provided');
  }
  
  const user = await verifyToken(token);
  if (!user) {
    throw new UnauthorizedError('Invalid token');
  }
  
  return user;
}

// Permission check
export function requirePermission(permission: Permission) {
  return async (req: Request, user: User) => {
    if (!user.permissions.includes(permission)) {
      throw new ForbiddenError(`Missing permission: ${permission}`);
    }
  };
}
```

## Input Validation

### Use Zod for All Input

```typescript
const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
  role: z.enum(['user', 'admin']).default('user'),
});

export async function createUser(input: unknown) {
  const data = CreateUserSchema.parse(input); // Throws on invalid
  // data is now typed correctly
}
```

## Logging

```typescript
// Structured logging
import { logger } from '@/lib/logger';

logger.info({ userId, action: 'login' }, 'User logged in');
logger.error({ error, requestId }, 'Request failed');
logger.warn({ threshold, current }, 'Rate limit approaching');

// Include context
logger.child({ requestId }).info('Processing request');
```

## Security Checklist

- [ ] All inputs validated with Zod
- [ ] SQL injection prevented (parameterized queries)
- [ ] Auth checked on all protected routes
- [ ] Rate limiting implemented
- [ ] Sensitive data not logged
- [ ] CORS properly configured
- [ ] Security headers set

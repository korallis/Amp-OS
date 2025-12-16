# API Design Standards

## 1. REST Conventions

### URL Structure
```
# Resources are nouns, plural
GET    /api/v1/users
GET    /api/v1/users/:id
POST   /api/v1/users
PATCH  /api/v1/users/:id
DELETE /api/v1/users/:id

# Nested resources for relationships
GET    /api/v1/users/:id/posts
POST   /api/v1/users/:id/posts

# Actions as sub-resources (when CRUD doesn't fit)
POST   /api/v1/users/:id/activate
POST   /api/v1/orders/:id/cancel
```

### Query Parameters
```
# Filtering
GET /api/v1/users?status=active&role=admin

# Pagination
GET /api/v1/users?page=2&limit=20

# Sorting
GET /api/v1/users?sort=created_at&order=desc

# Field selection
GET /api/v1/users?fields=id,name,email

# Search
GET /api/v1/users?q=john
```

## 2. Response Format

### Success Response
```json
{
  "data": {
    "id": "123",
    "type": "user",
    "attributes": {
      "name": "John Doe",
      "email": "john@example.com"
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

### List Response
```json
{
  "data": [
    { "id": "1", "name": "Item 1" },
    { "id": "2", "name": "Item 2" }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "totalPages": 3
  }
}
```

### Error Response
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  }
}
```

## 3. HTTP Status Codes

### Success (2xx)
| Code | Use Case |
|------|----------|
| 200 | GET, PATCH, DELETE success |
| 201 | POST created new resource |
| 204 | Success with no content (bulk delete) |

### Client Error (4xx)
| Code | Use Case |
|------|----------|
| 400 | Malformed request, validation error |
| 401 | Missing or invalid authentication |
| 403 | Authenticated but not authorized |
| 404 | Resource not found |
| 409 | Conflict (duplicate, state mismatch) |
| 422 | Valid syntax but semantic error |
| 429 | Rate limit exceeded |

### Server Error (5xx)
| Code | Use Case |
|------|----------|
| 500 | Unexpected server error |
| 502 | Bad gateway (upstream failure) |
| 503 | Service unavailable (maintenance) |

## 4. Authentication & Authorization

### Headers
```
Authorization: Bearer <token>
X-API-Key: <key>                  # For service-to-service
X-Request-ID: <uuid>              # For tracing
```

### Patterns
```typescript
// Middleware approach
app.use('/api', authMiddleware);
app.use('/api/admin', requireRole('admin'));

// Route-level
router.get('/profile', authenticate, getProfile);
router.post('/users', authenticate, authorize('users:create'), createUser);
```

## 5. Validation

### Input Validation
```typescript
// Schema-based validation (zod, joi, yup)
const createUserSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.string().email(),
  password: z.string().min(8),
  role: z.enum(['user', 'admin']).default('user')
});

// Validate early, fail fast
const result = createUserSchema.safeParse(req.body);
if (!result.success) {
  return res.status(400).json({ 
    error: formatZodError(result.error) 
  });
}
```

### Sanitization
```typescript
// Always sanitize user input
const sanitized = {
  name: sanitizeHtml(input.name),
  email: input.email.toLowerCase().trim()
};
```

## 6. Database Patterns

### Migrations
```sql
-- Always use migrations, never manual changes
-- Include both up and down migrations
-- Name: YYYYMMDDHHMMSS_description.sql

-- 20240115103000_add_users_table.sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Down migration
DROP TABLE users;
```

### Indexing
```sql
-- Index foreign keys
CREATE INDEX idx_posts_user_id ON posts(user_id);

-- Index frequently queried fields
CREATE INDEX idx_users_email ON users(email);

-- Composite index for common queries
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
```

### Soft Deletes
```sql
-- Prefer soft delete for user data
ALTER TABLE users ADD COLUMN deleted_at TIMESTAMP NULL;

-- Query active records
SELECT * FROM users WHERE deleted_at IS NULL;
```

## 7. Error Handling

### Centralized Handler
```typescript
// Error types
class AppError extends Error {
  constructor(
    public statusCode: number,
    public code: string,
    message: string
  ) {
    super(message);
  }
}

class NotFoundError extends AppError {
  constructor(resource: string) {
    super(404, 'NOT_FOUND', `${resource} not found`);
  }
}

// Global error handler
app.use((err, req, res, next) => {
  const status = err.statusCode || 500;
  const code = err.code || 'INTERNAL_ERROR';
  
  // Log server errors
  if (status >= 500) {
    logger.error(err);
  }
  
  res.status(status).json({
    error: { code, message: err.message }
  });
});
```

## 8. Logging & Monitoring

### Request Logging
```typescript
// Log every request with context
logger.info('Request', {
  method: req.method,
  path: req.path,
  userId: req.user?.id,
  requestId: req.headers['x-request-id'],
  duration: endTime - startTime
});
```

### Structured Logs
```typescript
// Use structured logging
logger.error('Database query failed', {
  query: 'SELECT * FROM users',
  error: err.message,
  stack: err.stack,
  context: { userId, operation: 'getUser' }
});
```

## 9. Security Checklist

- [ ] Use HTTPS only
- [ ] Implement rate limiting
- [ ] Validate all inputs
- [ ] Use parameterized queries (prevent SQL injection)
- [ ] Sanitize outputs (prevent XSS)
- [ ] Implement proper CORS
- [ ] Never expose stack traces in production
- [ ] Audit sensitive operations
- [ ] Implement request timeouts
- [ ] Use secure session management

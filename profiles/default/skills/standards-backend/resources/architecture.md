# Backend Architecture Patterns

## Layered Architecture

```
┌─────────────────────────────────┐
│         Controllers/Routes      │  ← HTTP handling, validation
├─────────────────────────────────┤
│           Services              │  ← Business logic
├─────────────────────────────────┤
│         Repositories            │  ← Data access
├─────────────────────────────────┤
│           Database              │  ← Storage
└─────────────────────────────────┘
```

### Layer Responsibilities

**Controllers**: Request parsing, input validation, response formatting
**Services**: Business logic, orchestration, transaction boundaries
**Repositories**: Data access, query building, caching

## Project Structure

```
src/
├── config/           # Configuration loading
├── controllers/      # Route handlers
├── services/         # Business logic
├── repositories/     # Data access
├── models/           # Data types/schemas
├── middleware/       # Express/Koa middleware
├── utils/            # Shared utilities
├── jobs/             # Background workers
└── index.ts          # Entry point
```

## Dependency Injection

```typescript
// Define interface
interface UserRepository {
  findById(id: string): Promise<User | null>;
}

// Inject dependencies
class UserService {
  constructor(private userRepo: UserRepository) {}
  
  async getUser(id: string) {
    return this.userRepo.findById(id);
  }
}

// Wire up at composition root
const userRepo = new PostgresUserRepository(db);
const userService = new UserService(userRepo);
```

## API Design

### RESTful Routes
```
GET    /users          # List users
POST   /users          # Create user
GET    /users/:id      # Get user
PUT    /users/:id      # Update user
DELETE /users/:id      # Delete user
GET    /users/:id/orders  # Nested resource
```

### Response Format
```json
{
  "data": { "id": "123", "name": "John" },
  "meta": { "requestId": "abc-123" }
}

{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "details": [{ "field": "email", "message": "Must be valid email" }]
  }
}
```

## Middleware Pipeline

```javascript
app.use(requestId());       // Add request ID
app.use(logger());          // Log requests
app.use(authenticate());    // Verify auth token
app.use(rateLimit());       // Rate limiting
app.use(routes);            // Route handlers
app.use(errorHandler());    // Catch errors
```

## Configuration Pattern

```typescript
const config = {
  server: {
    port: env.PORT || 3000,
    host: env.HOST || '0.0.0.0',
  },
  database: {
    url: env.DATABASE_URL,
    poolSize: parseInt(env.DB_POOL_SIZE, 10) || 10,
  },
  auth: {
    jwtSecret: env.JWT_SECRET,
    tokenExpiry: '1h',
  },
};

// Validate required config at startup
const required = ['database.url', 'auth.jwtSecret'];
validateConfig(config, required);
```

## Health Checks

```javascript
app.get('/health', async (req, res) => {
  const checks = {
    database: await checkDatabase(),
    redis: await checkRedis(),
    external: await checkExternalApi(),
  };
  
  const healthy = Object.values(checks).every(c => c.status === 'ok');
  res.status(healthy ? 200 : 503).json({ status: healthy ? 'ok' : 'degraded', checks });
});
```

## Graceful Shutdown

```javascript
process.on('SIGTERM', async () => {
  logger.info('Shutting down...');
  server.close();              // Stop accepting requests
  await jobQueue.close();      // Finish current jobs
  await db.end();              // Close DB connections
  process.exit(0);
});
```

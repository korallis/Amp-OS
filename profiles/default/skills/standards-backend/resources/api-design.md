# API Design Patterns

Comprehensive API design standards for 2025 TypeScript applications.

## REST Endpoint Conventions

### URL Structure

```
# Resource collections (plural nouns)
GET    /api/projects              # List projects
POST   /api/projects              # Create project
GET    /api/projects/:id          # Get single project
PATCH  /api/projects/:id          # Update project
DELETE /api/projects/:id          # Delete project

# Nested resources
GET    /api/projects/:id/documents
POST   /api/projects/:id/documents
GET    /api/projects/:id/documents/:docId

# Actions (use verbs for non-CRUD operations)
POST   /api/projects/:id/archive
POST   /api/projects/:id/duplicate
POST   /api/auth/refresh-token

# Filtering, sorting, pagination via query params
GET    /api/projects?status=active&sort=-createdAt&page=2&limit=20

# Search
GET    /api/projects/search?q=keyword
```

### HTTP Methods

| Method | Usage | Idempotent | Safe |
|--------|-------|------------|------|
| GET | Retrieve resources | Yes | Yes |
| POST | Create resource / Actions | No | No |
| PUT | Full replacement | Yes | No |
| PATCH | Partial update | Yes | No |
| DELETE | Remove resource | Yes | No |

### URL Naming Rules

1. Use lowercase with hyphens: `/api/user-settings` not `/api/userSettings`
2. Use plural nouns for collections: `/api/users` not `/api/user`
3. Use resource IDs in path: `/api/users/:id` not `/api/users?id=123`
4. Avoid deep nesting (max 2 levels): `/api/projects/:id/documents` ✓
5. Version in URL or header: `/api/v1/projects` or `Accept: application/vnd.api.v1+json`

---

## Response Format Standards

### Success Response

```typescript
// Single resource
{
  "success": true,
  "data": {
    "id": "proj_123",
    "name": "My Project",
    "status": "active",
    "createdAt": "2025-01-15T10:30:00Z",
    "updatedAt": "2025-01-15T10:30:00Z"
  }
}

// Collection with pagination
{
  "success": true,
  "data": [
    { "id": "proj_123", "name": "Project 1" },
    { "id": "proj_456", "name": "Project 2" }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "totalPages": 3,
    "hasNext": true,
    "hasPrev": false
  }
}

// Empty collection (not null)
{
  "success": true,
  "data": [],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 0,
    "totalPages": 0,
    "hasNext": false,
    "hasPrev": false
  }
}
```

### Error Response

```typescript
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The request contains invalid data",
    "details": {
      "formErrors": [],
      "fieldErrors": {
        "email": ["Invalid email format"],
        "name": ["Name is required", "Name must be at least 2 characters"]
      }
    },
    "requestId": "req_abc123"  // For debugging
  }
}

// Simple error
{
  "success": false,
  "error": {
    "code": "NOT_FOUND",
    "message": "Project not found"
  }
}
```

### TypeScript Types

```typescript
// types/api.ts
export type ApiSuccess<T> = {
  success: true;
  data: T;
};

export type ApiSuccessWithPagination<T> = {
  success: true;
  data: T[];
  pagination: Pagination;
};

export type ApiError = {
  success: false;
  error: {
    code: string;
    message: string;
    details?: unknown;
    requestId?: string;
  };
};

export type ApiResponse<T> = ApiSuccess<T> | ApiError;

export type Pagination = {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
  hasNext: boolean;
  hasPrev: boolean;
};
```

---

## Status Code Usage

### Success Codes (2xx)

| Code | Name | When to Use |
|------|------|-------------|
| 200 | OK | GET success, PATCH/PUT success with body |
| 201 | Created | POST created new resource |
| 202 | Accepted | Async operation started |
| 204 | No Content | DELETE success, PATCH with no body |

### Client Error Codes (4xx)

| Code | Name | When to Use |
|------|------|-------------|
| 400 | Bad Request | Invalid JSON, validation errors |
| 401 | Unauthorized | Missing or invalid auth token |
| 403 | Forbidden | Valid auth but insufficient permissions |
| 404 | Not Found | Resource doesn't exist |
| 405 | Method Not Allowed | Wrong HTTP method |
| 409 | Conflict | Duplicate resource, version conflict |
| 422 | Unprocessable Entity | Semantic errors (valid JSON, invalid logic) |
| 429 | Too Many Requests | Rate limit exceeded |

### Server Error Codes (5xx)

| Code | Name | When to Use |
|------|------|-------------|
| 500 | Internal Server Error | Unexpected server errors |
| 502 | Bad Gateway | Upstream service failure |
| 503 | Service Unavailable | Maintenance, overload |
| 504 | Gateway Timeout | Upstream timeout |

### Implementation

```typescript
// lib/api/status.ts
export const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  ACCEPTED: 202,
  NO_CONTENT: 204,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  UNPROCESSABLE_ENTITY: 422,
  TOO_MANY_REQUESTS: 429,
  INTERNAL_SERVER_ERROR: 500,
  SERVICE_UNAVAILABLE: 503,
} as const;

export const ERROR_CODES = {
  VALIDATION_ERROR: { status: 400, message: "Validation failed" },
  UNAUTHORIZED: { status: 401, message: "Authentication required" },
  FORBIDDEN: { status: 403, message: "Access denied" },
  NOT_FOUND: { status: 404, message: "Resource not found" },
  CONFLICT: { status: 409, message: "Resource conflict" },
  RATE_LIMITED: { status: 429, message: "Too many requests" },
  INTERNAL_ERROR: { status: 500, message: "Internal server error" },
} as const;
```

---

## Error Handling Patterns

### Centralized Error Handler

```typescript
// lib/api/errors.ts
export class ApiError extends Error {
  constructor(
    public code: string,
    public statusCode: number,
    message: string,
    public details?: unknown
  ) {
    super(message);
    this.name = "ApiError";
  }

  static badRequest(message: string, details?: unknown) {
    return new ApiError("BAD_REQUEST", 400, message, details);
  }

  static unauthorized(message = "Authentication required") {
    return new ApiError("UNAUTHORIZED", 401, message);
  }

  static forbidden(message = "Access denied") {
    return new ApiError("FORBIDDEN", 403, message);
  }

  static notFound(resource = "Resource") {
    return new ApiError("NOT_FOUND", 404, `${resource} not found`);
  }

  static conflict(message: string) {
    return new ApiError("CONFLICT", 409, message);
  }

  static rateLimited(retryAfter?: number) {
    return new ApiError(
      "RATE_LIMITED",
      429,
      "Too many requests",
      retryAfter ? { retryAfter } : undefined
    );
  }

  static internal(message = "An unexpected error occurred") {
    return new ApiError("INTERNAL_ERROR", 500, message);
  }
}

// Error handler middleware
export function handleError(error: unknown): NextResponse {
  // Generate request ID for tracking
  const requestId = crypto.randomUUID().slice(0, 8);

  // Log full error server-side
  console.error(`[${requestId}]`, error);

  if (error instanceof ApiError) {
    return NextResponse.json(
      {
        success: false,
        error: {
          code: error.code,
          message: error.message,
          details: error.details,
          requestId,
        },
      },
      { status: error.statusCode }
    );
  }

  if (error instanceof ZodError) {
    return NextResponse.json(
      {
        success: false,
        error: {
          code: "VALIDATION_ERROR",
          message: "Invalid request data",
          details: error.flatten(),
          requestId,
        },
      },
      { status: 400 }
    );
  }

  // Don't leak internal error details in production
  return NextResponse.json(
    {
      success: false,
      error: {
        code: "INTERNAL_ERROR",
        message:
          process.env.NODE_ENV === "development" && error instanceof Error
            ? error.message
            : "An unexpected error occurred",
        requestId,
      },
    },
    { status: 500 }
  );
}
```

### Route Handler Pattern

```typescript
// lib/api/handler.ts
import { NextRequest, NextResponse } from "next/server";
import { auth } from "@clerk/nextjs/server";
import { handleError, ApiError } from "./errors";

type Handler<T> = (
  req: NextRequest,
  context: {
    params: Record<string, string>;
    userId: string;
  }
) => Promise<T>;

export function withAuth<T>(handler: Handler<T>) {
  return async (req: NextRequest, { params }: { params: Record<string, string> }) => {
    try {
      const { userId } = await auth();
      if (!userId) {
        throw ApiError.unauthorized();
      }

      const result = await handler(req, { params, userId });
      
      if (result === null || result === undefined) {
        return new NextResponse(null, { status: 204 });
      }
      
      return NextResponse.json({ success: true, data: result });
    } catch (error) {
      return handleError(error);
    }
  };
}

// Usage
// app/api/projects/[id]/route.ts
import { withAuth } from "@/lib/api/handler";
import { ApiError } from "@/lib/api/errors";

export const GET = withAuth(async (req, { params, userId }) => {
  const project = await db.query.projects.findFirst({
    where: eq(projects.id, params.id),
  });

  if (!project) {
    throw ApiError.notFound("Project");
  }

  if (project.userId !== userId && !project.isPublic) {
    throw ApiError.forbidden();
  }

  return project;
});
```

---

## Pagination Patterns

### Offset-Based Pagination

```typescript
// Best for: Traditional lists, known total count, page jumping
// Limitations: Slow for large offsets, inconsistent with real-time data

const paginationSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

export async function listWithOffsetPagination(
  userId: string,
  { page, limit }: { page: number; limit: number }
) {
  const offset = (page - 1) * limit;

  const [items, [{ count }]] = await Promise.all([
    db.query.projects.findMany({
      where: eq(projects.userId, userId),
      orderBy: [desc(projects.createdAt)],
      limit,
      offset,
    }),
    db.select({ count: sql<number>`count(*)` })
      .from(projects)
      .where(eq(projects.userId, userId)),
  ]);

  const total = Number(count);
  const totalPages = Math.ceil(total / limit);

  return {
    data: items,
    pagination: {
      page,
      limit,
      total,
      totalPages,
      hasNext: page < totalPages,
      hasPrev: page > 1,
    },
  };
}
```

### Cursor-Based Pagination

```typescript
// Best for: Infinite scroll, real-time data, large datasets
// Limitations: No page jumping, requires stable sort field

const cursorSchema = z.object({
  cursor: z.string().optional(),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

export async function listWithCursorPagination(
  userId: string,
  { cursor, limit }: { cursor?: string; limit: number }
) {
  // Decode cursor (base64 encoded: `${createdAt}:${id}`)
  let cursorData: { createdAt: Date; id: string } | null = null;
  if (cursor) {
    try {
      const decoded = Buffer.from(cursor, "base64").toString();
      const [timestamp, id] = decoded.split(":");
      cursorData = { createdAt: new Date(timestamp), id };
    } catch {
      throw ApiError.badRequest("Invalid cursor");
    }
  }

  // Fetch one extra to determine hasNext
  const items = await db.query.projects.findMany({
    where: and(
      eq(projects.userId, userId),
      cursorData
        ? or(
            lt(projects.createdAt, cursorData.createdAt),
            and(
              eq(projects.createdAt, cursorData.createdAt),
              lt(projects.id, cursorData.id)
            )
          )
        : undefined
    ),
    orderBy: [desc(projects.createdAt), desc(projects.id)],
    limit: limit + 1,
  });

  const hasNext = items.length > limit;
  const data = hasNext ? items.slice(0, -1) : items;
  
  const nextCursor = hasNext && data.length > 0
    ? Buffer.from(
        `${data[data.length - 1].createdAt.toISOString()}:${data[data.length - 1].id}`
      ).toString("base64")
    : null;

  return {
    data,
    pagination: {
      nextCursor,
      hasNext,
      limit,
    },
  };
}
```

### Convex Pagination

```typescript
// Built-in cursor-based pagination
export const list = query({
  args: {
    paginationOpts: paginationOptsValidator,
    status: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const userId = await getAuthUserId(ctx);
    if (!userId) throw new Error("Unauthorized");

    return await ctx.db
      .query("projects")
      .withIndex("by_user_status", (q) =>
        args.status
          ? q.eq("userId", userId).eq("status", args.status)
          : q.eq("userId", userId)
      )
      .order("desc")
      .paginate(args.paginationOpts);
  },
});
```

---

## Rate Limiting

### Token Bucket Algorithm

```typescript
// lib/rate-limit.ts
import { Ratelimit } from "@upstash/ratelimit";
import { Redis } from "@upstash/redis";

const redis = new Redis({
  url: process.env.UPSTASH_REDIS_URL!,
  token: process.env.UPSTASH_REDIS_TOKEN!,
});

// Different rate limiters for different use cases
export const rateLimiters = {
  // General API: 100 requests per 10 seconds
  api: new Ratelimit({
    redis,
    limiter: Ratelimit.slidingWindow(100, "10 s"),
    analytics: true,
    prefix: "ratelimit:api",
  }),

  // Auth endpoints: 5 requests per minute
  auth: new Ratelimit({
    redis,
    limiter: Ratelimit.slidingWindow(5, "1 m"),
    analytics: true,
    prefix: "ratelimit:auth",
  }),

  // Expensive operations: 10 per hour
  expensive: new Ratelimit({
    redis,
    limiter: Ratelimit.slidingWindow(10, "1 h"),
    analytics: true,
    prefix: "ratelimit:expensive",
  }),

  // AI/LLM calls: 20 per minute
  ai: new Ratelimit({
    redis,
    limiter: Ratelimit.tokenBucket(20, "1 m", 20),
    analytics: true,
    prefix: "ratelimit:ai",
  }),
};

export async function checkRateLimit(
  limiter: keyof typeof rateLimiters,
  identifier: string
): Promise<{
  success: boolean;
  limit: number;
  remaining: number;
  reset: number;
}> {
  const { success, limit, remaining, reset } = await rateLimiters[limiter].limit(
    identifier
  );

  return { success, limit, remaining, reset };
}
```

### Middleware Integration

```typescript
// middleware/rate-limit.ts
import { NextRequest, NextResponse } from "next/server";
import { checkRateLimit } from "@/lib/rate-limit";

export async function withRateLimit(
  req: NextRequest,
  limiter: "api" | "auth" | "expensive" | "ai" = "api"
) {
  // Identify by user ID (auth'd) or IP (unauth'd)
  const identifier =
    req.headers.get("x-user-id") ??
    req.headers.get("x-forwarded-for")?.split(",")[0] ??
    req.ip ??
    "anonymous";

  const { success, limit, remaining, reset } = await checkRateLimit(
    limiter,
    identifier
  );

  // Add rate limit headers
  const headers = new Headers();
  headers.set("X-RateLimit-Limit", limit.toString());
  headers.set("X-RateLimit-Remaining", remaining.toString());
  headers.set("X-RateLimit-Reset", reset.toString());

  if (!success) {
    return NextResponse.json(
      {
        success: false,
        error: {
          code: "RATE_LIMITED",
          message: "Too many requests",
          details: { retryAfter: Math.ceil((reset - Date.now()) / 1000) },
        },
      },
      {
        status: 429,
        headers: {
          ...Object.fromEntries(headers),
          "Retry-After": Math.ceil((reset - Date.now()) / 1000).toString(),
        },
      }
    );
  }

  return { headers };
}

// Usage in route
export async function POST(req: NextRequest) {
  const rateLimitResult = await withRateLimit(req, "expensive");
  if (rateLimitResult instanceof NextResponse) {
    return rateLimitResult;
  }

  // Continue with request...
  const response = NextResponse.json({ success: true, data: result });
  rateLimitResult.headers.forEach((value, key) => {
    response.headers.set(key, value);
  });
  return response;
}
```

---

## Security Best Practices

### Input Validation

```typescript
// Always validate ALL input with Zod
import { z } from "zod";

// Strict schemas - no unknown keys
const createUserSchema = z.object({
  email: z.string().email().toLowerCase().trim(),
  name: z.string().min(1).max(100).trim(),
  role: z.enum(["user", "admin"]).default("user"),
}).strict();

// Validate path params
const idParamSchema = z.object({
  id: z.string().uuid(),
});

// Validate query params with coercion
const querySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  search: z.string().max(200).optional(),
  status: z.enum(["active", "inactive"]).optional(),
});
```

### SQL Injection Prevention

```typescript
// ❌ NEVER interpolate user input
const BAD = `SELECT * FROM users WHERE id = '${userId}'`;

// ✅ Use parameterized queries (Drizzle)
const GOOD = db.select().from(users).where(eq(users.id, userId));

// ✅ Use parameterized queries (Prisma)
const GOOD = prisma.user.findUnique({ where: { id: userId } });

// ✅ Use prepared statements
const prepared = db
  .select()
  .from(users)
  .where(eq(users.email, sql.placeholder("email")))
  .prepare("get_user_by_email");

await prepared.execute({ email: userInput });
```

### XSS Prevention

```typescript
// Sanitize HTML content before storage
import DOMPurify from "isomorphic-dompurify";

const sanitizedHtml = DOMPurify.sanitize(userInput, {
  ALLOWED_TAGS: ["b", "i", "em", "strong", "a", "p", "br"],
  ALLOWED_ATTR: ["href"],
});

// Set security headers
// next.config.js
const securityHeaders = [
  {
    key: "X-Content-Type-Options",
    value: "nosniff",
  },
  {
    key: "X-Frame-Options",
    value: "DENY",
  },
  {
    key: "X-XSS-Protection",
    value: "1; mode=block",
  },
  {
    key: "Content-Security-Policy",
    value: "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline';",
  },
];
```

### Authentication Security

```typescript
// Secure session configuration (Auth.js)
export const { handlers, auth } = NextAuth({
  session: {
    strategy: "jwt",
    maxAge: 30 * 24 * 60 * 60, // 30 days
  },
  cookies: {
    sessionToken: {
      name: `__Secure-authjs.session-token`,
      options: {
        httpOnly: true,
        sameSite: "lax",
        path: "/",
        secure: process.env.NODE_ENV === "production",
      },
    },
  },
});

// Always verify ownership before mutations
export async function updateProject(projectId: string, userId: string, data: unknown) {
  const project = await db.query.projects.findFirst({
    where: and(
      eq(projects.id, projectId),
      eq(projects.userId, userId) // Ownership check
    ),
  });

  if (!project) {
    throw ApiError.notFound("Project");
  }

  // Proceed with update
}
```

### Environment Variables

```typescript
// lib/env.ts - Validate env vars at startup
import { z } from "zod";

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  CLERK_SECRET_KEY: z.string().min(1),
  STRIPE_SECRET_KEY: z.string().startsWith("sk_"),
  STRIPE_WEBHOOK_SECRET: z.string().startsWith("whsec_"),
  NODE_ENV: z.enum(["development", "production", "test"]).default("development"),
});

export const env = envSchema.parse(process.env);

// Never log secrets
console.log("Config loaded:", {
  nodeEnv: env.NODE_ENV,
  hasStripeKey: !!env.STRIPE_SECRET_KEY,
  // ❌ NEVER: console.log(env.STRIPE_SECRET_KEY)
});
```

---

## Webhook Patterns

### Signature Verification

```typescript
// Generic webhook handler
// lib/webhooks/verify.ts
import { createHmac, timingSafeEqual } from "crypto";

export function verifyWebhookSignature(
  payload: string,
  signature: string,
  secret: string,
  options: {
    algorithm?: "sha256" | "sha1";
    encoding?: "hex" | "base64";
    prefix?: string;
  } = {}
): boolean {
  const { algorithm = "sha256", encoding = "hex", prefix = "" } = options;

  const expectedSignature = createHmac(algorithm, secret)
    .update(payload, "utf8")
    .digest(encoding);

  const expected = prefix + expectedSignature;

  if (signature.length !== expected.length) {
    return false;
  }

  return timingSafeEqual(Buffer.from(signature), Buffer.from(expected));
}

// Stripe webhook (uses their SDK)
import Stripe from "stripe";

export async function verifyStripeWebhook(
  body: string,
  signature: string
): Promise<Stripe.Event> {
  return stripe.webhooks.constructEvent(
    body,
    signature,
    process.env.STRIPE_WEBHOOK_SECRET!
  );
}

// Clerk webhook
import { Webhook } from "svix";

export function verifyClerkWebhook(
  body: string,
  headers: { svix_id: string; svix_timestamp: string; svix_signature: string }
) {
  const wh = new Webhook(process.env.CLERK_WEBHOOK_SECRET!);
  return wh.verify(body, {
    "svix-id": headers.svix_id,
    "svix-timestamp": headers.svix_timestamp,
    "svix-signature": headers.svix_signature,
  });
}
```

### Idempotent Webhook Processing

```typescript
// Store processed webhook IDs to prevent duplicate processing
// db/schema.ts
export const webhookEvents = pgTable("webhook_events", {
  id: varchar("id", { length: 255 }).primaryKey(), // Webhook event ID
  source: varchar("source", { length: 50 }).notNull(), // "stripe", "clerk", etc.
  type: varchar("type", { length: 100 }).notNull(),
  processedAt: timestamp("processed_at").defaultNow().notNull(),
  payload: jsonb("payload"),
});

// lib/webhooks/idempotent.ts
export async function processWebhookIdempotent<T>(
  eventId: string,
  source: string,
  type: string,
  handler: () => Promise<T>
): Promise<{ processed: boolean; result?: T }> {
  // Check if already processed
  const existing = await db.query.webhookEvents.findFirst({
    where: and(
      eq(webhookEvents.id, eventId),
      eq(webhookEvents.source, source)
    ),
  });

  if (existing) {
    console.log(`Webhook ${eventId} already processed, skipping`);
    return { processed: false };
  }

  // Process and record
  const result = await db.transaction(async (tx) => {
    // Record event first (prevents race conditions)
    await tx.insert(webhookEvents).values({
      id: eventId,
      source,
      type,
    });

    // Process
    return handler();
  });

  return { processed: true, result };
}

// Usage
export async function POST(req: Request) {
  const event = await verifyStripeWebhook(body, signature);

  const { processed } = await processWebhookIdempotent(
    event.id,
    "stripe",
    event.type,
    async () => {
      switch (event.type) {
        case "checkout.session.completed":
          await handleCheckoutComplete(event.data.object);
          break;
        // ...
      }
    }
  );

  return NextResponse.json({ received: true, processed });
}
```

### Webhook Retry Handling

```typescript
// Return appropriate status codes for webhook providers
export async function POST(req: Request) {
  try {
    const event = await verifyWebhook(body, signature);
    await processEvent(event);
    
    // 200: Success, don't retry
    return new Response(null, { status: 200 });
  } catch (error) {
    if (error instanceof SignatureVerificationError) {
      // 400: Bad request, don't retry
      return new Response("Invalid signature", { status: 400 });
    }

    if (error instanceof TransientError) {
      // 500: Temporary failure, please retry
      return new Response("Temporary error", { status: 500 });
    }

    // Log and acknowledge to prevent infinite retries
    console.error("Webhook processing failed:", error);
    return new Response("Error logged", { status: 200 });
  }
}
```

---

## Database Connection Patterns

### Connection Pooling

```typescript
// Serverless: Use HTTP connections (Neon)
import { neon } from "@neondatabase/serverless";
const sql = neon(process.env.DATABASE_URL!);

// Traditional: Use connection pool (pg)
import { Pool } from "pg";

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20, // Maximum connections
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Prisma: Connection pool via URL params
// DATABASE_URL="postgresql://...?connection_limit=5&pool_timeout=10"
```

### Serverless Database Considerations

```typescript
// Edge Runtime (Vercel Edge Functions, Cloudflare Workers)
// - Use HTTP-based connections (Neon HTTP, PlanetScale HTTP)
// - No persistent connections
// - Cold start optimization

// Neon: Use HTTP adapter for edge
import { neon } from "@neondatabase/serverless";
export const runtime = "edge";

const sql = neon(process.env.DATABASE_URL!);
const result = await sql`SELECT * FROM users WHERE id = ${userId}`;

// Node.js Runtime (API routes, Server Components)
// - Can use WebSocket/TCP connections
// - Connection pooling works
// - Use for complex queries, transactions

// Neon: Use pool for Node.js
import { Pool } from "@neondatabase/serverless";
const pool = new Pool({ connectionString: process.env.DATABASE_URL });
```

### Transaction Patterns

```typescript
// Drizzle transaction
await db.transaction(async (tx) => {
  const user = await tx.insert(users).values({ ... }).returning();
  await tx.insert(accounts).values({ userId: user[0].id, ... });
});

// Prisma transaction
await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({ data: { ... } });
  await tx.account.create({ data: { userId: user.id, ... } });
});

// Prisma interactive transaction with timeout
await prisma.$transaction(
  async (tx) => {
    // Long-running operations
  },
  {
    maxWait: 5000, // Wait for connection
    timeout: 10000, // Transaction timeout
  }
);

// Convex: Mutations are automatically transactional
export const createWithRelated = mutation({
  handler: async (ctx, args) => {
    const userId = await ctx.db.insert("users", { ... });
    await ctx.db.insert("accounts", { userId, ... });
    // Automatically atomic
  },
});
```

### Health Checks

```typescript
// app/api/health/route.ts
import { db } from "@/db";
import { sql } from "drizzle-orm";

export async function GET() {
  const checks: Record<string, { status: "ok" | "error"; latency?: number }> = {};

  // Database check
  const dbStart = Date.now();
  try {
    await db.execute(sql`SELECT 1`);
    checks.database = { status: "ok", latency: Date.now() - dbStart };
  } catch {
    checks.database = { status: "error" };
  }

  // Redis check (if applicable)
  const redisStart = Date.now();
  try {
    await redis.ping();
    checks.redis = { status: "ok", latency: Date.now() - redisStart };
  } catch {
    checks.redis = { status: "error" };
  }

  const allHealthy = Object.values(checks).every((c) => c.status === "ok");

  return NextResponse.json(
    {
      status: allHealthy ? "healthy" : "degraded",
      checks,
      timestamp: new Date().toISOString(),
    },
    { status: allHealthy ? 200 : 503 }
  );
}
```

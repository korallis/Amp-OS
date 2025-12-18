---
description: API and backend standards
globs: ["**/api/**", "**/routes/**", "**/handlers/**", "**/controllers/**", "**/server/**", "!**/node_modules/**", "!**/dist/**", "!**/build/**", "!**/.next/**"]
---

# API Standards

> **Rule Precedence**: Security > Correctness/Types > Testing > Performance > Style

## Route Handler Structure

```typescript
// Next.js App Router example
import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';

const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
});

export async function POST(request: NextRequest) {
  try {
    // 1. Parse and validate input
    const body = await request.json();
    const data = createUserSchema.parse(body);
    
    // 2. Business logic
    const user = await userService.create(data);
    
    // 3. Return response
    return NextResponse.json(user, { status: 201 });
    
  } catch (error) {
    // 4. Handle errors
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: 'Validation failed', details: error.errors },
        { status: 400 }
      );
    }
    
    console.error('Create user failed:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
```

## Response Format

```typescript
// Success responses
{ data: T }                           // Single item
{ data: T[], meta: { total, page } }  // List with pagination

// Error responses
{ 
  error: string,           // Human-readable message
  code?: string,           // Machine-readable code (e.g., "USER_NOT_FOUND")
  details?: unknown        // Additional context (validation errors, etc.)
}
```

## Status Codes

| Code | Use Case |
|------|----------|
| 200 | Success (GET, PUT, PATCH) |
| 201 | Created (POST) |
| 204 | No Content (DELETE) |
| 400 | Bad Request (validation failed) |
| 401 | Unauthorized (not logged in) |
| 403 | Forbidden (logged in, no permission) |
| 404 | Not Found |
| 409 | Conflict (duplicate, version mismatch) |
| 422 | Unprocessable Entity (business rule violation) |
| 500 | Internal Server Error |

## Authentication

- Verify auth on every protected route
- Extract user from session/token early
- Return 401 for missing/invalid auth
- Return 403 for valid auth but insufficient permissions

```typescript
export async function GET(request: NextRequest) {
  const session = await getServerSession();
  
  if (!session?.user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }
  
  const resource = await getResource(params.id);
  
  if (resource.ownerId !== session.user.id) {
    return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
  }
  
  return NextResponse.json({ data: resource });
}
```

## Rate Limiting

- Implement rate limiting on public endpoints
- Use sliding window or token bucket algorithms
- Return 429 with Retry-After header

## Logging

- Log request ID for tracing
- Log errors with context (user, endpoint, payload shape)
- Don't log sensitive data (passwords, tokens, PII)

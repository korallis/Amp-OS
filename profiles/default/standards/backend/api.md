# API Design

Principles for designing consistent, maintainable, and developer-friendly APIs.

## Core Principles

### 1. Consistency Over Cleverness
- Use predictable naming conventions across all endpoints
- Follow established HTTP semantics (GET reads, POST creates, etc.)
- Return consistent response shapes and error formats

### 2. Resource-Oriented Design
- Model endpoints around resources, not actions
- Use nouns for resource names: `/users`, `/orders`, `/products`
- Nest resources to express relationships: `/users/{id}/orders`

### 3. Explicit Over Implicit
- Version APIs explicitly: `/api/v1/`
- Document all parameters, including optional ones
- Return meaningful status codes (don't use 200 for errors)

### 4. Fail Gracefully
- Provide actionable error messages
- Include error codes for programmatic handling
- Never expose internal implementation details in errors

### 5. Design for Evolution
- Add fields, never remove (without deprecation)
- Use feature flags for breaking changes
- Support pagination from day one

## Response Standards

| Scenario | Status | Body Shape |
|----------|--------|------------|
| Success (single) | 200 | `{ data: {...} }` |
| Success (list) | 200 | `{ data: [...], meta: {...} }` |
| Created | 201 | `{ data: {...} }` |
| No content | 204 | Empty |
| Validation error | 400 | `{ error: { code, message, details } }` |
| Unauthorized | 401 | `{ error: { code, message } }` |
| Not found | 404 | `{ error: { code, message } }` |
| Server error | 500 | `{ error: { code, message } }` |

## Naming Conventions

```
GET    /resources          → List
GET    /resources/:id      → Read
POST   /resources          → Create
PUT    /resources/:id      → Replace
PATCH  /resources/:id      → Update
DELETE /resources/:id      → Delete

POST   /resources/:id/actions/verb  → Custom actions
```

## Technology-Specific Patterns

For implementation details, see:
- [API Design Patterns](../../skills/standards-backend/resources/api-design.md)
- [tRPC Implementation](../../skills/standards-backend/resources/trpc.md)
- [Architecture Patterns](../../skills/standards-backend/resources/architecture.md)

## Quick Checklist

- [ ] All endpoints use consistent naming
- [ ] Error responses include actionable messages
- [ ] Pagination implemented for list endpoints
- [ ] Authentication/authorization documented
- [ ] Rate limiting considered
- [ ] API versioned appropriately

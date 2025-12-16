---
name: amp-os-standards-backend
description: Backend API and server-side development standards. Load when implementing APIs, database operations, or server logic to ensure consistent endpoint design, error responses, and data patterns.
---

# Backend Standards

Standards for API design, database patterns, and server-side code.

## When to Use
- Implementing API endpoints
- Designing database schemas
- Writing server-side business logic
- Creating background jobs or services

## Standards Reference

See [api-design.md](resources/api-design.md) for complete guidelines.

## Quick Reference

### REST Endpoints
```
GET    /resources          # List
GET    /resources/:id      # Get one
POST   /resources          # Create
PUT    /resources/:id      # Replace
PATCH  /resources/:id      # Update
DELETE /resources/:id      # Delete
```

### Response Format
```json
{
  "data": {},
  "meta": { "page": 1, "total": 100 },
  "error": null
}
```

### Status Codes
- 200: Success
- 201: Created
- 400: Bad Request
- 401: Unauthorized
- 403: Forbidden
- 404: Not Found
- 500: Server Error

### Database
- Use migrations for schema changes
- Index foreign keys and query fields
- Soft delete for user data
- Validate at DB level too

## Amp Tools to Use
- `finder` - Find existing API patterns
- `oracle` - Complex architecture decisions

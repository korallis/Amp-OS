---
title: "[Feature Name]"
status: draft
created: YYYY-MM-DD
updated: YYYY-MM-DD
author: ""
---

# [Feature Name] Specification

## Goal

[A clear, single-sentence statement of what this feature achieves and why it matters]

---

## User Stories

From requirements:
- As a [user type], I want [action] so that [benefit]
- As a [user type], I want [action] so that [benefit]

---

## Functional Requirements

### Must Have
1. [Requirement 1]
2. [Requirement 2]

### Should Have
1. [Requirement 3]

---

## Technical Approach

### Architecture Overview

```
[Diagram or description of how components interact]

┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Client    │────▶│    API      │────▶│  Database   │
└─────────────┘     └─────────────┘     └─────────────┘
```

### Components

#### Component 1: [Name]

**Purpose:** [What this component does]

**Responsibilities:**
- [Responsibility 1]
- [Responsibility 2]

**Interface:**
```typescript
interface ComponentName {
  method1(param: Type): Promise<ReturnType>;
  method2(param: Type): ReturnType;
}
```

#### Component 2: [Name]

**Purpose:** [What this component does]

**Responsibilities:**
- [Responsibility 1]
- [Responsibility 2]

---

### Data Model

```typescript
// Main entity
interface Entity {
  id: string;
  field1: string;
  field2: number;
  createdAt: Date;
  updatedAt: Date;
}

// Related entity
interface RelatedEntity {
  id: string;
  entityId: string;
  // ...
}
```

**Database Schema:**
```sql
CREATE TABLE entities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  field1 VARCHAR(255) NOT NULL,
  field2 INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

---

### API Design

#### Endpoint 1: Create Entity

```
POST /api/entities

Request:
{
  "field1": "string",
  "field2": 123
}

Response (201):
{
  "data": {
    "id": "uuid",
    "field1": "string",
    "field2": 123,
    "createdAt": "ISO-8601"
  }
}

Errors:
- 400: Validation error
- 401: Not authenticated
- 403: Not authorized
```

#### Endpoint 2: Get Entity

```
GET /api/entities/:id

Response (200):
{
  "data": { ... }
}

Errors:
- 404: Entity not found
```

---

### UI Components

#### Component: [Name]

**Props:**
```typescript
interface Props {
  prop1: string;
  prop2?: number;
  onAction: (id: string) => void;
}
```

**States:**
- Loading: [description]
- Empty: [description]
- Error: [description]
- Success: [description]

**User Flow:**
1. User does X
2. System responds with Y
3. User sees Z

---

## Error Handling

| Error Case | Code | User Message | Action |
|------------|------|--------------|--------|
| Invalid input | 400 | "Please check your input" | Show validation errors |
| Not found | 404 | "Resource not found" | Redirect or show error |
| Server error | 500 | "Something went wrong" | Log and show generic error |

---

## Testing Strategy

### Unit Tests
- [ ] Component 1 business logic
- [ ] Component 2 validation
- [ ] Utility functions

### Integration Tests
- [ ] API endpoint tests
- [ ] Database operations
- [ ] Service interactions

### E2E Tests
- [ ] Happy path user flow
- [ ] Error handling flow
- [ ] Edge cases

### Coverage Target
- Statements: 80%
- Branches: 75%
- Critical paths: 100%

---

## Security Considerations

- [ ] Input validation with Zod
- [ ] Authentication required
- [ ] Authorization checks
- [ ] Rate limiting
- [ ] Audit logging

---

## Performance Considerations

- Expected load: [requests/second]
- Response time target: [ms]
- Caching strategy: [description]
- Database indexing: [fields to index]

---

## Migration Plan

If modifying existing functionality:

1. **Phase 1**: [Add new alongside old]
2. **Phase 2**: [Migrate users gradually]
3. **Phase 3**: [Remove old implementation]

---

## Out of Scope

Explicitly NOT part of this spec:
- [Item 1] (planned for future)
- [Item 2] (separate feature)

---

## Open Questions

- [ ] [Question needing resolution]
- [ ] [Design decision to make]

---

## References

- [Requirements Doc](./planning/requirements.md)
- [Related Feature Spec](../related-feature/spec.md)
- [External Documentation](https://...)

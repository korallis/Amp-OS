# Input Validation

Patterns for validating and sanitizing input data.

## Principles

1. **Validate at boundaries** - Check all external input immediately
2. **Fail fast** - Reject invalid data early with clear errors
3. **Whitelist over blacklist** - Define what's allowed, not what's blocked
4. **Never trust input** - All external data is potentially malicious
5. **Validate then transform** - Parse, don't validate

## Validation Boundaries

### Where to Validate
- API endpoints (request bodies, params, headers)
- Form submissions
- Environment variables (at startup)
- External service responses
- File uploads

### Validation Flow
```
Input → Schema Validation → Type Transformation → Business Logic
```

## Validation Patterns

### Schema-Based Validation
```typescript
const UserSchema = z.object({
  email: z.string().email(),
  age: z.number().min(0).max(150),
  role: z.enum(['user', 'admin']),
});

// Parse returns typed data or throws
const user = UserSchema.parse(rawInput);
```

### Custom Type Guards
```typescript
function isValidId(value: unknown): value is string {
  return typeof value === 'string' && 
         value.length > 0 && 
         /^[a-zA-Z0-9-]+$/.test(value);
}
```

### Sanitization
```typescript
function sanitizeString(input: string): string {
  return input.trim().slice(0, MAX_LENGTH);
}
```

## Error Messages

- Be specific about what failed
- Don't leak implementation details
- Provide actionable guidance
- Aggregate multiple errors when possible

```typescript
// Good: "Email must be a valid email address"
// Bad: "Validation failed" or "regex /^.../ did not match"
```

## Detailed Patterns

For implementation-specific patterns, see:
- [Coding Conventions - Type Guards](../../skills/standards-global/resources/coding-conventions.md#type-guards)
- [Common Patterns - Null Safety](../../skills/standards-global/resources/common-patterns.md#null-safety)

## Quick Reference

```
✅ DO                          ❌ AVOID
─────────────────────────────────────────
Schema validation              Manual field checks
Whitelist allowed values       Blacklist bad values
Validate at entry points       Deep validation
Typed parse results            Loose any types
Specific error messages        Generic failures
```

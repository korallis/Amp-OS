# Error Handling

Patterns for robust and consistent error handling.

## Principles

1. **Fail fast** - Detect and report errors early
2. **Fail gracefully** - Never crash without recovery attempt
3. **Be specific** - Use typed errors with context
4. **Handle at boundaries** - Catch errors at appropriate levels
5. **Never swallow errors** - Always log or propagate

## Error Types

### Custom Error Classes
```typescript
class AppError extends Error {
  constructor(
    message: string,
    public code: string,
    public statusCode: number = 500,
    public context?: Record<string, unknown>
  ) {
    super(message);
    this.name = this.constructor.name;
  }
}

class ValidationError extends AppError { /* 400 */ }
class NotFoundError extends AppError { /* 404 */ }
class UnauthorizedError extends AppError { /* 401 */ }
```

## Error Handling Patterns

### Guard Clauses
```typescript
function processUser(user: User | null) {
  if (!user) throw new NotFoundError('User');
  if (!user.isActive) throw new ValidationError('User inactive');
  // Main logic here
}
```

### Try-Catch at Boundaries
```typescript
try {
  await processRequest(data);
} catch (error) {
  if (error instanceof ValidationError) {
    return { status: 400, error: error.message };
  }
  logger.error('Unexpected error', { error });
  return { status: 500, error: 'Internal error' };
}
```

### Result Pattern (Alternative)
```typescript
type Result<T> = 
  | { success: true; data: T }
  | { success: false; error: AppError };
```

## Logging Errors

- Include error context (user, request ID)
- Distinguish operational vs programming errors
- Never log sensitive data
- Use structured logging

## Detailed Patterns

For implementation-specific patterns, see:
- [Common Patterns - Error Handling](../../skills/standards-global/resources/common-patterns.md#error-handling)
- [Coding Conventions - Error Classes](../../skills/standards-global/resources/coding-conventions.md#error-handling-patterns)

## Quick Reference

```
✅ DO                          ❌ AVOID
─────────────────────────────────────────
Typed error classes             Generic Error()
Include error context           Bare error messages
Handle at boundaries            Catch everywhere
Log with structure              console.log(error)
Re-throw unknown errors         Swallow silently
```

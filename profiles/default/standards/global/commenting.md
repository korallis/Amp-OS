# Code Commenting

Guidelines for when and how to write code comments.

## Principles

1. **Code explains what, comments explain why** - Self-documenting code needs fewer comments
2. **Comments are a last resort** - Prefer renaming over commenting unclear code
3. **Keep comments current** - Outdated comments are worse than no comments
4. **Document intent, not mechanics** - Explain decisions, not syntax

## When to Comment

### Always Comment
- **Complex algorithms** - Non-obvious logic or business rules
- **Workarounds** - Why a hack exists (with ticket reference)
- **Edge cases** - Why specific conditions are handled
- **External dependencies** - API quirks or version requirements
- **Public APIs** - Function signatures for libraries

### Never Comment
- What the code literally does
- Obvious operations
- Code that should be renamed instead
- Changelog information (use git)

## Comment Formats

### Single-Line
```
// Calculate tax after applying regional exemptions
const tax = calculateRegionalTax(subtotal, region);
```

### Block Comments
```
/*
 * Retry with exponential backoff because the payment
 * provider rate-limits during peak hours (see TICKET-123)
 */
```

### TODO Format
```
// TODO(username): Description of what needs to be done
// FIXME: Description of known issue
// HACK: Why this workaround exists (link to ticket)
```

## Documentation Comments

For public APIs, document:
- Purpose of the function
- Parameters and their constraints
- Return value and possible errors
- Usage example (if non-obvious)

## Detailed Patterns

For language-specific documentation patterns, see:
- [Communication Style](../../skills/standards-global/resources/communication-style.md)

## Quick Reference

```
✅ GOOD COMMENTS                ❌ BAD COMMENTS
───────────────────────────────────────────────
// Handles edge case where     // Increment counter
// user has no primary email   counter++;

// HACK: API returns 200 on    // Get user
// error, check body instead   const user = getUser();

// Business rule: Premium      // Loop through array
// users get 30-day grace      for (const item of items)
```

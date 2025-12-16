# Communication Style Guidelines

## Core Principles

1. **Be Direct** - State the main point first, then supporting details
2. **Be Concise** - Remove unnecessary words and filler
3. **Be Specific** - Use concrete examples over abstract descriptions
4. **Be Actionable** - Provide clear next steps when applicable

## Code Comments

### Do
- Explain "why" not "what"
- Document non-obvious business logic
- Note performance implications
- Reference tickets/issues for context

### Don't
- Describe obvious operations
- Leave TODO comments without context
- Write essays in comment blocks
- Duplicate information from function names

## Commit Messages

```
<type>(<scope>): <subject>

<body - optional>

<footer - optional>
```

**Types**: feat, fix, docs, style, refactor, test, chore

**Example**:
```
feat(auth): add OAuth2 refresh token rotation

Implements automatic token refresh to prevent session expiration.
Tokens rotate on each use per RFC 6749 recommendations.

Closes #234
```

## Pull Request Descriptions

1. **Summary** - One sentence describing the change
2. **Motivation** - Why this change is needed
3. **Changes** - Bullet list of key modifications
4. **Testing** - How it was verified
5. **Screenshots** - If UI changes (optional)

## Error Messages

**Good**: `Failed to connect to database at localhost:5432 - connection refused`
**Bad**: `Database error occurred`

Include:
- What failed
- Why it failed (if known)
- How to fix it (if applicable)

## Documentation

- Start with a one-sentence summary
- Use examples liberally
- Keep paragraphs short (3-4 sentences max)
- Use headings to enable scanning
- Update docs with code changes

## Code Review Feedback

- Be kind, assume good intent
- Suggest, don't demand: "Consider..." vs "You must..."
- Explain the reasoning behind suggestions
- Acknowledge good patterns you see
- Use "we" not "you" for team standards

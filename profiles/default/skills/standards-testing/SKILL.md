---
name: amp-os-standards-testing
description: Testing patterns and best practices. Load when writing tests to ensure consistent test structure, naming, coverage strategies, and maintainable test code across unit, integration, and e2e tests.
---

# Testing Standards

Standards for writing effective, maintainable tests.

## When to Use
- Writing any new tests
- Reviewing test coverage
- Setting up test infrastructure
- Debugging flaky tests

## Standards Reference

See [test-patterns.md](resources/test-patterns.md) for complete guidelines.

## Quick Reference

### Test Structure (AAA)
```typescript
test('should do something', () => {
  // Arrange - set up test data
  const input = createTestData();
  
  // Act - execute the code
  const result = functionUnderTest(input);
  
  // Assert - verify outcome
  expect(result).toBe(expected);
});
```

### Naming Convention
```
test('[unit] [action] [expected outcome]')
test('UserService creates user with valid email')
test('Button disables when loading is true')
```

### Coverage Targets
- New code: 80%+ coverage
- Critical paths: 100% coverage
- Edge cases: Always test
- Happy path: Always test

### Test Types
- Unit: Single function/component, mocked deps
- Integration: Multiple units together
- E2E: Full user flow in browser

## Amp Tools to Use
- `finder` - Find existing test patterns
- `Bash` - Run test commands

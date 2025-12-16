# Test Writing

Principles for writing effective, maintainable tests.

## Core Principles

### 1. Test Behavior, Not Implementation
Tests should verify what code does, not how it does it.

- Focus on inputs and outputs
- Avoid testing private methods directly
- Tests survive refactoring

### 2. Arrange-Act-Assert
Structure tests clearly and consistently.

- **Arrange**: Set up test conditions
- **Act**: Execute the behavior under test
- **Assert**: Verify the expected outcome

### 3. One Assertion Per Concept
Each test should verify one logical concept.

- Multiple assertions are fine if testing one behavior
- Separate tests for separate behaviors
- Test names describe the specific scenario

### 4. Tests as Documentation
Tests should clearly communicate intended behavior.

- Descriptive test names
- Clear setup and assertions
- Serve as usage examples

### 5. Fast and Isolated
Tests should run quickly and independently.

- No shared mutable state between tests
- Mock external dependencies
- Parallelize where possible

## Test Categories

| Type | Scope | Speed | Purpose |
|------|-------|-------|---------|
| Unit | Single function/class | Fast | Logic correctness |
| Integration | Multiple units | Medium | Component interaction |
| E2E | Full system | Slow | User workflows |

## Test Naming

Use descriptive names that explain the scenario:

```
[unit]_[scenario]_[expected result]

calculateTotal_withDiscount_appliesPercentage
userLogin_invalidPassword_returnsError
```

## Detailed Patterns

For implementation-specific patterns, see:
- [Test Patterns](../../skills/standards-testing/resources/test-patterns.md)

## Quick Reference

| Practice | Do | Avoid |
|----------|-----|-------|
| Data | Use factories/builders | Hardcoded fixtures |
| Mocks | Mock at boundaries | Over-mocking |
| Setup | Minimal, focused | Shared complex state |
| Assertions | Specific messages | Generic failures |
| Cleanup | Automatic/implicit | Manual, fragile |

## Anti-Patterns to Avoid

- **Flaky tests**: Tests that sometimes pass, sometimes fail
- **Test interdependence**: Tests that must run in order
- **Testing framework code**: Verifying mocks were called correctly
- **Excessive setup**: More setup than test code
- **Magic values**: Unexplained numbers/strings

## Coverage Guidelines

- Aim for meaningful coverage, not 100%
- Prioritize critical paths and edge cases
- Untested code is a risk indicator
- Coverage alone doesn't ensure quality

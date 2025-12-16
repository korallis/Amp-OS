# Test Coverage Guidelines

## Coverage Targets

| Code Type | Target | Rationale |
|-----------|--------|-----------|
| Business logic | 90%+ | Core value, high risk |
| API endpoints | 85%+ | External contracts |
| Utilities/helpers | 95%+ | Highly reusable |
| UI components | 70%+ | Visual testing supplements |
| Configuration | 50%+ | Simple, low risk |

## What to Cover

### Always Test
- Business rules and calculations
- Data transformations
- API request/response handling
- Authentication/authorization logic
- Error handling paths
- Edge cases (empty, null, boundary values)

### Test Selectively
- Simple getters/setters
- Framework boilerplate
- Third-party library wrappers
- Logging statements

### Don't Test
- Generated code
- Type definitions
- Constants/enums
- Framework internals

## Coverage Types

```
┌─────────────────────────────────────────────┐
│ Line Coverage: Were lines executed?         │
│ Branch Coverage: Were all if/else taken?    │
│ Function Coverage: Were functions called?   │
│ Statement Coverage: Were statements run?    │
└─────────────────────────────────────────────┘
```

**Focus on branch coverage** - line coverage can be misleading.

```javascript
// 100% line coverage with one test, but 50% branch coverage
function getDiscount(user) {
  return user.isPremium ? 0.2 : 0.1;  // Need both branches tested
}

// Test 1: isPremium = true  → 0.2 ✓
// Test 2: isPremium = false → 0.1 ✓  (Need this too!)
```

## Coverage Configuration

```javascript
// jest.config.js
module.exports = {
  collectCoverageFrom: [
    'src/**/*.{js,ts}',
    '!src/**/*.d.ts',
    '!src/**/*.test.{js,ts}',
    '!src/index.ts',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
    './src/services/': {
      branches: 90,
      functions: 90,
    },
  },
};
```

## Measuring Effectively

### Coverage Report Analysis
```bash
# Generate HTML report
npm test -- --coverage --coverageReporters=html

# Key files to review
# - Uncovered lines (red highlighting)
# - Partially covered branches (yellow)
# - Files with < target coverage
```

### Finding Gaps
1. Sort by lowest coverage percentage
2. Focus on business-critical files first
3. Look for untested error paths
4. Check conditional branches

## Quality Over Quantity

**Bad coverage** (gaming metrics):
```javascript
test('covers lines', () => {
  const result = complexFunction(validInput);
  expect(result).toBeDefined();  // Weak assertion
});
```

**Good coverage** (meaningful tests):
```javascript
test('calculates tax correctly for premium users', () => {
  const result = calculateTax({ isPremium: true, amount: 100 });
  expect(result).toBe(15);  // Specific expected value
});

test('throws error for negative amounts', () => {
  expect(() => calculateTax({ amount: -1 }))
    .toThrow('Amount must be positive');
});
```

## CI Integration

```yaml
# .github/workflows/test.yml
- name: Run tests with coverage
  run: npm test -- --coverage

- name: Check coverage thresholds
  run: npm test -- --coverage --coverageThreshold='{"global":{"lines":80}}'

- name: Upload coverage report
  uses: codecov/codecov-action@v3
```

## When to Adjust Targets

**Increase** when:
- Code is stable and mature
- Adding critical business logic
- Post-incident remediation

**Decrease** when:
- Rapid prototyping phase
- UI-heavy with visual tests
- Legacy code migration (temporarily)

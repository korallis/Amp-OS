# Test Execution Guide

## Overview

Standard procedures for running tests during implementation verification.

---

## Pre-Test Setup

### Environment Check
```bash
# Ensure clean state
git status

# Install dependencies
[package manager] install

# Check environment variables
env | grep -E "TEST|NODE_ENV|DATABASE"
```

### Database State
```bash
# Reset test database if needed
[db reset command]

# Run migrations
[migration command]
```

---

## Running Tests

### Full Test Suite
```bash
# Run all tests
pnpm test          # Node.js
cargo test         # Rust
go test ./...      # Go
pytest             # Python
```

### With Coverage
```bash
# Generate coverage report
pnpm test --coverage
cargo tarpaulin
go test -cover ./...
pytest --cov
```

### Specific Test Types
```bash
# Unit tests only
pnpm test:unit

# Integration tests
pnpm test:integration

# E2E tests
pnpm test:e2e
```

---

## Test Output Analysis

### Passing Tests
```
✓ Expected: All tests pass
✓ No skipped tests (unless documented)
✓ Reasonable execution time
```

### Failing Tests
```
For each failure:
1. Note test name and file
2. Read error message
3. Check if new or existing failure
4. Determine if code bug or test bug
```

### Flaky Tests
```
Signs of flakiness:
- Passes sometimes, fails others
- Timing-dependent
- Order-dependent

Action: Document and investigate
```

---

## Coverage Analysis

### Minimum Thresholds
```
Recommended minimums:
- Statements: 80%
- Branches: 70%
- Functions: 80%
- Lines: 80%
```

### Review Uncovered Code
```bash
# View coverage report
open coverage/index.html  # or equivalent

Check:
- Critical paths covered?
- Error handlers covered?
- Edge cases covered?
```

---

## Common Test Commands

### Watch Mode (Development)
```bash
pnpm test --watch
cargo watch -x test
```

### Filter by Pattern
```bash
pnpm test --filter "user"
cargo test user
go test -run TestUser ./...
pytest -k "user"
```

### Verbose Output
```bash
pnpm test --verbose
cargo test -- --nocapture
go test -v ./...
pytest -v
```

---

## Troubleshooting

### Tests Won't Run
```bash
# Check for syntax errors
[lint command]

# Check test configuration
cat [test config file]

# Try running single test
[test command] [single test path]
```

### Timeout Issues
```bash
# Increase timeout
pnpm test --timeout 10000

# Check for hanging tests
# Look for unclosed connections, missing callbacks
```

### Environment Issues
```bash
# Use test environment
NODE_ENV=test pnpm test

# Check test database connection
[db ping command]
```

---

## Test Report Template

```markdown
## Test Execution Report

Date: [date]
Feature: [feature name]

### Summary
- Total tests: [n]
- Passed: [n]
- Failed: [n]
- Skipped: [n]
- Coverage: [%]

### Failed Tests
[List any failures with brief description]

### Notes
[Any observations or concerns]
```

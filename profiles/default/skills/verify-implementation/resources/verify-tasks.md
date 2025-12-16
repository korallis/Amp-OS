# Task Completion Verification

## Overview

Detailed checklist for verifying all tasks are complete before final sign-off.

---

## Task Group Audit

### For Each Task Group

```markdown
## TG[n]: [Name]

### Tests Section
- [ ] All tests listed in "Tests First" exist in codebase
- [ ] All tests are passing
- [ ] Test coverage adequate for the group

### Sub-tasks Section
- [ ] All sub-tasks marked [x] complete
- [ ] Implementation matches sub-task description
- [ ] No partial implementations

### Dependencies
- [ ] Required dependencies were completed first
- [ ] No broken dependencies in codebase
```

---

## Completion Criteria

### Test Completeness
```
For each test in tasks.md:
1. Find corresponding test file
2. Verify test exists and runs
3. Confirm test passes
4. Check test covers stated behavior
```

### Implementation Completeness
```
For each sub-task:
1. Locate implemented code
2. Verify functionality works
3. Confirm no TODO/FIXME left
4. Check error handling present
```

---

## Common Issues

### Incomplete Tasks
```
Signs of incomplete work:
- Checkbox marked but code missing
- Partial implementation
- Disabled or skipped tests
- TODO comments in code
```

### Missing Tests
```
Signs of missing test coverage:
- Sub-task done but no test
- Test marked done but not in codebase
- Test exists but doesn't run
```

---

## Verification Commands

### List All Tests
```bash
# Find all test files
find . -name "*.test.*" -o -name "*_test.*"

# Count tests
grep -r "it\|test\|describe" tests/
```

### Find TODOs
```bash
# Search for incomplete markers
grep -r "TODO\|FIXME\|XXX" src/
```

### Run Specific Test Group
```bash
# Run tests matching pattern
[test command] --filter "[task group name]"
```

---

## Task Reconciliation

### Create Tracking Table

| Task Group | Tests Done | Tasks Done | Verified |
|------------|------------|------------|----------|
| TG1        | 5/5        | 4/4        | ✓        |
| TG2        | 3/3        | 3/3        | ✓        |
| TG3        | 4/4        | 5/5        | ✓        |
| ...        | ...        | ...        | ...      |

---

## Remediation

### If Tasks Incomplete

1. Document which tasks are incomplete
2. Assess impact on feature completeness
3. Decide: complete now or defer?
4. If completing: return to `implement-tasks`
5. If deferring: document as known limitation

### Update tasks.md

```markdown
## Known Incomplete Items
- [ ] TG3: Error handling for edge case X (deferred)
- [ ] TG4: Mobile responsiveness (Phase 2)
```

---

## Sign-Off Checklist

Before marking tasks verified:

- [ ] All task groups audited
- [ ] All tests accounted for
- [ ] All sub-tasks complete or documented
- [ ] No unexpected TODOs in new code
- [ ] Reconciliation table shows 100% or documented gaps

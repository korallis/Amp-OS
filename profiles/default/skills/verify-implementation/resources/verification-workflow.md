# Implementation Verification Workflow

## Overview

Comprehensive process for verifying implementation completeness and quality.

---

## Phase 1: Task Completion Audit

### Review tasks.md
1. All task groups marked complete
2. All sub-tasks checked off
3. All tests listed as passing
4. No open blockers documented

### Verify Checkboxes
```
Count and confirm:
- Total tasks: [n]
- Completed: [n]
- Remaining: [should be 0]
```

---

## Phase 2: Test Suite Verification

### Run All Tests
```bash
# Run full test suite
[project test command]

# Run with coverage
[coverage command]
```

### Expected Results
- [ ] All tests pass
- [ ] No skipped tests
- [ ] Coverage meets threshold
- [ ] No flaky tests observed

### Test Categories
```
Verify each category:
- [ ] Unit tests passing
- [ ] Integration tests passing
- [ ] E2E tests passing (if applicable)
```

---

## Phase 3: Spec Compliance

### Load Implementation Verifier
```
skill load implementation-verifier
```

### Cross-Reference Checklist
For each acceptance criterion in spec.md:
- [ ] Implementation exists
- [ ] Behavior matches spec
- [ ] Edge cases handled
- [ ] Error cases covered

### Architecture Review
- [ ] Components match design
- [ ] Data flow as specified
- [ ] APIs match contract
- [ ] No unauthorized deviations

---

## Phase 4: Code Quality

### Run Quality Checks
```bash
# Lint
[lint command]

# Type check
[typecheck command]

# Build
[build command]
```

### Quality Criteria
- [ ] No lint errors
- [ ] No type errors
- [ ] Build succeeds
- [ ] No new warnings introduced

### Standards Compliance
Reference applicable standards:
- [ ] Global standards followed
- [ ] Backend standards (if applicable)
- [ ] Frontend standards (if applicable)
- [ ] Testing standards followed

---

## Phase 5: Documentation

### Update Documentation
- [ ] README updated if needed
- [ ] API docs current
- [ ] Inline comments adequate
- [ ] CHANGELOG entry added

### Roadmap Update
- [ ] Feature marked complete in roadmap
- [ ] Next features identified
- [ ] Dependencies updated

---

## Outputs

1. **final-verification-report.md** - Complete verification results
2. **Updated roadmap** - Feature completion marked
3. **Next steps** - Identified follow-up work

---

## Verification Decision

### PASS Criteria
- All tests pass
- Spec compliance confirmed
- Code quality checks pass
- Documentation complete

### FAIL Actions
If verification fails:
1. Document specific failures
2. Create remediation tasks
3. Return to implementation
4. Re-verify after fixes

---

## Sign-Off

```markdown
## Verification Complete

Feature: [name]
Verified by: [agent/human]
Date: [date]
Status: PASS / FAIL

Notes:
[any observations or follow-up items]
```

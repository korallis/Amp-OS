---
title: "Verification Report: Feature Name"
spec: "./spec.md"
tasks: "./tasks.md"
verified_date: YYYY-MM-DD
verifier: ""
status: pending
---

# Verification Report: Feature Name

## Executive Summary

| Metric | Result |
|--------|--------|
| Overall Status | ⬜ Pending |
| Tasks Completed | X / Y |
| Tests Passing | X / Y |
| Blockers | None |

### Summary

Brief 2-3 sentence summary of verification outcome.

### Recommendation

- [ ] **Approve** - Ready for release
- [ ] **Approve with notes** - Minor issues documented
- [ ] **Revisions needed** - Issues must be addressed

---

## Tasks Verification

### Completed Tasks

| Task ID | Description | Status | Notes |
|---------|-------------|--------|-------|
| T-001 | [Task name] | ✅ Pass | |
| T-002 | [Task name] | ✅ Pass | |
| T-003 | [Task name] | ✅ Pass | Minor refactor suggested |

### Failed / Incomplete Tasks

| Task ID | Description | Status | Issue | Remediation |
|---------|-------------|--------|-------|-------------|
| T-004 | [Task name] | ❌ Fail | [Issue description] | [Required action] |

### Spec Compliance

| Requirement | Met | Evidence |
|-------------|-----|----------|
| Functional Req 1 | ✅ | [link to code/test] |
| Functional Req 2 | ✅ | [link to code/test] |
| Performance Req | ⚠️ | 210ms avg (target: 200ms) |

---

## Test Results

### Test Summary

| Category | Passed | Failed | Skipped | Coverage |
|----------|--------|--------|---------|----------|
| Unit | X | 0 | 0 | 85% |
| Integration | X | 0 | 0 | 70% |
| E2E | X | 0 | 0 | N/A |

### Test Execution

```bash
# Command used
pnpm test

# Output summary
✓ X tests passed
✗ 0 tests failed
```

### Failed Tests

<!-- If any -->

| Test | Error | Root Cause |
|------|-------|------------|
| test_name | Error message | Analysis |

### Coverage Report

- Lines: X%
- Branches: X%
- Functions: X%

---

## Roadmap Updates

### Documentation

- [ ] README updated
- [ ] API documentation updated
- [ ] User guide updated
- [ ] CHANGELOG entry added

### Follow-up Items

| Item | Priority | Owner | Ticket |
|------|----------|-------|--------|
| Performance optimization | Medium | TBD | #XXX |
| Additional edge case handling | Low | TBD | #XXX |

### Technical Debt

- Item 1: Description and suggested remediation
- Item 2: Description and suggested remediation

---

## Notes

### Verification Process

1. Reviewed all tasks against spec requirements
2. Ran full test suite
3. Manual testing of critical paths
4. Code review completed

### Observations

- Positive: [What went well]
- Improvement: [What could be better]

### Sign-off

| Role | Name | Date | Approved |
|------|------|------|----------|
| Developer | | | ⬜ |
| Reviewer | | | ⬜ |
| Product | | | ⬜ |

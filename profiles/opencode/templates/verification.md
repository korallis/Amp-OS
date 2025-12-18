# Verification Report: [Feature Name]

> Verified: YYYY-MM-DD
> Verifier: [Name/Agent]
> Status: [PASS / NEEDS WORK / FAIL]

---

## Summary

| Metric | Result |
|--------|--------|
| Tasks Completed | X/Y |
| Tests Passing | X/Y |
| Coverage | X% |
| Spec Compliance | [Full / Partial / None] |
| Overall Status | [PASS / NEEDS WORK / FAIL] |

---

## Task Completion Audit

### Group 1: [Group Name]

| Task | Status | Verified | Notes |
|------|--------|----------|-------|
| T-001 | ✅ | ✅ | |
| T-002 | ✅ | ✅ | |

### Group 2: [Group Name]

| Task | Status | Verified | Notes |
|------|--------|----------|-------|
| T-003 | ✅ | ✅ | |
| T-004 | ✅ | ⚠️ | Minor issue: [description] |

### Group 3: [Group Name]

| Task | Status | Verified | Notes |
|------|--------|----------|-------|
| T-005 | ✅ | ✅ | |
| T-006 | ✅ | ✅ | |

---

## Spec Compliance

### Functional Requirements

| Requirement | Implemented | Verified | Notes |
|-------------|-------------|----------|-------|
| REQ-001 | ✅ | ✅ | |
| REQ-002 | ✅ | ✅ | |
| REQ-003 | ✅ | ⚠️ | Partial: [what's missing] |

### Non-Functional Requirements

| Requirement | Target | Actual | Status |
|-------------|--------|--------|--------|
| Response Time | < 200ms | 150ms | ✅ |
| Test Coverage | 80% | 85% | ✅ |
| Accessibility | WCAG AA | AA | ✅ |

---

## Test Results

### Test Suite Summary

```
Test Suites: X passed, Y total
Tests:       X passed, Y total
Snapshots:   X passed, Y total
Time:        X.XXs
```

### Coverage Report

| Metric | Coverage | Target | Status |
|--------|----------|--------|--------|
| Statements | 85% | 80% | ✅ |
| Branches | 78% | 75% | ✅ |
| Functions | 90% | 80% | ✅ |
| Lines | 85% | 80% | ✅ |

### Failed/Skipped Tests

_None_ (or list any)

---

## Code Quality

### Standards Compliance

- [✅] No TypeScript errors
- [✅] No ESLint warnings
- [✅] Follows naming conventions
- [✅] No type suppressions (as any, @ts-ignore)
- [✅] Error handling is comprehensive
- [✅] No console.log statements

### Security Review

- [✅] Input validation implemented
- [✅] Authentication checks in place
- [✅] Authorization verified
- [✅] No sensitive data exposure

### Performance Review

- [✅] No obvious N+1 queries
- [✅] Appropriate caching
- [✅] Lazy loading where applicable

---

## Issues Found

### Critical (Must Fix)

_None_ (or list)

### Major (Should Fix)

1. **[Issue Title]**
   - Location: [file:line]
   - Description: [what's wrong]
   - Recommendation: [how to fix]

### Minor (Nice to Fix)

1. **[Issue Title]**
   - Location: [file:line]
   - Description: [what's wrong]
   - Recommendation: [how to fix]

---

## Deviations from Spec

| Deviation | Reason | Approved By |
|-----------|--------|-------------|
| [Change made] | [Why it was necessary] | [Who approved] |

---

## Documentation Status

- [✅] Code comments adequate
- [✅] API documentation updated
- [✅] README updated (if needed)
- [✅] Changelog entry added

---

## Recommendations

1. [Recommendation for future improvement]
2. [Technical debt to address later]
3. [Follow-up feature idea]

---

## Sign-off

### Verification Checklist

- [ ] All tasks completed and verified
- [ ] All tests passing
- [ ] Spec requirements met
- [ ] Code quality standards followed
- [ ] No critical issues remaining
- [ ] Documentation complete

### Result

**Status:** [PASS / NEEDS WORK / FAIL]

**Notes:** [Any final comments]

---

## Roadmap Update

If PASS:
- [ ] Update feature status in `opencode-os/product/roadmap.md`
- [ ] Mark milestone progress

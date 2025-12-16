# Implementation Verification Checklist

## 1. Task Completion (25 points)

- [ ] **All Tasks Done** (15pts) - Every task in tasks.md marked complete
- [ ] **Todo Sync** (5pts) - `todo_read` shows all items resolved
- [ ] **No Skipped Items** (5pts) - Any skipped tasks documented with reason

## 2. Test Coverage (25 points)

- [ ] **All Tests Pass** (15pts) - Full test suite runs green
- [ ] **Spec Tests Exist** (5pts) - Tests from tasks.md are implemented
- [ ] **Edge Cases Covered** (5pts) - Error paths and boundaries tested

## 3. Code Quality (20 points)

- [ ] **Linting Passes** (5pts) - No linter errors in changed files
- [ ] **Type Check Passes** (5pts) - No type errors (if applicable)
- [ ] **Build Succeeds** (5pts) - Production build completes
- [ ] **No Debug Code** (5pts) - console.log, debugger removed

## 4. Spec Alignment (20 points)

- [ ] **Goals Met** (10pts) - Each goal in spec.md is satisfied
- [ ] **Acceptance Criteria** (5pts) - All criteria from spec pass
- [ ] **No Scope Creep** (5pts) - Implementation matches spec, no extras

## 5. Documentation (10 points)

- [ ] **Code Comments** (3pts) - Complex logic explained where needed
- [ ] **API Docs** (4pts) - New endpoints/functions documented
- [ ] **README Updated** (3pts) - Usage instructions added if needed

---

## Verification Commands

Run these in order:

```bash
# 1. Run tests
npm test                    # or: pnpm test, yarn test, cargo test, go test

# 2. Check types
npm run typecheck           # or: tsc --noEmit, cargo check

# 3. Run linter
npm run lint                # or: eslint ., cargo clippy

# 4. Verify build
npm run build               # or: cargo build --release, go build
```

## Scoring Guide

| Score | Verdict | Action |
|-------|---------|--------|
| 90-100 | ✅ COMPLETE | Ready for merge/deploy |
| 70-89 | ⚠️ MINOR ISSUES | Fix flagged items |
| 50-69 | 🔄 INCOMPLETE | Significant work remaining |
| <50 | ❌ FAILED | Major implementation gaps |

## Common Issues

### Blockers
- Failing tests (must fix before completion)
- Type errors (must resolve)
- Missing required functionality from spec

### Warnings (fix if time permits)
- Low test coverage on new code
- Missing inline documentation
- Unused imports or variables

## Final Report Template

```markdown
# Final Verification Report

**Feature:** [name]
**Date:** [date]
**Verifier:** AI Assistant

## Summary
[1-2 sentence overview]

## Checklist Results
- Task Completion: X/25
- Test Coverage: X/25
- Code Quality: X/20
- Spec Alignment: X/20
- Documentation: X/10
- **Total: X/100**

## Test Results
[paste test output summary]

## Issues Found
1. [issue] - [severity] - [recommendation]

## Verdict
[COMPLETE/INCOMPLETE] - [brief justification]
```

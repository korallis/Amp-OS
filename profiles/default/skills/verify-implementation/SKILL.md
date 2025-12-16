---
name: amp-os-verify-implementation
description: Final verification after implementation is complete. Use when all tasks are done to verify against spec, run full tests, update roadmap, and generate final report.
---

# Verify Implementation

Complete final verification and documentation after implementation.

## When to Use
- All task groups in tasks.md are complete
- Ready for final verification
- Need to update roadmap and generate report

## Workflow

1. **Verify Against Spec**
   - Load `amp-os-implementation-verifier` skill
   - Check all requirements from spec.md are met
   - Verify acceptance criteria pass

2. **Run Full Test Suite**
   - Execute complete test suite
   - Verify no regressions
   - Check test coverage if applicable

3. **Code Quality Check**
   - Run linter and type checker
   - Load `amp-os-standards-global` to verify patterns
   - Address any issues

4. **Update Roadmap**
   - Mark feature complete in `amp-os/product/roadmap.md`
   - Update milestone status
   - Note any scope changes

5. **Generate Final Report**
   - Use [final-report-template.md](resources/final-report-template.md)
   - Save to `amp-os/specs/[feature]/verifications/final-verification.md`

6. **Oracle Review** (Recommended)
   - Call `oracle`: "Review this implementation against the spec"
   - Address any concerns raised

## Resources
- [Final Report Template](resources/final-report-template.md)

## Amp Tools to Use
- `oracle` - Final review and validation
- `todo_write` - Mark feature complete
- Build/test commands from AGENTS.md

## Verification Checklist
- [ ] All spec requirements implemented
- [ ] All acceptance criteria pass
- [ ] Full test suite passes
- [ ] No lint/type errors
- [ ] Documentation updated
- [ ] Roadmap updated
- [ ] Final report generated

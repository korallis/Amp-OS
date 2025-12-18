---
description: Verify implementation against spec and generate report
agent: oracle
subtask: true
---

Verify implementation of: **$ARGUMENTS**

## Inputs

Specification:
!`cat opencode-os/specs/$1/spec.md 2>/dev/null || echo "No spec found"`

Tasks:
!`cat opencode-os/specs/$1/tasks.md 2>/dev/null || echo "No tasks found"`

## Verification Process

1. **Task Completion Audit**
   - Review all tasks in tasks.md
   - Verify each task marked complete is actually done
   - Check that acceptance criteria are met
   - Note any incomplete or skipped tasks

2. **Spec Compliance Check**
   - Compare implementation against spec requirements
   - Verify all functional requirements are implemented
   - Check non-functional requirements (performance, security)
   - Document any deviations with justification

3. **Test Verification**
   - Run full test suite
   - Check test coverage meets requirements
   - Verify critical paths have adequate coverage
   - Note any failing or skipped tests

4. **Code Quality Review**
   - Check adherence to coding standards
   - Look for security issues
   - Identify any technical debt introduced
   - Note areas for future improvement

5. **Documentation Check**
   - Verify code is properly documented
   - Check that API documentation is complete
   - Ensure README updates if needed

6. **Generate Report**
   - Summarize verification results
   - List any issues found
   - Provide recommendations
   - Include sign-off status

## Template

@opencode-os/templates/verification.md

## Output

Save report to: `opencode-os/specs/$1/verification.md`

Also update: `opencode-os/product/roadmap.md` (mark feature complete if passing)

## Verification Criteria

A feature passes verification when:
- [ ] All tasks are complete
- [ ] All tests pass
- [ ] Spec requirements are met
- [ ] Code quality standards are followed
- [ ] No critical issues remain

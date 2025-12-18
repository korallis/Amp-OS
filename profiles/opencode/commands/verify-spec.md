---
description: Verify specification quality before implementation
agent: oracle
subtask: true
---

Verify specification for: **$ARGUMENTS**

## Input

Specification to verify:
!`cat opencode-os/specs/$1/spec.md 2>/dev/null || echo "No spec found - run /write-spec $1 first"`

Requirements reference:
!`cat opencode-os/specs/$1/planning/requirements.md 2>/dev/null || echo "No requirements found"`

## Verification Checklist

### 1. Completeness
- [ ] All requirements from requirements.md are addressed
- [ ] User stories have corresponding technical solutions
- [ ] Edge cases are documented
- [ ] Error handling is specified

### 2. Clarity
- [ ] Technical approach is unambiguous
- [ ] Components and interfaces are clearly defined
- [ ] Data models are complete
- [ ] No undefined terms or concepts

### 3. Feasibility
- [ ] Technical approach is realistic
- [ ] Dependencies are available and suitable
- [ ] Performance requirements are achievable
- [ ] Security approach is sound

### 4. Testability
- [ ] Testing strategy is defined
- [ ] Acceptance criteria are measurable
- [ ] Test scenarios cover requirements
- [ ] Critical paths are identified

### 5. Consistency
- [ ] Aligns with existing architecture
- [ ] Follows project standards
- [ ] Naming conventions are consistent
- [ ] No contradictions within spec

## Process

1. Read the specification thoroughly
2. Check each verification criteria
3. Note any issues or gaps found
4. Provide specific recommendations for improvement
5. Give overall assessment (Pass/Needs Work/Fail)

## Output

Provide a verification summary with:
- Overall status
- Issues found (by category)
- Specific recommendations
- Whether spec is ready for task creation

If issues are found, the spec should be revised before proceeding to /create-tasks.

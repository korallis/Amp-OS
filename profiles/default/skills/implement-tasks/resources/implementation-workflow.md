# Implementation Workflow

## Overview

This document provides detailed guidance for implementing task groups from tasks.md.

---

## Pre-Implementation Checklist

Before starting implementation:

- [ ] `tasks.md` is complete and reviewed
- [ ] `spec.md` is approved
- [ ] Understand all dependencies between task groups
- [ ] Standards skills loaded as needed
- [ ] Development environment ready

---

## TDD Implementation Cycle

For each task group, follow this cycle:

### 1. Red Phase (Write Failing Tests)
```
For each test in the task group:
1. Read the test description from tasks.md
2. Write the test code
3. Run the test - it should FAIL
4. If test passes, the test might be wrong
```

### 2. Green Phase (Implement)
```
For each sub-task:
1. Write minimal code to make tests pass
2. Run tests after each change
3. Stop when tests pass
```

### 3. Refactor Phase (Clean Up)
```
1. Review code for duplication
2. Apply patterns from standards skills
3. Ensure tests still pass
4. Update any documentation
```

---

## Multi-Agent Delegation

When using `Task` tool for parallel work:

### Good Candidates for Delegation
- Database migrations (isolated)
- Independent API endpoints
- Separate UI components
- Utility functions

### Poor Candidates for Delegation
- Tightly coupled code
- Shared state modifications
- Sequential dependencies

### Delegation Prompt Template
```
Implement [Task Group Name] from amp-os/specs/[feature]/tasks.md

Context:
- Spec: amp-os/specs/[feature]/spec.md
- Dependencies completed: [list]

Instructions:
1. Load amp-os-standards-[relevant] skill
2. Write tests first (see Tests First section in tasks.md)
3. Implement sub-tasks in order
4. Run only: [specific test command]
5. Report: tests passing, files modified, any blockers
```

---

## Progress Tracking

### Update tasks.md
Mark completed items with [x]:
```markdown
- [x] Test: user can create account
- [x] Implement user model
- [ ] Implement validation  <- current
```

### Update Amp Todos
```
todo_write: "TG1 Database Layer - COMPLETE"
todo_write: "TG2 API Layer - IN PROGRESS"
```

---

## Handling Blockers

If you encounter issues:

1. **Missing requirement**: Note in tasks.md, consult spec.md
2. **Test unclear**: Review acceptance criteria
3. **Dependency issue**: Check task group order
4. **Technical blocker**: Use `oracle` for guidance

---

## Group Completion Checklist

Before moving to next task group:

- [ ] All tests written for group
- [ ] All tests passing
- [ ] Sub-tasks completed
- [ ] tasks.md updated
- [ ] Amp todos updated
- [ ] No lint/type errors
- [ ] Code follows standards

# Task Creation Workflow

## Overview

Process for breaking specifications into implementable task groups with tests-first approach.

---

## Phase 1: Spec Analysis

### Review Specification
1. Read spec.md completely
2. Identify all deliverables
3. Note technical components
4. Map dependencies

### Extract Work Items
```
From spec, identify:
- Data models to create/modify
- API endpoints to implement
- UI components needed
- Business logic functions
- Integration points
```

---

## Phase 2: Task Grouping

### Grouping Principles
```
Good task groups:
- Can be completed in 1-2 hours
- Have clear start and end
- Minimize cross-dependencies
- Can run tests independently
```

### Suggested Group Structure
```
TG1: Data Layer
- Database schema/migrations
- Model definitions
- Repository/data access

TG2: Business Logic
- Core functions
- Validation rules
- Domain logic

TG3: API Layer
- Route handlers
- Request/response mapping
- Error handling

TG4: UI Components
- Component implementation
- State management
- User interactions

TG5: Integration
- Wire everything together
- E2E flow verification
```

---

## Phase 3: Tests-First Definition

### For Each Task Group
Define tests BEFORE implementation tasks:

```markdown
## Task Group 1: [Name]

### Tests First
- [ ] Test: [specific behavior to verify]
- [ ] Test: [another behavior]
- [ ] Test: [edge case]

### Sub-tasks
- [ ] Implement [component A]
- [ ] Implement [component B]
- [ ] Handle [edge case]
```

### Test Granularity
```
Write tests that:
- Test one behavior each
- Are independent
- Have clear pass/fail
- Cover acceptance criteria
```

---

## Phase 4: Dependency Mapping

### Identify Order
1. List what each group needs
2. Map blockers and requirements
3. Order groups by dependencies
4. Note parallel opportunities

### Dependency Notation
```markdown
## Dependencies
- TG1 → TG2 (TG2 needs TG1 models)
- TG2 → TG3 (TG3 uses TG2 logic)
- TG1, TG2, TG3 → TG4 (UI needs API ready)
```

---

## Phase 5: Estimation

### Size Each Group
```
Sizing guide:
S (Small)  - < 1 hour, straightforward
M (Medium) - 1-2 hours, some complexity
L (Large)  - 2-4 hours, complex logic

If larger than L, split the group
```

### Risk Assessment
Note potential blockers:
- Unclear requirements
- Technical uncertainty
- External dependencies

---

## Validation Checklist

- [ ] All spec items have tasks
- [ ] Each group has tests defined first
- [ ] Dependencies are logical
- [ ] Groups are right-sized
- [ ] No circular dependencies
- [ ] Acceptance criteria traceable

---

## Outputs

1. **tasks.md** - Complete task breakdown
2. **Updated todos** - Implementation order
3. **Delegation notes** - Parallelization opportunities

---

## Next Steps

After tasks.md approval:
1. Load `implement-tasks` skill
2. Start with TG1
3. Follow TDD cycle per group

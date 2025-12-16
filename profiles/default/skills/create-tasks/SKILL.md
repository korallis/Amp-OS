---
name: create-tasks
description: Break a specification into implementable tasks. Use after spec.md is complete to create tasks.md with grouped, ordered, dependency-aware task breakdown.
---

# Create Tasks

Break a specification into a structured, implementable task list.

## When to Use
- spec.md is complete and verified
- Ready to plan implementation work
- Need clear task breakdown with dependencies

## Workflow

1. **Analyze Spec**
   - Read `amp-os/specs/[feature]/spec.md`
   - Read `amp-os/specs/[feature]/planning/requirements.md`

2. **Plan Task Groups**
   - Group by specialization (database, API, frontend, testing)
   - Order by dependencies
   - Include 2-8 focused tests per group

3. **Create Tasks Document**
   - Follow template from [tasks-template.md](resources/tasks-template.md)
   - Save to `amp-os/specs/[feature]/tasks.md`

4. **Sync with Amp Todo System**
   - Use `todo_write` to create todos for each task group
   - Tag with `spec:[feature-name]`, `phase:implementation`

## Task Structure
Each task group should have:
- Clear dependencies
- 2-8 focused tests (written first)
- Implementation sub-tasks
- Test verification (run only group tests)
- Acceptance criteria

## Resources
- [Tasks Template](resources/tasks-template.md)

## Amp Tools to Use
- `todo_write` - Sync tasks to Amp's todo system
- `todo_read` - Check existing task status

---
description: Break specification into implementable task groups
subtask: true
---

Create implementation tasks for: **$ARGUMENTS**

## Input

Specification:
!`cat opencode-os/specs/$1/spec.md 2>/dev/null || echo "No spec found - run /write-spec $1 first"`

## Process

1. **Analyze Specification**
   - Read the entire specification
   - Identify all components that need to be built
   - Note dependencies between components
   - Estimate complexity of each part

2. **Create Task Groups**
   - Group related tasks together (aim for 3-5 groups)
   - Order groups by dependencies
   - Each group should be independently testable
   - Keep groups focused and manageable

3. **Define Individual Tasks**
   - Break each group into specific tasks
   - Maximum 4-6 tasks per group
   - Each task should be completable in 1-4 hours
   - Include clear acceptance criteria

4. **Plan Testing**
   - Tests come BEFORE implementation in each group
   - Specify what type of tests needed per task
   - Include test coverage expectations

5. **Estimate and Prioritize**
   - Add time estimates (S/M/L or hours)
   - Mark priorities (High/Medium/Low)
   - Identify any blockers or risks

## Template

@opencode-os/templates/tasks.md

## Output

Save to: `opencode-os/specs/$1/tasks.md`

## Guidelines

- Tasks should be atomic and well-defined
- Include "Write tests for X" as explicit tasks
- Consider parallel execution opportunities
- Flag tasks that need specific expertise
- Include setup/configuration tasks if needed

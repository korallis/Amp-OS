---
description: Implement a feature following tasks and standards
---

Implement: **$ARGUMENTS**

## Context

Tasks to implement:
!`cat opencode-os/specs/$1/tasks.md 2>/dev/null || echo "No tasks found - run /create-tasks $1 first"`

Specification reference:
!`cat opencode-os/specs/$1/spec.md 2>/dev/null || echo "No spec found"`

## Standards (MUST FOLLOW)

@opencode-os/standards/global.md
@opencode-os/standards/backend.md
@opencode-os/standards/frontend.md
@opencode-os/standards/testing.md

## Implementation Process

1. **Read and Understand**
   - Review the tasks.md file completely
   - Understand the spec requirements
   - Note any dependencies or prerequisites

2. **For Each Task Group (in order):**

   a. **Write Tests First**
      - Create failing tests that define expected behavior
      - Cover happy path and edge cases
      - Include error scenarios

   b. **Implement Minimum Code**
      - Write just enough code to pass tests
      - Follow the standards strictly
      - Keep functions small and focused

   c. **Refactor**
      - Clean up while keeping tests green
      - Extract common patterns
      - Improve naming and structure

   d. **Mark Complete**
      - Update task status in tasks.md
      - Run full test suite for the group

3. **Use Available Agents for Help**
   - @explore - for codebase questions and finding patterns
   - @librarian - for library documentation and examples
   - @oracle - for architecture decisions and debugging
   - @frontend-ui-ux-engineer - for UI components (if available)

## Rules

- **NO type suppressions** (`as any`, `@ts-ignore`, `@ts-expect-error`)
- **NO empty catch blocks**
- **Follow existing patterns** in the codebase
- **Run tests** after each task group
- **Commit** after each successful group (if using git)

## Quality Checks

Before marking a task complete:
- [ ] All tests pass
- [ ] No TypeScript errors
- [ ] Code follows project standards
- [ ] No console.log statements (use proper logging)
- [ ] Error handling is comprehensive

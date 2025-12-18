---
description: Write detailed technical specification from requirements
agent: document-writer
subtask: true
---

Write a technical specification for: **$ARGUMENTS**

## Input

Requirements document:
!`cat opencode-os/specs/$1/planning/requirements.md 2>/dev/null || echo "No requirements found - run /shape-spec $1 first"`

## Standards to Follow

@opencode-os/standards/global.md

## Process

1. **Review Requirements**
   - Read and understand all requirements thoroughly
   - Identify any gaps or ambiguities
   - Note questions that need resolution

2. **Design Technical Approach**
   - Define the overall architecture
   - Choose appropriate patterns and technologies
   - Consider scalability and maintainability
   - Plan for error handling and edge cases

3. **Define Components**
   - List all components/modules needed
   - Define interfaces between components
   - Specify data models and schemas
   - Document API contracts

4. **Testing Strategy**
   - Define what tests are needed (unit, integration, e2e)
   - Specify test coverage expectations
   - Identify critical paths that need thorough testing

5. **Write Specification**
   - Follow the spec template structure
   - Be specific and unambiguous
   - Include code examples where helpful
   - Document assumptions and decisions

## Template

@opencode-os/templates/spec.md

## Output

Save to: `opencode-os/specs/$1/spec.md`

## Guidelines

- Specifications should be implementable without further clarification
- Include rationale for significant technical decisions
- Mark anything out of scope explicitly
- Keep open questions in a dedicated section

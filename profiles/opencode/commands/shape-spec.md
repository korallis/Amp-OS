---
description: Research and gather requirements for a feature
agent: librarian
subtask: true
---

You are researching requirements for: **$ARGUMENTS**

## Standards to Follow

@opencode-os/standards/global.md

## Process

1. **Research Phase**
   - Search for similar implementations in open source projects
   - Look up relevant library documentation via context7
   - Find best practices and patterns for this type of feature
   - Review any existing related code in this codebase

2. **Requirements Gathering**
   - Define user stories with clear acceptance criteria
   - Identify functional requirements (what it must do)
   - Identify non-functional requirements (performance, security, accessibility)
   - Document constraints and limitations

3. **Technical Discovery**
   - Explore the existing codebase for related patterns
   - Identify integration points with existing systems
   - Note any technical risks or challenges
   - List dependencies on external services or libraries

4. **Documentation**
   - Create a comprehensive requirements document
   - Include research findings and references
   - Document open questions for stakeholder review

## Output Format

Create the feature directory and save requirements:
```
opencode-os/specs/$1/planning/requirements.md
```

Use template: @opencode-os/templates/requirements.md

## Guidelines

- Be thorough in research before documenting
- Include links to relevant documentation and examples found
- Clearly separate must-have from nice-to-have requirements
- Flag any areas needing stakeholder input

---
description: Create or update product roadmap with strategic planning
agent: oracle
subtask: true
---

You are helping create a product roadmap for this project.

## Current Context

Project AGENTS.md:
!`cat AGENTS.md 2>/dev/null || echo "No AGENTS.md - run /init first"`

Existing roadmap:
!`cat opencode-os/product/roadmap.md 2>/dev/null || echo "No roadmap yet"`

## Your Task

$ARGUMENTS

## Process

1. **Analyze Current State**
   - Review the project's AGENTS.md for context
   - Explore the codebase structure to understand what exists
   - Check for any existing product documentation

2. **Strategic Planning**
   - Define clear milestones with measurable outcomes
   - Prioritize features based on user value and technical dependencies
   - Consider technical debt and infrastructure needs
   - Identify risks and mitigation strategies

3. **Create/Update Roadmap**
   - Use the template structure from @opencode-os/templates/roadmap.md
   - Include timeline estimates
   - Define success criteria for each milestone

## Template Reference

@opencode-os/templates/roadmap.md

## Output

Save the roadmap to: `opencode-os/product/roadmap.md`

## Guidelines

- Be realistic about timelines
- Consider dependencies between features
- Include both user-facing features and technical improvements
- Mark current milestone clearly

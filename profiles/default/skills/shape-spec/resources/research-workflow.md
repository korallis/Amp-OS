# Research & Discovery Workflow

## Overview

Process for gathering requirements and context before writing specifications.

---

## Phase 1: Understand the Problem

### Context Gathering
1. Review feature description from roadmap
2. Identify the user problem being solved
3. Note any existing related functionality
4. Understand success criteria

### Key Questions
```
- Who is the primary user?
- What triggers this need?
- What does success look like?
- What happens without this feature?
```

---

## Phase 2: Codebase Analysis

### Existing Patterns
Use `code-analysis` skill to understand:
1. Current architecture relevant to feature
2. Similar implementations to reference
3. Shared utilities and patterns
4. Data models and schemas

### Technical Constraints
```
Identify:
- Required integrations
- Performance requirements
- Security considerations
- Platform limitations
```

---

## Phase 3: External Research

### Use RAG Tools
```
exa - For code examples and API patterns
perplexity - For best practices and tradeoffs
ref - For official documentation
```

### Research Topics
1. Industry patterns for this feature type
2. Library/framework recommendations
3. Common pitfalls and solutions
4. Accessibility requirements

---

## Phase 4: Stakeholder Input

### Gather Requirements
1. Clarify ambiguous requirements
2. Confirm edge cases
3. Validate assumptions
4. Discuss tradeoffs

### Document Decisions
```
For each decision:
- What was decided
- Why (rationale)
- Alternatives considered
- Impact on implementation
```

---

## Phase 5: Synthesize Findings

### Create Requirements Document
Using `requirements-template.md`:
1. User stories with acceptance criteria
2. Technical requirements
3. Non-functional requirements
4. Out of scope items

### Validation Checklist
- [ ] All user needs captured
- [ ] Technical constraints documented
- [ ] Edge cases identified
- [ ] Dependencies mapped
- [ ] Assumptions validated

---

## Outputs

1. **requirements.md** - Complete requirements document
2. **Research notes** - Supporting findings
3. **Open questions** - Items needing resolution

---

## Next Steps

After requirements approval:
1. Load `write-spec` skill
2. Transform requirements into specification
3. Include implementation guidance

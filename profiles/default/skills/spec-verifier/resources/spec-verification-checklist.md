# Spec Verification Checklist

## 1. Clarity & Structure (20 points)

- [ ] **Title & Overview** (5pts) - Clear feature name and one-paragraph summary
- [ ] **Goals Defined** (5pts) - Explicit success criteria listed
- [ ] **User Stories** (5pts) - At least one "As a [user], I want [action] so that [benefit]"
- [ ] **Non-Goals** (5pts) - Explicitly states what's out of scope

## 2. Technical Completeness (25 points)

- [ ] **Technical Approach** (10pts) - Architecture decisions documented
- [ ] **Data Model** (5pts) - Schema changes or data structures defined
- [ ] **API Design** (5pts) - Endpoints, inputs, outputs specified (if applicable)
- [ ] **Integration Points** (5pts) - External dependencies identified

## 3. Feasibility (20 points)

- [ ] **Existing Code Referenced** (10pts) - Uses `finder` results to identify reusable code
- [ ] **No Fictional Dependencies** (5pts) - Only references libraries/patterns that exist
- [ ] **Reasonable Scope** (5pts) - Can be implemented in stated timeline

## 4. Testability (20 points)

- [ ] **Acceptance Criteria** (10pts) - Clear pass/fail conditions for each requirement
- [ ] **Test Scenarios** (5pts) - Happy path and edge cases identified
- [ ] **Measurable Outcomes** (5pts) - Quantifiable success metrics where applicable

## 5. Dependency Awareness (15 points)

- [ ] **Prerequisites Listed** (5pts) - What must exist before implementation
- [ ] **Blockers Identified** (5pts) - External factors that could delay work
- [ ] **Impact Analysis** (5pts) - Effects on existing functionality noted

---

## Scoring Guide

| Score | Verdict | Action |
|-------|---------|--------|
| 90-100 | ✅ READY | Proceed to task creation |
| 70-89 | ⚠️ MINOR ISSUES | Address flagged items, then proceed |
| 50-69 | 🔄 NEEDS REVISION | Significant gaps, revise spec |
| <50 | ❌ INCOMPLETE | Return to shape-spec phase |

## Common Issues

### Red Flags
- Vague language ("improve performance", "make it better")
- Missing error handling considerations
- No rollback/migration strategy for data changes
- Circular dependencies between features

### Quick Fixes
- Add specific metrics to vague goals
- Include error states in user stories
- Reference actual file paths from codebase exploration
- Explicitly state assumptions

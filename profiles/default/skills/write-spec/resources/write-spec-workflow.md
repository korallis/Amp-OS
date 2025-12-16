# Specification Writing Workflow

## Overview

Process for transforming requirements into a complete, implementable specification.

---

## Phase 1: Structure Setup

### Initialize Spec
1. Create feature directory: `amp-os/specs/[feature-name]/`
2. Copy `spec-template.md` as starting point
3. Set metadata (version, status, date)
4. Reference requirements document

### Define Boundaries
```
Clearly state:
- What IS in scope
- What is NOT in scope
- Deferred items for future phases
- Hard constraints
```

---

## Phase 2: Technical Design

### Architecture Section
1. Describe overall approach
2. Create architecture diagram (use `architecture-diagrams` skill)
3. Define component responsibilities
4. Map data flow

### Data Models
```
For each entity:
- Field definitions with types
- Validation rules
- Relationships
- Migration strategy (if modifying existing)
```

### API Design
```
For each endpoint/interface:
- Input parameters
- Output format
- Error cases
- Authentication requirements
```

---

## Phase 3: Behavior Specification

### User Flows
1. Document primary user journey
2. Include alternative paths
3. Specify error handling
4. Note edge cases

### Acceptance Criteria
```
For each user story:
GIVEN [context]
WHEN [action]
THEN [expected outcome]
```

### Edge Cases
List and specify behavior for:
- Empty states
- Error conditions
- Concurrent access
- Boundary conditions

---

## Phase 4: Implementation Guidance

### Technical Recommendations
1. Suggested approach or patterns
2. Files likely to be modified
3. Key dependencies
4. Performance considerations

### Testing Strategy
```
Unit tests:
- Critical functions to test
- Mock requirements

Integration tests:
- API endpoint coverage
- Data flow verification

E2E tests:
- User journey coverage
```

---

## Phase 5: Review & Verification

### Self-Review Checklist
- [ ] All requirements addressed
- [ ] No ambiguous language
- [ ] Edge cases covered
- [ ] Testable criteria defined
- [ ] Technical approach validated

### Load Spec Verifier
```
skill load spec-verifier
- Run verification checklist
- Address any gaps
- Get approval before tasks
```

---

## Outputs

1. **spec.md** - Complete specification
2. **Architecture diagrams** - Visual references
3. **Verification report** - Quality confirmation

---

## Next Steps

After spec approval:
1. Load `create-tasks` skill
2. Break spec into implementable tasks
3. Define task groups and dependencies

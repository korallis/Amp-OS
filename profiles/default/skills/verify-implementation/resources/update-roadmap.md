# Roadmap Update Process

## Overview

Steps for updating the product roadmap after feature completion or phase changes.

---

## When to Update

### Completion Events
- Feature implementation verified
- Phase milestone reached
- Scope change approved
- Timeline adjustment needed

### Update Triggers
```
✓ Feature passes verification → Mark complete
✓ New requirements identified → Add to backlog
✓ Priorities change → Reorder features
✓ Estimates wrong → Adjust timeline
```

---

## Marking Features Complete

### In roadmap.md

```markdown
## Phase 1: MVP

### Completed
- [x] User authentication (v1.0.0)
- [x] Basic CRUD operations (v1.0.0)

### In Progress
- [ ] Search functionality ← current

### Planned
- [ ] Export feature
- [ ] Notifications
```

### Add Version Tag
When releasing:
```markdown
- [x] Feature name (v1.2.0, 2024-01-15)
```

---

## Recording Lessons Learned

### For Each Completed Feature

```markdown
### Feature: [Name]

**Completed**: [date]
**Planned effort**: [estimate]
**Actual effort**: [actual]

**What went well**:
- [positive observation]

**What to improve**:
- [lesson learned]

**Follow-up items**:
- [deferred work]
- [future enhancement]
```

---

## Adjusting Future Estimates

### Based on Actuals
```
If estimate was off:
1. Note variance (planned vs actual)
2. Identify why (scope creep, complexity, etc.)
3. Apply factor to similar future work
```

### Update Remaining Estimates
```markdown
## Phase 2 (Revised)

- [ ] Feature A - M → L (increased based on Phase 1 learnings)
- [ ] Feature B - S (unchanged)
```

---

## Handling Scope Changes

### Adding Features
```markdown
## Backlog (New)
- [ ] [New feature] - Added [date], source: [reason]
```

### Removing/Deferring Features
```markdown
## Deferred
- [ ] [Feature] - Moved from Phase 2, reason: [explanation]
```

### Priority Changes
Document the change:
```markdown
## Priority Changes Log
- [date]: Moved [feature] from Phase 3 to Phase 2 due to [reason]
```

---

## Communicating Changes

### Update Todos
```
todo_write: "Roadmap updated - [feature] complete"
todo_write: "Next: [next feature] - ready for spec shaping"
```

### Notify Stakeholders
If human review needed:
```markdown
## Roadmap Update Summary

**Completed this cycle**:
- [feature list]

**Changes to plan**:
- [any adjustments]

**Next priorities**:
- [upcoming work]

Please review and confirm priorities for next cycle.
```

---

## Roadmap Health Check

### Periodic Review
```
Every [n] features, review:
- [ ] Priorities still correct?
- [ ] Estimates calibrated?
- [ ] Dependencies valid?
- [ ] Timeline realistic?
```

### Metrics to Track
```
- Features completed vs planned
- Estimate accuracy trend
- Scope creep frequency
- Blocked item count
```

---

## Next Feature Selection

### After Completion
1. Review roadmap for next priority
2. Check dependencies satisfied
3. Confirm requirements clear
4. Load `plan-product` or `shape-spec` skill

### Selection Criteria
```
Prioritize features that:
- Have dependencies met
- Align with current phase goals
- Have clear requirements
- Are right-sized for available time
```

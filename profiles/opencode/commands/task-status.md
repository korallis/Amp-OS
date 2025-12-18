---
description: Check and update task status for a feature
---

Check task status for: **$ARGUMENTS**

## Current Tasks

!`cat opencode-os/specs/$1/tasks.md 2>/dev/null || echo "No tasks found for this feature"`

## Actions

Based on your request, I will:

1. **If checking status**: Display current progress across all task groups
2. **If updating status**: Update the specified task status in tasks.md

## Status Legend

- `Pending` - Not started
- `In Progress` - Currently being worked on  
- `Complete` - Finished and verified
- `Blocked` - Cannot proceed (document blocker)

## Progress Summary

I'll analyze the tasks.md file and provide:
- Total tasks and completion percentage
- Current task group being worked on
- Any blocked tasks
- Estimated remaining effort

## Usage Examples

```
/task-status auth                    # Check status of auth feature
/task-status auth mark T-001 complete   # Mark task T-001 as complete
/task-status auth block T-003 "waiting for API"  # Mark task blocked
```

$ARGUMENTS

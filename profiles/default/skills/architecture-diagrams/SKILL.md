---
name: architecture-diagrams
description: Generate mermaid architecture diagrams. Use when visualizing system flows, component relationships, sequences, or data models.
---

# Architecture Diagrams

Generate clear mermaid diagrams with proper syntax and styling.

## Workflow

1. **Identify diagram type** based on what you're visualizing:
   - `flowchart` - Process flows, decision trees, workflows
   - `sequenceDiagram` - API calls, user interactions, async flows
   - `graph` - Component relationships, dependencies
   - `erDiagram` - Data models, database schemas

2. **Gather context** using code tools:
   - Use `finder` to locate relevant components
   - Use `Read` to understand relationships
   - Link to source files in diagram notes

3. **Generate diagram** using Amp's `mermaid` tool:
   - Keep labels concise (3-4 words max)
   - Use consistent naming conventions
   - Add notes for complex relationships

4. **Cite sources** - Link diagram elements to actual code locations

## Quick Reference

See [diagram-templates.md](resources/diagram-templates.md) for syntax examples.

## When to Use

- Visualizing system architecture or component relationships
- Documenting API flows or user interactions
- Creating database/data model diagrams
- Explaining complex workflows or decision trees

## Key Principles

- **One concept per diagram** - Split complex systems into multiple diagrams
- **Top-to-bottom or left-to-right** - Consistent flow direction
- **Color-code by concern** - Use subgraphs or styling for grouping
- **Always cite code** - Diagrams should reference actual implementations

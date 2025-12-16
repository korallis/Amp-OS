# Mermaid Diagram Templates

## Flowchart - Process/Decision Flow

```mermaid
flowchart TD
    A[Start] --> B{Decision?}
    B -->|Yes| C[Action 1]
    B -->|No| D[Action 2]
    C --> E[End]
    D --> E
```

### With Subgraphs (Component Grouping)

```mermaid
flowchart LR
    subgraph Frontend
        A[UI] --> B[State]
    end
    subgraph Backend
        C[API] --> D[DB]
    end
    B --> C
```

## Sequence Diagram - Interactions Over Time

```mermaid
sequenceDiagram
    participant U as User
    participant A as API
    participant D as Database
    
    U->>A: POST /resource
    A->>D: INSERT record
    D-->>A: success
    A-->>U: 201 Created
```

### With Async/Parallel

```mermaid
sequenceDiagram
    participant C as Client
    participant S as Server
    participant Q as Queue
    
    C->>S: Request
    S->>Q: Enqueue job
    S-->>C: 202 Accepted
    Q-->>S: Job complete
    S->>C: Webhook notification
```

## Component/Graph Diagram - Relationships

```mermaid
graph TD
    A[Service A] --> B[Service B]
    A --> C[Service C]
    B --> D[(Database)]
    C --> D
    B -.-> E[Cache]
```

### Dependency Graph

```mermaid
graph BT
    Core --> Utils
    API --> Core
    API --> Auth
    Auth --> Core
    CLI --> API
```

## ER Diagram - Data Models

```mermaid
erDiagram
    USER ||--o{ ORDER : places
    ORDER ||--|{ LINE_ITEM : contains
    PRODUCT ||--o{ LINE_ITEM : "ordered in"
    
    USER {
        int id PK
        string email UK
        string name
    }
    ORDER {
        int id PK
        int user_id FK
        date created_at
    }
```

## State Diagram - State Machines

```mermaid
stateDiagram-v2
    [*] --> Draft
    Draft --> Review: submit
    Review --> Approved: approve
    Review --> Draft: reject
    Approved --> Published: publish
    Published --> [*]
```

## Styling Tips

### Node Shapes
- `[text]` - Rectangle (process)
- `{text}` - Diamond (decision)
- `([text])` - Stadium (start/end)
- `[(text)]` - Cylinder (database)
- `((text))` - Circle (connector)

### Arrow Types
- `-->` - Solid arrow
- `-.->` - Dotted arrow
- `==>` - Thick arrow
- `-->>` - Async/response
- `--x` - Cross (failure)

### Adding Notes
```mermaid
sequenceDiagram
    Note over A,B: Shared context
    Note right of A: Local note
```

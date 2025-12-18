---
description: React and component standards
globs: ["**/*.tsx", "**/*.jsx", "!**/node_modules/**", "!**/dist/**", "!**/build/**", "!**/.next/**", "!**/coverage/**"]
---

# React Standards

> **Rule Precedence**: Security > Correctness/Types > Testing > Performance > Style

## Component Structure

```tsx
// 1. Imports (external, internal, relative)
// 2. Types/Interfaces
// 3. Constants
// 4. Component
// 5. Helper functions (if not extracted)

interface Props {
  title: string;
  onAction: () => void;
  children?: React.ReactNode;
}

export function MyComponent({ title, onAction, children }: Props) {
  // Hooks first, grouped by type
  const [state, setState] = useState<State>({ status: 'idle' });
  const { data } = useQuery(...);
  
  // Derived state
  const isLoading = state.status === 'loading';
  
  // Callbacks (memoize if passed to children)
  const handleClick = useCallback(() => {
    onAction();
  }, [onAction]);
  
  // Effects last
  useEffect(() => {
    // ...
  }, [deps]);
  
  // Early returns for loading/error states
  if (isLoading) return <Skeleton />;
  
  return (
    <div>
      {children}
    </div>
  );
}
```

## Hooks Rules

- Call hooks at top level only (no conditions/loops)
- Custom hooks must start with `use`
- Memoize expensive computations: `useMemo`
- Memoize callbacks passed to children: `useCallback`
- **Don't over-memoize** - measure first

## State Management

- Local state: `useState` for UI, form inputs
- Server state: TanStack Query (React Query)
- Global client state: Zustand (when needed)
- URL state: Use router params/search params

## Performance

- Lazy load routes: `React.lazy()` + `Suspense`
- Virtualize long lists: `@tanstack/react-virtual`
- Avoid inline objects/arrays in JSX (causes re-renders)
- Use React DevTools Profiler to identify bottlenecks

## Accessibility

- Use semantic HTML (`button`, `nav`, `main`, etc.)
- Add `aria-*` attributes where needed
- Ensure keyboard navigation works
- Test with screen readers

## Error Handling

- Use Error Boundaries for component trees
- Handle async errors in try/catch or `.catch()`
- Show user-friendly error messages
- Log errors to monitoring service

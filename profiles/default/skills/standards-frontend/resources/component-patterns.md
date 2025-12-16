# Component Patterns

## 1. Component Structure

### Basic Component
```tsx
// 1. Imports
import { useState } from 'react';
import { cn } from '@/lib/utils';
import type { ButtonProps } from './types';

// 2. Types (or import from types file)
interface CardProps {
  title: string;
  children: React.ReactNode;
  className?: string;
}

// 3. Component (named export)
export function Card({ title, children, className }: CardProps) {
  return (
    <div className={cn('card', className)}>
      <h2 className="card-title">{title}</h2>
      <div className="card-content">{children}</div>
    </div>
  );
}
```

### Component with Hooks
```tsx
export function UserProfile({ userId }: { userId: string }) {
  // 1. Hooks first
  const { data: user, isLoading } = useUser(userId);
  const [isEditing, setIsEditing] = useState(false);
  
  // 2. Early returns
  if (isLoading) return <Skeleton />;
  if (!user) return <NotFound />;
  
  // 3. Handlers
  const handleEdit = () => setIsEditing(true);
  
  // 4. Render
  return (
    <div>
      <h1>{user.name}</h1>
      <button onClick={handleEdit}>Edit</button>
    </div>
  );
}
```

## 2. Props Patterns

### Optional vs Required
```tsx
interface Props {
  // Required
  title: string;
  onClick: () => void;
  
  // Optional with defaults
  variant?: 'primary' | 'secondary';
  disabled?: boolean;
  
  // Children
  children: React.ReactNode;
}

export function Button({ 
  title, 
  onClick, 
  variant = 'primary',  // Default value
  disabled = false,
  children 
}: Props) {}
```

### Extending HTML Elements
```tsx
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant: 'primary' | 'secondary';
  isLoading?: boolean;
}

export function Button({ variant, isLoading, children, ...props }: ButtonProps) {
  return (
    <button {...props} disabled={isLoading || props.disabled}>
      {isLoading ? <Spinner /> : children}
    </button>
  );
}
```

### Render Props & Slots
```tsx
interface ListProps<T> {
  items: T[];
  renderItem: (item: T, index: number) => React.ReactNode;
  header?: React.ReactNode;
  emptyState?: React.ReactNode;
}

export function List<T>({ items, renderItem, header, emptyState }: ListProps<T>) {
  if (items.length === 0) return emptyState ?? <p>No items</p>;
  
  return (
    <div>
      {header}
      <ul>{items.map((item, i) => renderItem(item, i))}</ul>
    </div>
  );
}
```

## 3. State Management

### Local State (UI only)
```tsx
// Toggle, form inputs, temporary UI state
const [isOpen, setIsOpen] = useState(false);
const [searchQuery, setSearchQuery] = useState('');
```

### Server State (React Query)
```tsx
// Data fetching, caching, synchronization
const { data, isLoading, error } = useQuery({
  queryKey: ['users', userId],
  queryFn: () => fetchUser(userId)
});

const mutation = useMutation({
  mutationFn: updateUser,
  onSuccess: () => queryClient.invalidateQueries(['users'])
});
```

### Shared State (Context)
```tsx
// Theme, auth, app-wide settings
const ThemeContext = createContext<ThemeContextType | null>(null);

export function useTheme() {
  const context = useContext(ThemeContext);
  if (!context) throw new Error('useTheme must be used within ThemeProvider');
  return context;
}
```

### URL State
```tsx
// Shareable, bookmarkable state
const [searchParams, setSearchParams] = useSearchParams();
const filter = searchParams.get('filter') ?? 'all';
```

## 4. Event Handling

### Forms
```tsx
function ContactForm() {
  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    const data = Object.fromEntries(formData);
    submitForm(data);
  };
  
  return (
    <form onSubmit={handleSubmit}>
      <input name="email" type="email" required />
      <button type="submit">Submit</button>
    </form>
  );
}
```

### Debounced Inputs
```tsx
function SearchInput() {
  const [value, setValue] = useState('');
  const debouncedSearch = useDebouncedCallback(
    (query: string) => performSearch(query),
    300
  );
  
  return (
    <input
      value={value}
      onChange={(e) => {
        setValue(e.target.value);
        debouncedSearch(e.target.value);
      }}
    />
  );
}
```

## 5. Accessibility

### Semantic HTML
```tsx
// Use correct elements
<button>Click me</button>        // Not <div onClick>
<a href="/page">Link</a>         // Not <span onClick>
<nav>Navigation</nav>            // Not <div class="nav">
<main>Main content</main>        // Not <div class="main">
```

### ARIA Labels
```tsx
// Interactive elements need labels
<button aria-label="Close dialog">
  <XIcon />
</button>

<input aria-describedby="email-hint" />
<p id="email-hint">We'll never share your email</p>

// Live regions for dynamic content
<div aria-live="polite" aria-atomic="true">
  {notification}
</div>
```

### Keyboard Navigation
```tsx
// Support keyboard interaction
<div
  role="button"
  tabIndex={0}
  onClick={handleClick}
  onKeyDown={(e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      handleClick();
    }
  }}
>
  Custom Button
</div>
```

## 6. Performance

### Memoization
```tsx
// Memoize expensive computations
const sortedItems = useMemo(
  () => items.sort((a, b) => a.name.localeCompare(b.name)),
  [items]
);

// Memoize callbacks passed to children
const handleClick = useCallback(() => {
  doSomething(id);
}, [id]);

// Memoize components that receive stable props
const MemoizedList = memo(List);
```

### Code Splitting
```tsx
// Lazy load routes
const Dashboard = lazy(() => import('./pages/Dashboard'));

// Lazy load heavy components
const Chart = lazy(() => import('./components/Chart'));

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <Dashboard />
    </Suspense>
  );
}
```

### List Virtualization
```tsx
// Use virtual lists for 100+ items
import { useVirtualizer } from '@tanstack/react-virtual';

function VirtualList({ items }) {
  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 50,
  });
  
  return (
    <div ref={parentRef} style={{ height: '400px', overflow: 'auto' }}>
      <div style={{ height: virtualizer.getTotalSize() }}>
        {virtualizer.getVirtualItems().map((virtualRow) => (
          <div key={virtualRow.key} style={{ transform: `translateY(${virtualRow.start}px)` }}>
            {items[virtualRow.index]}
          </div>
        ))}
      </div>
    </div>
  );
}
```

## 7. Error Handling

### Error Boundaries
```tsx
class ErrorBoundary extends React.Component {
  state = { hasError: false };
  
  static getDerivedStateFromError() {
    return { hasError: true };
  }
  
  componentDidCatch(error, info) {
    logError(error, info);
  }
  
  render() {
    if (this.state.hasError) {
      return <ErrorFallback onReset={() => this.setState({ hasError: false })} />;
    }
    return this.props.children;
  }
}
```

### Async Error States
```tsx
function DataComponent() {
  const { data, error, isLoading } = useQuery(/*...*/);
  
  if (isLoading) return <Skeleton />;
  if (error) return <ErrorMessage error={error} />;
  if (!data) return <EmptyState />;
  
  return <DataView data={data} />;
}
```

## 8. Testing Patterns

### Component Tests
```tsx
import { render, screen, userEvent } from '@testing-library/react';

test('button calls onClick when clicked', async () => {
  const handleClick = vi.fn();
  render(<Button onClick={handleClick}>Click me</Button>);
  
  await userEvent.click(screen.getByRole('button', { name: /click me/i }));
  
  expect(handleClick).toHaveBeenCalledOnce();
});
```

### Query Priority
```tsx
// Prefer accessible queries
screen.getByRole('button', { name: /submit/i });  // Best
screen.getByLabelText('Email');                    // Good
screen.getByText('Welcome');                       // OK
screen.getByTestId('submit-btn');                  // Last resort
```

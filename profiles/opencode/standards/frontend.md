# Frontend Standards

Standards for React, UI components, and client-side development.

## React Patterns

### Component Structure

```typescript
// Prefer function components with explicit return types
interface ButtonProps {
  variant?: 'primary' | 'secondary';
  size?: 'sm' | 'md' | 'lg';
  children: React.ReactNode;
  onClick?: () => void;
  disabled?: boolean;
}

export function Button({
  variant = 'primary',
  size = 'md',
  children,
  onClick,
  disabled,
}: ButtonProps): React.ReactElement {
  return (
    <button
      className={cn(buttonVariants({ variant, size }))}
      onClick={onClick}
      disabled={disabled}
    >
      {children}
    </button>
  );
}
```

### Composition Over Inheritance

```typescript
// Good: Composition
function Card({ children }: { children: React.ReactNode }) {
  return <div className="rounded-lg border p-4">{children}</div>;
}

function CardHeader({ children }: { children: React.ReactNode }) {
  return <div className="mb-4 font-bold">{children}</div>;
}

function CardContent({ children }: { children: React.ReactNode }) {
  return <div>{children}</div>;
}

// Usage
<Card>
  <CardHeader>Title</CardHeader>
  <CardContent>Content</CardContent>
</Card>
```

### Custom Hooks

```typescript
// Extract reusable logic into hooks
function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);

  return debouncedValue;
}
```

## State Management

### Server State: TanStack Query

```typescript
// Queries
const { data, isLoading, error } = useQuery({
  queryKey: ['users', userId],
  queryFn: () => fetchUser(userId),
  staleTime: 5 * 60 * 1000, // 5 minutes
});

// Mutations
const mutation = useMutation({
  mutationFn: updateUser,
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['users'] });
  },
});
```

### Client State: Zustand or Context

```typescript
// Zustand for global UI state
interface UIStore {
  sidebarOpen: boolean;
  toggleSidebar: () => void;
}

const useUIStore = create<UIStore>((set) => ({
  sidebarOpen: true,
  toggleSidebar: () => set((s) => ({ sidebarOpen: !s.sidebarOpen })),
}));

// Context for scoped state
const FormContext = createContext<FormState | null>(null);

function useFormContext() {
  const context = useContext(FormContext);
  if (!context) {
    throw new Error('useFormContext must be used within FormProvider');
  }
  return context;
}
```

## Forms

### React Hook Form + Zod

```typescript
const formSchema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
});

type FormData = z.infer<typeof formSchema>;

function LoginForm() {
  const form = useForm<FormData>({
    resolver: zodResolver(formSchema),
    defaultValues: { email: '', password: '' },
  });

  const onSubmit = async (data: FormData) => {
    await login(data);
  };

  return (
    <form onSubmit={form.handleSubmit(onSubmit)}>
      {/* form fields */}
    </form>
  );
}
```

## Styling

### Tailwind CSS Conventions

```typescript
// Use cn() helper for conditional classes
import { cn } from '@/lib/utils';

<div className={cn(
  'rounded-lg border p-4',
  isActive && 'border-blue-500',
  disabled && 'opacity-50 cursor-not-allowed'
)} />
```

### CSS Variables for Theming

```css
:root {
  --background: 0 0% 100%;
  --foreground: 222.2 84% 4.9%;
  --primary: 221.2 83.2% 53.3%;
}

.dark {
  --background: 222.2 84% 4.9%;
  --foreground: 210 40% 98%;
}
```

## Accessibility

### Required Practices

```typescript
// All interactive elements need accessible names
<button aria-label="Close dialog">
  <XIcon />
</button>

// Form inputs need labels
<label htmlFor="email">Email</label>
<input id="email" type="email" />

// Images need alt text
<img src={src} alt="User profile picture" />

// Use semantic HTML
<nav>, <main>, <article>, <aside>, <header>, <footer>
```

### Keyboard Navigation

```typescript
// Handle keyboard events
function Dialog({ onClose }: { onClose: () => void }) {
  useEffect(() => {
    const handleEscape = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
    };
    document.addEventListener('keydown', handleEscape);
    return () => document.removeEventListener('keydown', handleEscape);
  }, [onClose]);
}
```

## Performance

### Memoization

```typescript
// Memoize expensive calculations
const sortedItems = useMemo(
  () => items.sort((a, b) => a.name.localeCompare(b.name)),
  [items]
);

// Memoize callbacks for child components
const handleClick = useCallback(() => {
  doSomething(id);
}, [id]);
```

### Code Splitting

```typescript
// Lazy load routes and heavy components
const Dashboard = lazy(() => import('./pages/dashboard'));
const Chart = lazy(() => import('./components/chart'));

<Suspense fallback={<Loading />}>
  <Dashboard />
</Suspense>
```

## Error Boundaries

```typescript
class ErrorBoundary extends Component<Props, State> {
  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    logger.error({ error, info }, 'React error boundary caught error');
  }

  render() {
    if (this.state.hasError) {
      return <ErrorFallback error={this.state.error} />;
    }
    return this.props.children;
  }
}
```

## Component Checklist

- [ ] Props have TypeScript interface
- [ ] Has meaningful display name
- [ ] Accessible (keyboard, screen reader)
- [ ] Handles loading state
- [ ] Handles error state
- [ ] Handles empty state
- [ ] Responsive on all breakpoints

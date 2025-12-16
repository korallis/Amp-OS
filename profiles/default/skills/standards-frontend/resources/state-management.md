# State Management Patterns

## State Categories

| Type | Scope | Examples | Solution |
|------|-------|----------|----------|
| **Local** | Single component | Form inputs, toggles | `useState`, component state |
| **Shared** | Component tree | Theme, user prefs | Context, props |
| **Server** | Remote data | API responses | React Query, SWR |
| **Global** | Entire app | Auth, cart | Zustand, Redux |
| **URL** | Navigation | Filters, pagination | Query params |

## Local State

```jsx
// Simple local state
function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>;
}

// Form state - use controlled inputs
function Form() {
  const [values, setValues] = useState({ name: '', email: '' });
  
  const handleChange = (e) => {
    setValues(prev => ({ ...prev, [e.target.name]: e.target.value }));
  };
  
  return <input name="name" value={values.name} onChange={handleChange} />;
}
```

## Server State (React Query)

```jsx
// Fetching
function UserProfile({ userId }) {
  const { data, isLoading, error } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
  
  if (isLoading) return <Spinner />;
  if (error) return <Error message={error.message} />;
  return <Profile user={data} />;
}

// Mutations
function UpdateUser() {
  const queryClient = useQueryClient();
  
  const mutation = useMutation({
    mutationFn: updateUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['user'] });
    },
  });
  
  return <button onClick={() => mutation.mutate(data)}>Save</button>;
}
```

## Global State (Zustand)

```javascript
// Store definition
const useStore = create((set, get) => ({
  user: null,
  isAuthenticated: false,
  
  login: async (credentials) => {
    const user = await authApi.login(credentials);
    set({ user, isAuthenticated: true });
  },
  
  logout: () => {
    set({ user: null, isAuthenticated: false });
  },
}));

// Usage in components
function Header() {
  const { user, logout } = useStore();
  return user ? <button onClick={logout}>Logout</button> : <LoginButton />;
}
```

## URL State

```jsx
// Use URL for shareable/bookmarkable state
function ProductList() {
  const [searchParams, setSearchParams] = useSearchParams();
  const category = searchParams.get('category') || 'all';
  const sort = searchParams.get('sort') || 'newest';
  
  const updateFilters = (key, value) => {
    setSearchParams(prev => {
      prev.set(key, value);
      return prev;
    });
  };
  
  return (
    <FilterSelect 
      value={category} 
      onChange={(v) => updateFilters('category', v)} 
    />
  );
}
```

## Best Practices

### State Colocation
Keep state as close to where it's used as possible.

```jsx
// Bad: Lifting state unnecessarily
function App() {
  const [modalOpen, setModalOpen] = useState(false);
  return <DeepChild modalOpen={modalOpen} setModalOpen={setModalOpen} />;
}

// Good: State lives where it's used
function DeepChild() {
  const [modalOpen, setModalOpen] = useState(false);
  return <Modal open={modalOpen} />;
}
```

### Derived State
Don't store what you can compute.

```jsx
// Bad
const [items, setItems] = useState([]);
const [total, setTotal] = useState(0); // Derived!

// Good
const [items, setItems] = useState([]);
const total = items.reduce((sum, item) => sum + item.price, 0);
```

### Avoid Prop Drilling
Use composition or context for deeply nested state.

```jsx
// Use composition
function Page() {
  const user = useUser();
  return (
    <Layout header={<Header user={user} />}>
      <Content />
    </Layout>
  );
}
```

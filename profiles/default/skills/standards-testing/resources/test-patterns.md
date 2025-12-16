# Test Patterns

## 1. Test Structure

### AAA Pattern (Arrange-Act-Assert)
```typescript
test('calculateTotal returns sum of items with tax', () => {
  // Arrange
  const items = [
    { price: 10, quantity: 2 },
    { price: 5, quantity: 1 }
  ];
  const taxRate = 0.1;
  
  // Act
  const total = calculateTotal(items, taxRate);
  
  // Assert
  expect(total).toBe(27.5); // (20 + 5) * 1.1
});
```

### Given-When-Then (BDD style)
```typescript
describe('ShoppingCart', () => {
  describe('given an empty cart', () => {
    describe('when adding an item', () => {
      it('then cart contains one item', () => {
        const cart = new ShoppingCart();
        cart.addItem({ id: '1', price: 10 });
        expect(cart.itemCount).toBe(1);
      });
    });
  });
});
```

## 2. Naming Conventions

### Test Files
```
# Mirror source structure
src/
  components/Button.tsx
  utils/format.ts
  
tests/  (or __tests__/ or colocated)
  components/Button.test.tsx
  utils/format.test.ts
```

### Test Names
```typescript
// Format: [subject] [action] [expected outcome]
test('UserService creates user with valid email', () => {});
test('Button displays loading spinner when isLoading is true', () => {});
test('validateEmail returns false for invalid format', () => {});

// Or use 'should' format
test('should create user with valid email', () => {});
test('should display loading spinner when loading', () => {});
```

### Describe Blocks
```typescript
describe('UserService', () => {
  describe('createUser', () => {
    test('creates user with valid data', () => {});
    test('throws ValidationError for invalid email', () => {});
    test('hashes password before saving', () => {});
  });
  
  describe('deleteUser', () => {
    test('soft deletes user by id', () => {});
    test('throws NotFoundError for invalid id', () => {});
  });
});
```

## 3. Test Categories

### Unit Tests
```typescript
// Test single function/component in isolation
// Mock all external dependencies

// Function test
test('formatCurrency formats number with dollar sign', () => {
  expect(formatCurrency(1234.5)).toBe('$1,234.50');
});

// Component test (mocked data)
test('UserCard displays user name', () => {
  render(<UserCard user={{ name: 'John', email: 'john@test.com' }} />);
  expect(screen.getByText('John')).toBeInTheDocument();
});
```

### Integration Tests
```typescript
// Test multiple units working together
// May use real dependencies or limited mocks

test('user registration flow', async () => {
  const db = await createTestDatabase();
  const userService = new UserService(db);
  const emailService = new MockEmailService();
  
  const user = await userService.register({
    email: 'test@example.com',
    password: 'password123'
  });
  
  expect(user.id).toBeDefined();
  expect(await db.users.findById(user.id)).toBeTruthy();
});
```

### E2E Tests
```typescript
// Test full user flows in real browser
// No mocking, test against real (test) environment

test('user can sign up and create first post', async ({ page }) => {
  await page.goto('/signup');
  await page.fill('[name="email"]', 'test@example.com');
  await page.fill('[name="password"]', 'password123');
  await page.click('button[type="submit"]');
  
  await expect(page).toHaveURL('/dashboard');
  
  await page.click('text=New Post');
  await page.fill('[name="title"]', 'My First Post');
  await page.click('text=Publish');
  
  await expect(page.locator('text=My First Post')).toBeVisible();
});
```

## 4. Mocking Patterns

### Function Mocks
```typescript
// Mock implementation
const mockFetch = vi.fn().mockResolvedValue({ data: [] });

// Mock return value
mockFn.mockReturnValue(42);
mockFn.mockReturnValueOnce(1).mockReturnValueOnce(2);

// Spy on existing function
const spy = vi.spyOn(console, 'log');
expect(spy).toHaveBeenCalledWith('message');
```

### Module Mocks
```typescript
// Mock entire module
vi.mock('@/services/api', () => ({
  fetchUsers: vi.fn().mockResolvedValue([]),
  createUser: vi.fn().mockResolvedValue({ id: '1' })
}));

// Partial mock
vi.mock('@/utils', async () => {
  const actual = await vi.importActual('@/utils');
  return {
    ...actual,
    formatDate: vi.fn().mockReturnValue('mocked date')
  };
});
```

### API Mocks (MSW)
```typescript
import { rest } from 'msw';
import { setupServer } from 'msw/node';

const server = setupServer(
  rest.get('/api/users', (req, res, ctx) => {
    return res(ctx.json([{ id: '1', name: 'John' }]));
  }),
  rest.post('/api/users', (req, res, ctx) => {
    return res(ctx.status(201), ctx.json({ id: '2' }));
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

## 5. Test Data

### Factories
```typescript
// Create consistent test data
function createUser(overrides: Partial<User> = {}): User {
  return {
    id: 'user-1',
    name: 'Test User',
    email: 'test@example.com',
    createdAt: new Date('2024-01-01'),
    ...overrides
  };
}

// Usage
const user = createUser({ name: 'Custom Name' });
const admin = createUser({ role: 'admin' });
```

### Fixtures
```typescript
// fixtures/users.ts
export const testUsers = {
  regularUser: {
    id: 'user-1',
    name: 'Regular User',
    role: 'user'
  },
  adminUser: {
    id: 'admin-1',
    name: 'Admin User',
    role: 'admin'
  }
};
```

## 6. Async Testing

### Promises
```typescript
// Async/await (preferred)
test('fetchUser returns user data', async () => {
  const user = await fetchUser('1');
  expect(user.name).toBe('John');
});

// Error testing
test('fetchUser throws for invalid id', async () => {
  await expect(fetchUser('invalid')).rejects.toThrow('User not found');
});
```

### Waiting for UI
```typescript
// Wait for element
await waitFor(() => {
  expect(screen.getByText('Loaded')).toBeInTheDocument();
});

// Find (has built-in waiting)
const button = await screen.findByRole('button', { name: /submit/i });

// Wait for element to disappear
await waitForElementToBeRemoved(() => screen.queryByText('Loading'));
```

## 7. Coverage Guidelines

### Targets
```
Overall:      70%+
New code:     80%+
Critical:     100%
```

### What to Test
- ✅ Business logic
- ✅ Edge cases and boundaries
- ✅ Error handling paths
- ✅ User interactions
- ✅ State transitions
- ✅ API integrations

### What to Skip
- ❌ Third-party library code
- ❌ Simple getters/setters
- ❌ Framework boilerplate
- ❌ Pure type definitions

## 8. Avoiding Flaky Tests

### Common Causes & Fixes
```typescript
// ❌ Flaky: depends on timing
test('shows notification', () => {
  showNotification();
  expect(screen.getByText('Success')).toBeInTheDocument();
});

// ✅ Fixed: wait for state
test('shows notification', async () => {
  showNotification();
  await waitFor(() => {
    expect(screen.getByText('Success')).toBeInTheDocument();
  });
});

// ❌ Flaky: depends on order
let counter = 0;
test('first test', () => { counter++; });
test('second test', () => { expect(counter).toBe(1); });

// ✅ Fixed: isolate state
beforeEach(() => { counter = 0; });

// ❌ Flaky: real timers
test('debounced search', () => {
  input('query');
  expect(mockSearch).toHaveBeenCalled();
});

// ✅ Fixed: fake timers
test('debounced search', () => {
  vi.useFakeTimers();
  input('query');
  vi.advanceTimersByTime(300);
  expect(mockSearch).toHaveBeenCalled();
  vi.useRealTimers();
});
```

## 9. Test Commands

```bash
# Run all tests
npm test

# Run in watch mode
npm test -- --watch

# Run specific file
npm test -- Button.test.tsx

# Run with coverage
npm test -- --coverage

# Run matching pattern
npm test -- -t "UserService"

# Run only changed files
npm test -- --changed
```

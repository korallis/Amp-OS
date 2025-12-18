---
description: Testing standards and patterns
globs: ["**/*.test.ts", "**/*.test.tsx", "**/*.spec.ts", "**/*.spec.tsx", "**/*.test.js", "**/*.test.jsx", "**/*.spec.js", "**/*.spec.jsx", "**/tests/**", "**/__tests__/**", "!**/node_modules/**", "!**/dist/**", "!**/coverage/**"]
---

# Testing Standards

> **Rule Precedence**: Security > Correctness/Types > Testing > Performance > Style

## Test Structure (AAA Pattern)

```typescript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with valid data', async () => {
      // Arrange
      const userData = { email: 'test@example.com', name: 'Test' };
      const mockRepo = createMockRepo();
      const service = new UserService(mockRepo);
      
      // Act
      const result = await service.createUser(userData);
      
      // Assert
      expect(result.email).toBe(userData.email);
      expect(mockRepo.save).toHaveBeenCalledWith(expect.objectContaining(userData));
    });
    
    it('should throw ValidationError for invalid email', async () => {
      // Arrange
      const userData = { email: 'invalid', name: 'Test' };
      const service = new UserService(createMockRepo());
      
      // Act & Assert
      await expect(service.createUser(userData))
        .rejects.toThrow(ValidationError);
    });
  });
});
```

## Naming Conventions

- Test files: `*.test.ts` or `*.spec.ts`
- Describe blocks: Component/function name
- It blocks: Start with "should" + expected behavior
- Be specific: "should return user when found" not "should work"

## Component Testing

```tsx
import { render, screen, userEvent } from '@testing-library/react';

describe('LoginForm', () => {
  it('should submit form with valid credentials', async () => {
    const onSubmit = vi.fn();
    const user = userEvent.setup();
    
    render(<LoginForm onSubmit={onSubmit} />);
    
    await user.type(screen.getByLabelText(/email/i), 'test@example.com');
    await user.type(screen.getByLabelText(/password/i), 'password123');
    await user.click(screen.getByRole('button', { name: /login/i }));
    
    expect(onSubmit).toHaveBeenCalledWith({
      email: 'test@example.com',
      password: 'password123'
    });
  });
});
```

## Mocking

```typescript
// Mock modules
vi.mock('@/lib/api', () => ({
  fetchUser: vi.fn()
}));

// Mock implementations
const mockFetch = vi.mocked(fetchUser);
mockFetch.mockResolvedValue({ id: '1', name: 'Test' });

// Reset between tests
beforeEach(() => {
  vi.clearAllMocks();
});
```

## API/Integration Tests

- Use MSW (Mock Service Worker) for API mocking
- Test actual HTTP flows, not just function calls
- Verify request payloads and headers

```typescript
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';

const server = setupServer(
  http.get('/api/users/:id', ({ params }) => {
    return HttpResponse.json({ id: params.id, name: 'Test User' });
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

## What NOT to Test

- Implementation details (internal state, private methods)
- Third-party libraries (trust they work)
- Framework internals
- Trivial code (simple getters/setters)

## Coverage Guidelines

- Aim for 80%+ on critical paths
- Don't chase 100% coverage blindly
- Focus on behavior, not lines
- Test edge cases and error paths

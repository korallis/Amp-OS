# CSS & Styling Best Practices

## Naming Convention (BEM)

```css
/* Block */
.card { }

/* Element (belongs to block) */
.card__title { }
.card__image { }

/* Modifier (variation) */
.card--featured { }
.card__title--large { }
```

## CSS Custom Properties

```css
:root {
  /* Colors */
  --color-primary: #3b82f6;
  --color-primary-hover: #2563eb;
  --color-text: #1f2937;
  --color-text-muted: #6b7280;
  --color-background: #ffffff;
  
  /* Spacing scale */
  --space-1: 0.25rem;  /* 4px */
  --space-2: 0.5rem;   /* 8px */
  --space-4: 1rem;     /* 16px */
  --space-8: 2rem;     /* 32px */
  
  /* Typography */
  --font-sans: system-ui, sans-serif;
  --font-mono: ui-monospace, monospace;
  --text-sm: 0.875rem;
  --text-base: 1rem;
  --text-lg: 1.125rem;
  
  /* Borders & Shadows */
  --radius-sm: 0.25rem;
  --radius-md: 0.5rem;
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1);
}
```

## Component Styles (CSS Modules)

```css
/* Button.module.css */
.button {
  padding: var(--space-2) var(--space-4);
  border-radius: var(--radius-md);
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.15s ease;
}

.primary {
  background: var(--color-primary);
  color: white;
}

.primary:hover {
  background: var(--color-primary-hover);
}
```

```jsx
import styles from './Button.module.css';

function Button({ variant = 'primary', children }) {
  return (
    <button className={`${styles.button} ${styles[variant]}`}>
      {children}
    </button>
  );
}
```

## Responsive Design

```css
/* Mobile-first approach */
.container {
  padding: var(--space-4);
}

/* Tablet and up */
@media (min-width: 768px) {
  .container {
    padding: var(--space-8);
    max-width: 768px;
    margin: 0 auto;
  }
}

/* Desktop */
@media (min-width: 1024px) {
  .container {
    max-width: 1024px;
  }
}
```

## Layout Patterns

```css
/* Flexbox centering */
.center {
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Stack (vertical) */
.stack {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

/* Cluster (horizontal wrap) */
.cluster {
  display: flex;
  flex-wrap: wrap;
  gap: var(--space-2);
}

/* Grid auto-fit */
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: var(--space-4);
}
```

## Accessibility

```css
/* Focus styles - never remove, always style */
:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}

/* Reduced motion */
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}

/* Screen reader only */
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  border: 0;
}
```

## Anti-Patterns to Avoid

```css
/* ❌ Avoid magic numbers */
.bad { margin-top: 17px; }

/* ✅ Use spacing scale */
.good { margin-top: var(--space-4); }

/* ❌ Avoid !important */
.bad { color: red !important; }

/* ❌ Avoid deep nesting */
.header .nav .list .item .link { }

/* ✅ Keep selectors flat */
.nav-link { }
```

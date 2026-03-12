---
name: test
description: Genera tests con Vitest y Testing Library para React, Vue y Node.js. Tests unitarios para lógica pura, de integración para hooks y componentes, y E2E con Playwright. Foco en tests que detectan bugs reales, no en coverage artificioso.
argument-hint: [archivo o función a testear]
---

Genera tests para: $ARGUMENTS

Lee el código a testear antes de escribir un solo test. Entiende qué hace, qué puede fallar y qué casos límite tiene.

**Regla de oro:** Un test es valioso si puede fallar cuando el código está roto. Si siempre pasa sin importar la implementación, no sirve.

---

## VITEST — SETUP

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    environment: 'happy-dom',  // o 'node' para backend puro
    globals: true,             // describe, it, expect sin imports
    setupFiles: ['./src/test/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'lcov'],
      thresholds: { lines: 80 },
    },
  },
})

// src/test/setup.ts
import '@testing-library/jest-dom'
import { cleanup } from '@testing-library/react'
import { afterEach } from 'vitest'

afterEach(() => cleanup())
```

---

## TESTS DE LÓGICA PURA (funciones, utils, services)

```typescript
// El tipo de test más valioso — sin mocks, sin DOM, puro
import { describe, it, expect } from 'vitest'
import { calculateDiscount, validateEmail, formatCurrency } from './utils'

describe('calculateDiscount', () => {
  // Test el caso feliz
  it('applies percentage discount correctly', () => {
    expect(calculateDiscount(100, 20)).toBe(80)
  })

  // Tests de edge cases — aquí es donde viven los bugs reales
  it('returns 0 for 100% discount', () => {
    expect(calculateDiscount(100, 100)).toBe(0)
  })

  it('throws for discount > 100%', () => {
    expect(() => calculateDiscount(100, 101)).toThrow('Invalid discount')
  })

  it('handles decimal prices correctly', () => {
    expect(calculateDiscount(10.5, 10)).toBeCloseTo(9.45, 2)
  })

  // Casos límite que los devs olvidan
  it('handles zero price', () => {
    expect(calculateDiscount(0, 50)).toBe(0)
  })
})
```

---

## TESTS DE COMPONENTES REACT

```typescript
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { vi, describe, it, expect, beforeEach } from 'vitest'
import { LoginForm } from './LoginForm'

// ✅ userEvent sobre fireEvent — simula comportamiento real del usuario
const user = userEvent.setup()

describe('LoginForm', () => {
  const mockOnSubmit = vi.fn()

  beforeEach(() => {
    mockOnSubmit.mockClear()
  })

  // Renderiza sin explotar con defaults
  it('renders without crashing', () => {
    render(<LoginForm onSubmit={mockOnSubmit} />)
    expect(screen.getByRole('button', { name: /iniciar sesión/i })).toBeInTheDocument()
  })

  // ✅ getByRole > getByTestId > getByText (más cercano a cómo lo usa el usuario)
  it('submits with correct values', async () => {
    render(<LoginForm onSubmit={mockOnSubmit} />)

    await user.type(screen.getByLabelText(/email/i), 'test@example.com')
    await user.type(screen.getByLabelText(/contraseña/i), 'password123')
    await user.click(screen.getByRole('button', { name: /iniciar sesión/i }))

    expect(mockOnSubmit).toHaveBeenCalledWith({
      email: 'test@example.com',
      password: 'password123',
    })
  })

  // Estados de UI
  it('shows loading state while submitting', async () => {
    mockOnSubmit.mockImplementation(() => new Promise(() => {})) // never resolves
    render(<LoginForm onSubmit={mockOnSubmit} />)

    await user.click(screen.getByRole('button', { name: /iniciar sesión/i }))

    expect(screen.getByRole('button', { name: /cargando/i })).toBeDisabled()
  })

  it('shows validation error for invalid email', async () => {
    render(<LoginForm onSubmit={mockOnSubmit} />)

    await user.type(screen.getByLabelText(/email/i), 'not-an-email')
    await user.click(screen.getByRole('button', { name: /iniciar sesión/i }))

    expect(screen.getByText(/email inválido/i)).toBeInTheDocument()
    expect(mockOnSubmit).not.toHaveBeenCalled()
  })

  // Accesibilidad
  it('is keyboard navigable', async () => {
    render(<LoginForm onSubmit={mockOnSubmit} />)

    await user.tab()
    expect(screen.getByLabelText(/email/i)).toHaveFocus()

    await user.tab()
    expect(screen.getByLabelText(/contraseña/i)).toHaveFocus()
  })
})
```

---

## TESTS DE HOOKS

```typescript
import { renderHook, act, waitFor } from '@testing-library/react'
import { vi, describe, it, expect } from 'vitest'
import { useCounter } from './useCounter'
import { useUsers } from './useUsers'

describe('useCounter', () => {
  it('initializes with given value', () => {
    const { result } = renderHook(() => useCounter(5))
    expect(result.current.count).toBe(5)
  })

  it('increments correctly', () => {
    const { result } = renderHook(() => useCounter(0))

    act(() => result.current.increment())

    expect(result.current.count).toBe(1)
  })
})

describe('useUsers (con fetch)', () => {
  it('fetches users on mount', async () => {
    // Mock de fetch — no llamar a la API real en tests unitarios
    vi.spyOn(global, 'fetch').mockResolvedValueOnce({
      ok: true,
      json: async () => [{ id: '1', name: 'Ana' }],
    } as Response)

    const { result } = renderHook(() => useUsers())

    expect(result.current.isLoading).toBe(true)

    await waitFor(() => {
      expect(result.current.isLoading).toBe(false)
    })

    expect(result.current.users).toHaveLength(1)
    expect(result.current.users[0].name).toBe('Ana')
  })
})
```

---

## TESTS DE COMPONENTS VUE

```typescript
import { mount } from '@vue/test-utils'
import { describe, it, expect, vi } from 'vitest'
import UserCard from './UserCard.vue'

describe('UserCard', () => {
  const user = { id: '1', name: 'Ana García', email: 'ana@example.com' }

  it('renders user data correctly', () => {
    const wrapper = mount(UserCard, { props: { user } })

    expect(wrapper.text()).toContain('Ana García')
    expect(wrapper.text()).toContain('ana@example.com')
  })

  it('emits select event on click', async () => {
    const wrapper = mount(UserCard, { props: { user } })

    await wrapper.trigger('click')

    expect(wrapper.emitted('select')).toHaveLength(1)
    expect(wrapper.emitted('select')![0]).toEqual([user.id])
  })
})
```

---

## TESTS DE LAMBDA / NODE BACKEND

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { UserService } from './service'
import { NotFoundError } from './errors'

// ✅ Testear el service directamente — sin AWS, sin HTTP
// El service es lógica pura con dependencias inyectadas

describe('UserService', () => {
  const mockRepo = {
    findById: vi.fn(),
    create: vi.fn(),
    findByEmail: vi.fn(),
  }

  const service = new UserService(mockRepo)

  beforeEach(() => vi.clearAllMocks())

  it('throws NotFoundError when user does not exist', async () => {
    mockRepo.findById.mockResolvedValue(null)

    await expect(service.getUser('nonexistent')).rejects.toThrow(NotFoundError)
  })

  it('returns user when found', async () => {
    const user = { id: '1', name: 'Ana', email: 'ana@test.com' }
    mockRepo.findById.mockResolvedValue(user)

    const result = await service.getUser('1')

    expect(result).toEqual(user)
    expect(mockRepo.findById).toHaveBeenCalledWith('1')
  })

  it('rejects duplicate email on create', async () => {
    mockRepo.findByEmail.mockResolvedValue({ id: 'existing' })

    await expect(
      service.createUser({ name: 'Bob', email: 'existing@test.com', password: '...' })
    ).rejects.toThrow(/already exists/)
  })
})
```

---

## QUÉ NO TESTEAR

- Getters/setters triviales sin lógica
- Código de terceros (testar tu uso de ellos, no el código de ellos)
- Implementaciones de UI que cambian frecuentemente por diseño
- Tipos TypeScript (el compilador ya los valida)
- Código generado automáticamente

---

## ENTREGA

1. Tests unitarios para toda la lógica pura
2. Tests de componente para los estados más importantes
3. Al menos un test que verifica accesibilidad (getByRole)
4. Mocks solo donde sea necesario para aislar — no mockear lo que se puede instanciar
5. Nombres de test que describen el comportamiento, no la implementación

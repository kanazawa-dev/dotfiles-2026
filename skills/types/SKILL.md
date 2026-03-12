---
name: types
description: Genera o mejora tipos TypeScript con strict mode, utility types avanzados, branded types, discriminated unions, type guards y generics bien diseñados. Elimina cualquier uso de any y fortalece el contrato del código.
argument-hint: [descripción de qué tipar o archivo a revisar]
---

Genera o mejora los tipos TypeScript para: $ARGUMENTS

---

## PRINCIPIOS

**Un buen tipo es:**
- Imposible de construir inválidamente (make illegal states unrepresentable)
- Auto-documentado — el nombre y la forma explican el dominio
- Lo más estrecho posible — no más permisivo de lo necesario

---

## PATRONES ESENCIALES

### Branded types — IDs que no se pueden confundir

```typescript
// ❌ Puedes pasar un userId donde va un postId y TypeScript no se queja
function getPost(userId: string, postId: string) {}

// ✅ Branded types — son strings en runtime, tipos distintos en compile time
declare const __brand: unique symbol
type Brand<T, B> = T & { readonly [__brand]: B }

type UserId = Brand<string, 'UserId'>
type PostId = Brand<string, 'PostId'>
type Email  = Brand<string, 'Email'>

// Constructor con validación
function asUserId(id: string): UserId {
  return id as UserId
}

function getPost(userId: UserId, postId: PostId) {}
// getPost(postId, userId) // ❌ Error de TypeScript — exactamente lo que queremos
```

### Discriminated unions — modelar estados correctamente

```typescript
// ❌ Demasiados campos opcionales — estado implícito y confuso
interface RequestState {
  isLoading: boolean
  data?: User
  error?: Error
}

// ✅ Discriminated union — cada estado es explícito e imposible de mezclar
type RequestState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error }

// TypeScript sabe qué campos existen en cada rama
function render(state: RequestState<User>) {
  switch (state.status) {
    case 'loading': return <Spinner />
    case 'error':   return <Error message={state.error.message} />
    case 'success': return <UserCard user={state.data} />  // data está garantizado
    case 'idle':    return null
  }
}
```

### Type guards — narrowing seguro

```typescript
// Predicate function — preferir sobre as Type
function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    'email' in value &&
    typeof (value as User).id === 'string' &&
    typeof (value as User).email === 'string'
  )
}

// Assertion function — lanza si no cumple
function assertIsUser(value: unknown): asserts value is User {
  if (!isUser(value)) throw new TypeError('Expected User')
}

// Para discriminated unions
function isSuccess<T>(state: RequestState<T>): state is Extract<RequestState<T>, { status: 'success' }> {
  return state.status === 'success'
}
```

### Utility types avanzados

```typescript
// Los básicos que todos conocen
type Partial<T>  // todos opcionales
type Required<T> // todos requeridos
type Pick<T, K>  // solo algunas keys
type Omit<T, K>  // todas menos algunas
type Readonly<T>
type Record<K, V>

// Los que se usan menos y deberían usarse más
type ReturnType<typeof fn>  // tipo de retorno de una función
type Parameters<typeof fn>  // tipos de parámetros como tuple
type Awaited<Promise<T>>    // T — unwrap de Promise

// Deep readonly (TypeScript no lo incluye, construirlo)
type DeepReadonly<T> = {
  readonly [K in keyof T]: T[K] extends object ? DeepReadonly<T[K]> : T[K]
}

// NonNullable
type NonNullable<T> = T extends null | undefined ? never : T

// Extraer/Excluir de unions
type WithoutError<T> = Exclude<T, { status: 'error' }>
type OnlySuccess<T> = Extract<T, { status: 'success' }>
```

### Generics bien diseñados

```typescript
// ❌ Generic que no aporta nada
function identity<T>(value: T): T { return value }

// ✅ Generic con constraint significativo
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key]
}

// ✅ Generic con default
type ApiResponse<T = unknown> = {
  data: T
  meta: { timestamp: string; version: string }
}

// ✅ Conditional types para casos avanzados
type Flatten<T> = T extends Array<infer Item> ? Item : T
// Flatten<string[]> = string
// Flatten<string>   = string

// ✅ Template literal types para string patterns
type EventName = `on${Capitalize<string>}`
type CSSProperty = `${string}-${string}`
type HttpMethod = 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE'
type ApiEndpoint = `/${string}`
```

### Const assertions y satisfies

```typescript
// satisfies — valida tipo sin ampliar
const config = {
  theme: 'dark',
  lang: 'es',
  features: ['auth', 'payments'],
} satisfies Config
// config.theme sigue siendo 'dark', no string

// as const — literales en vez de tipos amplios
const ROLES = ['admin', 'user', 'guest'] as const
type Role = typeof ROLES[number]  // 'admin' | 'user' | 'guest'

// Object con keys tipadas como union
const ERRORS = {
  NOT_FOUND: 'Resource not found',
  UNAUTHORIZED: 'Unauthorized',
} as const satisfies Record<string, string>

type ErrorCode = keyof typeof ERRORS
```

---

## ANTI-PATRONES A ELIMINAR

```typescript
// ❌ any — siempre hay alternativa
const data: any = await fetch(url).then(r => r.json())
// ✅
const data = await fetch(url).then(r => r.json() as Promise<ApiResponse>)
// ✅ o mejor, usar Zod para validar en runtime

// ❌ Type assertion sin motivo
const user = response as User
// ✅ Type guard o validación
if (isUser(response)) { /* usa response */ }

// ❌ Object con index signature amplio
type Config = { [key: string]: any }
// ✅ Record con tipos concretos
type Config = Record<string, string | number | boolean>
// ✅ O mejor, tipo explícito con todos los campos

// ❌ Non-null assertion sin garantía
const user = getUser()!
// ✅ Manejo explícito
const user = getUser()
if (!user) throw new Error('User not found')

// ❌ Enum de TypeScript (genera código JS, problemas de tree-shaking)
enum Direction { Up, Down }
// ✅ Union de string literals
type Direction = 'up' | 'down'
// ✅ O const object si necesitas iterar
const Direction = { Up: 'up', Down: 'down' } as const
type Direction = typeof Direction[keyof typeof Direction]
```

---

## ENTREGA

1. Tipos completos con comentarios JSDoc donde no sean obvios
2. Type guards para los tipos más importantes
3. Branded types para IDs y valores con semántica específica
4. Ejemplos de uso mostrando cómo TypeScript ayuda a prevenir bugs
5. Migración desde `any` o tipos débiles si los hay

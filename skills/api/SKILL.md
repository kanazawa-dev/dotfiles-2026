---
name: api
description: Diseña o revisa APIs REST o tRPC en TypeScript con convenciones claras, validación Zod, error handling consistente, autenticación, rate limiting y documentación OpenAPI. Enfocado en APIs que otros van a consumir y mantener.
argument-hint: [rest|trpc] [recurso o endpoint a diseñar]
---

Diseña o revisa la API para: $ARGUMENTS

Primero determina:
- ¿REST o tRPC? (tRPC solo si el cliente es TypeScript y fullstack)
- ¿API pública (third-party) o interna (mismo equipo)?
- ¿Qué framework? (Next.js Route Handlers, Hono, Fastify, Express)
- ¿Hay autenticación ya? ¿Qué tipo? (JWT, sessions, API keys)

---

## REST — CONVENCIONES

### URLs y métodos

```
# Recursos en plural, sustantivos, lowercase con kebab-case
GET    /users                    → lista paginada
GET    /users/:id                → uno por ID
POST   /users                   → crear
PATCH  /users/:id                → actualizar parcialmente (preferir sobre PUT)
DELETE /users/:id                → eliminar

# Relaciones — anidado solo 1 nivel
GET    /users/:id/posts          → posts de un usuario
POST   /users/:id/posts          → crear post para un usuario

# Acciones que no son CRUD — verbos como sub-recursos
POST   /users/:id/verify-email   # ✅
POST   /users/:id/archive        # ✅
POST   /invoices/:id/send        # ✅

# ❌ Nunca verbos en la URL
GET    /getUsers
POST   /createUser
POST   /users/doArchive
```

### Respuestas HTTP consistentes

```typescript
// Estructura de respuesta siempre igual
type ApiResponse<T> = {
  data: T
  meta?: {
    page: number
    pageSize: number
    totalCount: number
    totalPages: number
  }
}

type ApiError = {
  error: {
    code: string        // machine-readable: "VALIDATION_ERROR", "NOT_FOUND"
    message: string     // human-readable
    details?: unknown   // campos específicos en validación
    requestId: string   // para debugging
  }
}

// Status codes correctos:
// 200 OK           → GET, PATCH exitoso
// 201 Created      → POST exitoso (con Location header al nuevo recurso)
// 204 No Content   → DELETE exitoso
// 400 Bad Request  → validación fallida, request malformado
// 401 Unauthorized → no autenticado
// 403 Forbidden    → autenticado pero sin permiso
// 404 Not Found    → recurso no existe
// 409 Conflict     → conflicto de estado (email duplicado, etc.)
// 422 Unprocessable → semánticamente inválido (negocio rechaza)
// 429 Too Many Requests → rate limit
// 500 Internal Server Error → bug nuestro
```

### Handler en Next.js Route Handler

```typescript
// app/api/users/[id]/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { z } from 'zod'
import { UserService } from '@/services/user'
import { withAuth, type AuthContext } from '@/lib/auth'
import { ApiError, NotFoundError } from '@/lib/errors'

const UpdateUserSchema = z.object({
  name: z.string().min(1).max(100).optional(),
  email: z.string().email().optional(),
}).refine(data => Object.keys(data).length > 0, {
  message: 'At least one field required'
})

// ✅ Handler tipado, con auth, con validación, con errores consistentes
export const PATCH = withAuth(async (
  request: NextRequest,
  { params, user }: { params: { id: string }; user: AuthContext }
) => {
  // Autorización — ¿puede este usuario modificar este recurso?
  if (user.id !== params.id && !user.isAdmin) {
    return NextResponse.json(
      { error: { code: 'FORBIDDEN', message: 'Not allowed', requestId: crypto.randomUUID() } },
      { status: 403 }
    )
  }

  // Validación
  const body = await request.json().catch(() => null)
  const parsed = UpdateUserSchema.safeParse(body)

  if (!parsed.success) {
    return NextResponse.json(
      {
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Invalid request body',
          details: parsed.error.flatten(),
          requestId: crypto.randomUUID(),
        }
      },
      { status: 400 }
    )
  }

  // Lógica de negocio
  try {
    const updated = await UserService.update(params.id, parsed.data)
    return NextResponse.json({ data: updated })
  } catch (error) {
    if (error instanceof NotFoundError) {
      return NextResponse.json(
        { error: { code: 'NOT_FOUND', message: error.message, requestId: crypto.randomUUID() } },
        { status: 404 }
      )
    }
    throw error  // dejar que el error handler global lo capture
  }
})
```

---

## PAGINACIÓN

```typescript
// Cursor-based — para feeds y listas que cambian frecuentemente
GET /posts?cursor=eyJpZCI6MTIzfQ&limit=20

type CursorPaginatedResponse<T> = {
  data: T[]
  pagination: {
    nextCursor: string | null
    hasMore: boolean
  }
}

// Offset — para tablas con navegación por página
GET /users?page=2&pageSize=20&sort=createdAt&order=desc

type OffsetPaginatedResponse<T> = {
  data: T[]
  meta: {
    page: number
    pageSize: number
    totalCount: number
    totalPages: number
  }
}
```

---

## TRPC — CUANDO EL CLIENTE ES TYPESCRIPT

```typescript
// server/routers/user.ts
import { z } from 'zod'
import { createTRPCRouter, protectedProcedure, publicProcedure } from '../trpc'
import { TRPCError } from '@trpc/server'

export const userRouter = createTRPCRouter({
  // Query — lectura
  byId: protectedProcedure
    .input(z.object({ id: z.string().uuid() }))
    .query(async ({ input, ctx }) => {
      const user = await ctx.db.user.findUnique({ where: { id: input.id } })
      if (!user) throw new TRPCError({ code: 'NOT_FOUND', message: 'User not found' })
      return user
    }),

  // Mutation — escritura
  update: protectedProcedure
    .input(z.object({
      id: z.string().uuid(),
      name: z.string().min(1).max(100).optional(),
      email: z.string().email().optional(),
    }))
    .mutation(async ({ input, ctx }) => {
      // Autorización
      if (input.id !== ctx.session.user.id) {
        throw new TRPCError({ code: 'FORBIDDEN' })
      }
      return ctx.db.user.update({ where: { id: input.id }, data: input })
    }),

  // Infinite query — para listas paginadas con "cargar más"
  list: protectedProcedure
    .input(z.object({
      cursor: z.string().optional(),
      limit: z.number().min(1).max(100).default(20),
    }))
    .query(async ({ input, ctx }) => {
      const items = await ctx.db.user.findMany({
        take: input.limit + 1,
        cursor: input.cursor ? { id: input.cursor } : undefined,
        orderBy: { createdAt: 'desc' },
      })

      const nextCursor = items.length > input.limit ? items.pop()!.id : undefined
      return { items, nextCursor }
    }),
})

// Cliente — 100% type-safe sin codegen
const { data } = api.user.byId.useQuery({ id: userId })
//      ^-- TypeScript sabe exactamente el tipo
```

---

## SEGURIDAD

```typescript
// Rate limiting con Upstash Redis
import { Ratelimit } from '@upstash/ratelimit'
import { Redis } from '@upstash/redis'

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, '10s'),  // 10 req / 10 seg
})

// En el middleware o handler
const { success, limit, remaining } = await ratelimit.limit(identifier)
if (!success) {
  return NextResponse.json(
    { error: { code: 'RATE_LIMIT_EXCEEDED', message: 'Too many requests' } },
    {
      status: 429,
      headers: {
        'X-RateLimit-Limit': String(limit),
        'X-RateLimit-Remaining': String(remaining),
        'Retry-After': '10',
      }
    }
  )
}

// Validar Content-Type en POST/PATCH
// Nunca confiar en el Content-Type del cliente para parsing
// Siempre sanitizar inputs que van a DB o que se muestran en UI
```

---

## ENTREGA

1. **Definición de endpoints** con URLs, métodos, request body y response
2. **Schemas Zod** para validación de inputs
3. **Implementación del handler** con auth, validación y error handling
4. **Tipos de respuesta** compartidos entre cliente y servidor
5. **Rate limiting** si es endpoint público o sensible
6. **Ejemplos de uso desde el cliente** (fetch, axios o tRPC)
7. **Errores posibles** documentados con sus status codes y códigos

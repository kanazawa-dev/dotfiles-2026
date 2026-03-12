---
name: graphql
description: Diseña schemas GraphQL y resolvers TypeScript production-ready con union types para errores, paginación cursor-based, DataLoaders para N+1, seguridad y codegen. Tanto servidor como cliente (React/Vue con TanStack Query o Apollo).
argument-hint: [schema|resolver|query|client] [descripción]
---

Diseña o revisa GraphQL para: $ARGUMENTS

Primero determina:
- ¿Es diseño de schema, implementación de resolvers, query del cliente, o todo?
- ¿Qué servidor usa? (Apollo Server, Pothos, Yoga, Mercurius)
- ¿Qué cliente usa? (Apollo Client, urql, TanStack Query + graphql-request)
- ¿Hay codegen configurado? (graphql-codegen)

---

## SCHEMA DESIGN

### Errores — union types, no null ni excepciones

```graphql
# ❌ El cliente no sabe qué salió mal
type Mutation {
  createUser(input: CreateUserInput!): User
}

# ✅ Los errores son parte del contrato de la API
type Mutation {
  createUser(input: CreateUserInput!): CreateUserResult!
}

union CreateUserResult = User | ValidationError | EmailAlreadyExistsError

type ValidationError {
  field: String!
  message: String!
}

type EmailAlreadyExistsError {
  email: String!
  message: String!
}
```

### Paginación

```graphql
# Cursor-based (Relay spec) — para listas grandes y feeds
type UserConnection {
  edges: [UserEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

type UserEdge {
  node: User!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}

type Query {
  users(first: Int, after: String, last: Int, before: String): UserConnection!
}

# Offset — solo para listas pequeñas y estáticas
type Query {
  categories(limit: Int = 20, offset: Int = 0): [Category!]!
}
```

### Tipos de datos

```graphql
# Scalars personalizados para tipos con semántica específica
scalar DateTime   # ISO 8601
scalar Email      # validado en runtime
scalar UUID       # formato uuid v4
scalar URL        # URL válida

# Nunca exponer IDs de base de datos — usar IDs opacos o UUIDs
type User {
  id: ID!           # UUID, no auto-increment de DB
  email: Email!
  createdAt: DateTime!
}

# Input types separados para mutations (nunca reusar tipos de output como input)
input CreateUserInput {
  name: String!
  email: Email!
  password: String!
}

input UpdateUserInput {
  name: String
  email: Email
  # password no — cambio de password es operación separada
}
```

---

## RESOLVERS EN TYPESCRIPT

### Tipado con Pothos (recomendado) o graphql-codegen

```typescript
// Con graphql-codegen + typescript-resolvers
import type { Resolvers } from './__generated__/types'
import type { Context } from './context'

export const userResolvers: Resolvers<Context> = {
  Query: {
    user: async (_parent, { id }, { dataSources, user }) => {
      if (!user) throw new AuthenticationError('Not authenticated')
      return dataSources.userAPI.findById(id)
    },
  },

  User: {
    // Resolver de campo — solo se ejecuta si el cliente lo pide
    posts: async (parent, { first = 10, after }, { loaders }) => {
      // ✅ DataLoader — nunca hacer query por cada user
      return loaders.postsByUserId.load({ userId: parent.id, first, after })
    },
  },

  Mutation: {
    createUser: async (_parent, { input }, { dataSources }) => {
      // Validar primero
      const existing = await dataSources.userAPI.findByEmail(input.email)
      if (existing) {
        return { __typename: 'EmailAlreadyExistsError', email: input.email, message: '...' }
      }

      const user = await dataSources.userAPI.create(input)
      return { __typename: 'User', ...user }
    },
  },
}
```

### DataLoaders — obligatorio para relaciones

```typescript
// loaders.ts — un DataLoader por relación, inicializado por request
import DataLoader from 'dataloader'

export function createLoaders(db: Database) {
  return {
    // ✅ Batch: recibe [userId1, userId2, ...] y hace UNA query
    userById: new DataLoader<string, User>(async (ids) => {
      const users = await db.user.findMany({ where: { id: { in: [...ids] } } })
      const userMap = new Map(users.map(u => [u.id, u]))
      // DataLoader requiere mismo orden y mismo largo que ids
      return ids.map(id => userMap.get(id) ?? new Error(`User ${id} not found`))
    }),

    postsByUserId: new DataLoader<string, Post[]>(async (userIds) => {
      const posts = await db.post.findMany({
        where: { authorId: { in: [...userIds] } }
      })
      return userIds.map(id => posts.filter(p => p.authorId === id))
    }),
  }
}

// Context — los loaders se crean por request
export type Context = {
  user: AuthUser | null
  loaders: ReturnType<typeof createLoaders>
  db: Database
}
```

---

## CLIENTE (React/Vue)

### Con TanStack Query + graphql-request (recomendado)

```typescript
// queries/user.ts — generado por codegen o escrito a mano
import { gql } from 'graphql-tag'

// Fragments para colocación — el componente declara qué data necesita
export const USER_FRAGMENT = gql`
  fragment UserCard on User {
    id
    name
    email
    avatarUrl
  }
`

export const GET_USER = gql`
  query GetUser($id: ID!) {
    user(id: $id) {
      ...UserCard
      posts(first: 5) {
        edges {
          node {
            id
            title
            publishedAt
          }
        }
      }
    }
  }
  ${USER_FRAGMENT}
`

// Hook generado por codegen o escrito a mano
export function useUser(id: string) {
  return useQuery({
    queryKey: ['user', id],
    queryFn: () => graphqlClient.request<GetUserQuery>(GET_USER, { id }),
    enabled: Boolean(id),
  })
}
```

### Mutations con optimistic updates

```typescript
export function useCreatePost() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (input: CreatePostInput) =>
      graphqlClient.request<CreatePostMutation>(CREATE_POST, { input }),

    // Actualizar la cache antes de que responda el servidor
    onMutate: async (input) => {
      await queryClient.cancelQueries({ queryKey: ['posts'] })
      const previous = queryClient.getQueryData(['posts'])

      queryClient.setQueryData(['posts'], (old: PostsQuery) => ({
        ...old,
        posts: { edges: [{ node: { id: 'temp', ...input } }, ...old.posts.edges] }
      }))

      return { previous }
    },

    onError: (_err, _vars, context) => {
      // Revertir si falla
      queryClient.setQueryData(['posts'], context?.previous)
    },

    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['posts'] })
    },
  })
}
```

---

## SEGURIDAD

```typescript
// Limitar profundidad — plugin para Apollo Server
import depthLimit from 'graphql-depth-limit'
import { createComplexityLimitRule } from 'graphql-validation-complexity'

const server = new ApolloServer({
  validationRules: [
    depthLimit(7),
    createComplexityLimitRule(1000, {
      scalarCost: 1,
      objectCost: 2,
      listFactor: 10,
    }),
  ],
})

// Persisted queries — solo queries pre-registradas en producción
// Deshabilitar introspección en producción
const server = new ApolloServer({
  introspection: process.env.NODE_ENV !== 'production',
})
```

---

## ENTREGA

1. **Schema GraphQL** completo con union types para errores
2. **Resolvers TypeScript** tipados con Context
3. **DataLoaders** para todas las relaciones que pueden ser N+1
4. **Queries/mutations del cliente** con fragments y hooks
5. **Configuración de codegen** si no existe
6. **Reglas de seguridad** (depth limit, complexity)
7. **Notas** sobre decisiones de diseño no obvias

---
name: perf
description: Analiza y optimiza performance de aplicaciones React, Next.js, Vue y Node.js/Lambda. Identifica re-renders innecesarios, bundle size, Core Web Vitals, queries lentas y bottlenecks de runtime con soluciones concretas y medibles.
argument-hint: [componente, página, endpoint o área a optimizar]
---

Analiza y optimiza la performance de: $ARGUMENTS

**Regla fundamental:** No optimizar sin medir. Cada cambio de performance debe tener un before/after medible. La optimización prematura genera deuda técnica sin beneficio real.

---

## FRONTEND — DIAGNOSTICAR PRIMERO

Antes de cambiar código, medir:

```bash
# Core Web Vitals en desarrollo
npx unlighthouse-cli --site http://localhost:3000

# Bundle analysis
npx @next/bundle-analyzer    # Next.js
npx vite-bundle-visualizer   # Vite/Vue
npx webpack-bundle-analyzer  # Webpack

# Profiling de re-renders en React
# React DevTools → Profiler → Record → interactuar → Stop
# Buscar barras largas y componentes que renderizan más veces de lo esperado
```

---

## RE-RENDERS EN REACT

### Identificar qué se re-renderiza

```tsx
// Temporal para debugging — agregar al componente sospechoso
import { useRef } from 'react'

function ExpensiveComponent({ data }: Props) {
  const renderCount = useRef(0)
  renderCount.current++
  console.log(`Renders: ${renderCount.current}`)
  // ...
}
```

### Causas más comunes y soluciones

```tsx
// ❌ Objeto/array creado en cada render = nueva referencia = re-render del hijo
function Parent() {
  return <Child config={{ theme: 'dark' }} />  // nuevo objeto en cada render
}

// ✅ Mover fuera del componente si es constante
const CONFIG = { theme: 'dark' } as const
function Parent() {
  return <Child config={CONFIG} />
}

// ❌ Función creada en cada render
function Parent({ id }: { id: string }) {
  return <Child onDelete={() => deleteItem(id)} />  // nueva función cada vez
}

// ✅ useCallback si el hijo está memoizado
function Parent({ id }: { id: string }) {
  const handleDelete = useCallback(() => deleteItem(id), [id])
  return <Child onDelete={handleDelete} />
}

// ❌ Context que re-renderiza todo cuando cambia cualquier valor
const AppContext = createContext({ user: null, theme: 'dark', cart: [] })

// ✅ Separar contexts por frecuencia de actualización
const UserContext  = createContext<User | null>(null)   // cambia raro
const ThemeContext = createContext<Theme>('dark')        // cambia raro
const CartContext  = createContext<Cart>([])             // cambia frecuente

// ✅ memo para evitar re-renders del hijo cuando el padre se actualiza
const ExpensiveList = memo(function ExpensiveList({ items }: { items: Item[] }) {
  return <>{items.map(item => <Item key={item.id} {...item} />)}</>
}, (prev, next) => prev.items === next.items)  // comparación custom si necesario
```

### useMemo y useCallback — cuándo SÍ usarlos

```tsx
// ✅ useMemo para cálculos realmente costosos
const sortedAndFiltered = useMemo(() => {
  return largeArray
    .filter(item => item.category === activeCategory)
    .sort((a, b) => b.date.localeCompare(a.date))
}, [largeArray, activeCategory])  // solo recalcula cuando cambian estas deps

// ✅ useMemo para valores de Context (evita re-renders en todos los consumers)
const contextValue = useMemo(
  () => ({ user, login, logout }),
  [user]  // login y logout son estables con useCallback
)

// ❌ useMemo para cálculos triviales — el overhead supera el beneficio
const doubled = useMemo(() => value * 2, [value])  // NO HACER
const doubled = value * 2  // simplemente esto
```

---

## NEXT.JS — ESPECÍFICO

```tsx
// ❌ "use client" en el Layout completo
// ✅ Bajar "use client" al componente más pequeño que lo necesita

// ❌ Fetch en el cliente (waterfall)
function Page() {
  const { data } = useQuery(...)  // espera al render, luego fetcha
}

// ✅ Fetch en el servidor
async function Page() {
  const data = await fetch(...)  // datos listos antes de renderizar
  return <Component data={data} />
}

// ✅ Parallel data fetching en el servidor
async function Page({ params }: { params: { id: string } }) {
  // ✅ En paralelo, no en secuencia
  const [user, posts] = await Promise.all([
    getUser(params.id),
    getPosts(params.id),
  ])
  return <UserPage user={user} posts={posts} />
}

// ✅ Streaming con Suspense para parts lentas
import { Suspense } from 'react'

async function Page() {
  const fastData = await getFastData()
  return (
    <>
      <FastComponent data={fastData} />
      <Suspense fallback={<Skeleton />}>
        <SlowComponent />  {/* Carga independientemente */}
      </Suspense>
    </>
  )
}
```

---

## BUNDLE SIZE

```tsx
// ❌ Importar toda la librería
import { format } from 'date-fns'
import _ from 'lodash'

// ✅ Importar solo lo que se usa
import format from 'date-fns/format'
import get from 'lodash/get'

// ✅ Dynamic import para código pesado que no se necesita al inicio
const HeavyChart = dynamic(() => import('./HeavyChart'), {
  loading: () => <Skeleton />,
  ssr: false,  // si usa browser APIs
})

// ✅ Route-based code splitting (automático en Next.js App Router)
// Cada page.tsx es su propio chunk

// Analizar qué pesa más:
// 1. Instalar: npm install @next/bundle-analyzer
// 2. Ejecutar: ANALYZE=true next build
// 3. Buscar: módulos >50KB que podrían ser lazy o reemplazados
```

---

## IMÁGENES Y ASSETS

```tsx
// ❌ <img> nativo — sin optimización, sin lazy loading, layout shift
<img src="/hero.jpg" alt="Hero" />

// ✅ next/image — optimización automática, lazy loading, sin layout shift
import Image from 'next/image'
<Image
  src="/hero.jpg"
  alt="Hero"
  width={1200}
  height={630}
  priority  // solo para above-the-fold
  placeholder="blur"
  blurDataURL="data:..."
/>

// Formatos modernos: WebP/AVIF automático con next/image
// Para SVGs: importar directamente como componente
import Logo from './logo.svg'
```

---

## NODE.JS / LAMBDA BACKEND

```typescript
// ❌ Operaciones en secuencia cuando pueden ser paralelas
const user  = await db.user.findById(userId)
const posts = await db.post.findByUserId(userId)  // espera a user innecesariamente

// ✅ En paralelo
const [user, posts] = await Promise.all([
  db.user.findById(userId),
  db.post.findByUserId(userId),
])

// ❌ N+1 — query por cada item
const users = await db.user.findAll()
const usersWithPosts = await Promise.all(
  users.map(u => db.post.findByUserId(u.id))  // N queries
)

// ✅ Una query con join o include
const users = await db.user.findAll({
  include: { posts: true }
})

// ✅ O DataLoader para GraphQL
const posts = await dataloader.postsByUserId.loadMany(users.map(u => u.id))

// Caché de resultados costosos
import { LRUCache } from 'lru-cache'

const cache = new LRUCache<string, User>({ max: 1000, ttl: 60_000 })

async function getUser(id: string): Promise<User> {
  const cached = cache.get(id)
  if (cached) return cached

  const user = await db.user.findById(id)
  cache.set(id, user)
  return user
}
```

---

## ENTREGA

1. **Diagnóstico** — qué se midió y qué se encontró (antes de proponer soluciones)
2. **Cambios concretos** con before/after de código
3. **Impacto esperado** — qué métrica mejora y cuánto
4. **Cómo verificar** — comando o herramienta para confirmar la mejora
5. **Qué NO cambiar** — optimizaciones que no valen el costo de complejidad

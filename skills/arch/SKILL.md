---
name: arch
description: Analiza y diseña la arquitectura de un sistema o feature. Evalúa separación de concerns, flujo de datos, escalabilidad, boundaries entre capas y decisiones de stack. Produce ADRs y diagramas en texto.
argument-hint: [feature o sistema a diseñar/revisar]
---

Analiza o diseña la arquitectura para: $ARGUMENTS

Primero lee el proyecto existente para entender el stack actual, los patterns ya establecidos y las decisiones previas. No propongas cambiar lo que ya funciona bien.

---

## PREGUNTAS QUE RESPONDER PRIMERO

Antes de proponer cualquier arquitectura, responde:

1. **¿Cuál es el problema real?** ¿Qué hace el sistema que hoy no puede hacer?
2. **¿Cuántos usuarios?** Las necesidades de 100 usuarios ≠ 100k ≠ 1M
3. **¿Cuáles son los SLOs?** Disponibilidad, latencia, consistencia requerida
4. **¿Qué puede fallar y qué consecuencia tiene?**
5. **¿Cuántas personas van a mantener esto?** La arquitectura correcta para 2 devs ≠ 20 devs

---

## CAPAS Y BOUNDARIES

### Frontend (Next.js / React / Vue)

```
pages / app /          → routing, auth guards, metadata
components/
  ui/                  → primitivos (Button, Input, Modal) — sin lógica de negocio
  features/            → componentes con lógica de dominio
  layouts/             → estructura de página
hooks / composables/   → lógica reutilizable, state management
services/              → llamadas a API, transformación de datos
stores/                → estado global (Zustand, Pinia)
types/                 → tipos compartidos
```

**Regla de dependencias:**
- `ui` no importa de `features`
- `components` no importa de `pages`
- `hooks` no importan de `components`
- Todo fluye hacia adentro, nunca hacia afuera

### Backend / Lambda

```
handler / controller   → entrada HTTP/event, validación de request, respuesta
service / use-case     → lógica de negocio pura — testeable sin infraestructura
repository             → acceso a datos — interfaz de la DB
infrastructure/        → implementaciones concretas (DynamoDB, PostgreSQL, S3)
domain/                → tipos y reglas de dominio
```

**Regla clave:** El service no sabe qué DB usa. El repository no sabe qué hace el service.

---

## PATRONES POR ESCENARIO

### CRUD simple con Next.js + DB
```
Cliente → Next.js Server Actions / Route Handlers → Prisma → PostgreSQL
```
- No necesita arquitectura compleja
- Server Actions para mutations (elimina API layer innecesaria)
- Zod para validación server-side
- ORM directo está bien para <100k operaciones/día

### API pública con múltiples clientes
```
Clientes (web, mobile, third-party)
  → API Gateway
    → Lambda por dominio (usuarios, pedidos, pagos)
      → DynamoDB / Aurora Serverless
```
- GraphQL si los clientes tienen necesidades de datos muy distintas
- REST si el contrato es estable y los clientes son conocidos
- Separar Lambdas por dominio, no por operación CRUD

### Procesamiento asíncrono
```
API / Event → SQS → Lambda processor → DB / S3
                ↓
           DLQ (dead letter queue) → alertas
```
- SQS para desacoplar productores y consumidores
- Siempre DLQ configurada
- Idempotencia en el procesador (SQS puede re-entregar)
- Visibility timeout > tiempo máximo de procesamiento

### Real-time features
```
Cliente → API Gateway WebSocket → Lambda (connect/disconnect/message)
                                    → DynamoDB (connections table)
                                    → SNS → broadcast a conexiones activas
```
- WebSockets para bi-directional real-time
- Server-Sent Events para uni-directional (más simple)
- Polling si la latencia puede ser de segundos

---

## ESTADO Y DATA FLOW

### Frontend state — ¿dónde vive cada tipo de dato?

```
URL params / query string  → estado que debe ser shareable y bookmarkable
                             (filtros, búsqueda, paginación, tab activo)

Server state (React Query / TanStack Query / SWR)
                           → datos del servidor, caché automática, revalidación
                             (users, posts, productos — cualquier cosa del backend)

Local component state      → UI state efímero (modal abierto, input value)

Global client state (Zustand / Pinia)
                           → estado del usuario autenticado, preferencias, carrito
                             Solo si realmente necesita ser global
```

**Regla:** Empieza con URL params + server state. Agrega global state solo cuando sea necesario.

---

## DECISIONES COMUNES

### SQL vs NoSQL
- **PostgreSQL**: relaciones complejas, transacciones, consultas ad-hoc, reporting
- **DynamoDB**: acceso por key conocida, escala masiva, single-digit ms latency, serverless

### Monolito vs microservicios
- Empieza monolítico. Extrae servicios solo cuando:
  - Un equipo distinto dueño de ese dominio
  - Necesidades de escala radicalmente distintas
  - Deploy independiente es un requerimiento

### REST vs GraphQL vs tRPC
- **REST**: contrato estable, múltiples clientes externos, caching HTTP
- **GraphQL**: múltiples clientes con necesidades de datos distintas, schema como contrato
- **tRPC**: stack TypeScript full-stack, type safety end-to-end sin codegen

---

## ENTREGA

1. **Diagrama en texto** (ASCII o mermaid) del flujo principal
2. **Estructura de carpetas** propuesta
3. **Decisiones clave** con alternativas consideradas
4. **ADR (Architecture Decision Record)** para cada decisión significativa:
   ```
   ## ADR-001: [Título]
   **Contexto:** Por qué se necesita tomar esta decisión
   **Decisión:** Qué se decidió
   **Alternativas consideradas:** Qué más se evaluó y por qué no
   **Consecuencias:** Trade-offs aceptados
   ```
5. **Riesgos identificados** y cómo mitigarlos
6. **Lo que NO incluir** — qué no construir ahora aunque parezca buena idea

---
name: review
description: Code review profundo para TypeScript, React, Next.js, Vue, GraphQL y Rust. Detecta bugs reales, problemas de performance, vulnerabilidades de seguridad y deuda técnica con ejemplos concretos de cómo arreglarlos.
argument-hint: [archivo o contexto a revisar]
---

Haz un code review exhaustivo de $ARGUMENTS. Si no se especifica, revisa el archivo o PR actual.

Lee el código completo antes de hacer cualquier comentario. Entiende la intención antes de criticar la implementación.

---

## PASO 1 — Correctitud y bugs

Busca activamente:

**JavaScript/TypeScript:**
- `await` faltante en operaciones async (error silencioso común)
- Mutación de estado directamente en lugar de crear nuevo objeto
- Closures que capturan variables en loops (`for (let i...)` vs `for (var i...)`)
- `.filter().map()` cuando un `.reduce()` sería una pasada
- `===` vs `==`, conversiones implícitas de tipo
- `parseInt()` sin radix, `parseFloat()` con strings inesperados
- Optional chaining `?.` faltante donde puede haber null
- Short-circuit evaluation usada para side effects (`x && doThing()`) — usar if

**TypeScript específico:**
- `any` sin justificación — proponer el tipo correcto
- `as Type` (type assertion) ocultando un error real
- Tipos union no exhaustivos sin `never` check al final
- `!` (non-null assertion) sin garantía en runtime
- Enums numéricos de TypeScript — preferir const enums o union de strings
- `interface` vs `type`: usar interface para objetos extensibles, type para unions/intersecciones/primitivos

**React:**
- `useEffect` con dependencias faltantes o mal puestas
- Estado que puede derivarse de props/otros estado (no necesita useState)
- Key prop usando index de array en listas que se reordenan
- Event handlers creados inline en render causando re-renders
- Refs mutadas durante render
- Context que re-renderiza todo cuando solo debería actualizar parte

**Vue:**
- Watchers con lógica que debería ser computed
- `reactive()` en primitivos (usar `ref()`)
- `v-if` y `v-for` en el mismo elemento
- Props mutadas directamente en el componente hijo

**Rust:**
- `unwrap()` / `expect()` sin justificación — proponer manejo de error
- Clones innecesarios que debería ser una referencia
- `panic!` en código de biblioteca
- Lifetimes elididos donde ser explícito mejoraría la legibilidad

---

## PASO 2 — Seguridad

**Crítico — buscar siempre:**
- Secrets, API keys, tokens en código fuente o comentarios
- `eval()` o `new Function()` con input del usuario
- `dangerouslySetInnerHTML` sin sanitización previa
- SQL construido con concatenación de strings
- Variables de entorno con `NEXT_PUBLIC_` que no deberían ser públicas
- Inputs de usuario usados directamente en nombres de archivo o paths
- `JSON.parse()` sin try/catch (puede tirar)
- CORS configurado con `*` en producción
- Cookies sin `httpOnly`, `secure`, `sameSite`
- Dependencias con vulnerabilidades conocidas

**Importante:**
- Rate limiting ausente en endpoints que lo necesitan
- Autenticación verificada en cada ruta protegida, no solo en middleware
- IDs de base de datos expuestos directamente (usar UUIDs o IDs opacos)
- Logs que incluyen datos sensibles (passwords, tokens, PII)

---

## PASO 3 — Performance

**React/Vue:**
- Identifica qué se re-renderiza y por qué — ¿es necesario?
- `useMemo`/`useCallback` usados donde no hace falta (tienen costo)
- `useMemo`/`useCallback` faltantes donde sí importa
- Imágenes sin lazy loading, sin dimensiones definidas (layout shift)
- Bundles grandes: imports de `lodash` completo en vez de `lodash/get`
- `useEffect` que hace fetch — considerar React Query/SWR/TanStack Query

**Next.js:**
- Componentes marcados `"use client"` que no necesitan serlo
- Datos fetched en client que podrían venir del servidor
- Imágenes sin `next/image`
- `getServerSideProps` cuando `getStaticProps` + revalidate sería suficiente

**GraphQL:**
- Queries N+1 sin DataLoader
- Campos solicitados en la query que no se usan en el componente
- Subscriptions cuando polling sería más simple y suficiente

**General:**
- Operaciones O(n²) en listas que crecen
- Llamadas a API en loops — batch cuando sea posible
- Cálculos pesados en el hilo principal que podrían ser Web Worker

---

## PASO 4 — Arquitectura y mantenibilidad

- ¿La función hace una sola cosa? Si tiene más de 30 líneas o más de 3 niveles de indentación, probablemente no.
- ¿Los nombres comunican la intención sin necesitar comentarios?
- ¿Hay lógica de negocio en un componente UI? Extraer a hook o service.
- ¿Hay duplicación que en 3 meses alguien va a olvidar mantener en sync?
- ¿Los errores fallan rápido y ruidosamente, o fallan silenciosamente?
- ¿Las dependencias apuntan hacia adentro? (UI → domain, domain ← infrastructure)

---

## FORMATO DE RESPUESTA

```
## Resumen
[2-3 líneas: calidad general, área más problemática, tono constructivo]

## 🔴 Crítico — arreglar antes de mergear
[Solo bugs reales o vulnerabilidades de seguridad. Máximo 3.]

Para cada uno:
**Problema:** [descripción concisa]
**Por qué importa:** [consecuencia real]
**Código actual:**
\`\`\`ts
// lo que está mal
\`\`\`
**Solución:**
\`\`\`ts
// cómo debería ser
\`\`\`

## 🟡 Importante — arreglar en este PR o crear ticket
[Performance, tipos incorrectos, code smells significativos]

## 🔵 Sugerencia — próxima iteración
[Mejoras de DX, refactors opcionales, alternativas a considerar]

## ✅ Lo que está bien
[Mencionar 2-3 cosas que están bien implementadas — el review es una conversación]

## Prioridad de acción
1. [Lo más urgente]
2. [Lo segundo]
3. [Lo tercero]
```

---
name: component
description: Genera componentes React, Next.js o Vue production-ready con TypeScript estricto, accesibilidad, estados de UI completos, tests y ejemplos de uso. Detecta el framework del proyecto automáticamente.
argument-hint: [nombre del componente] [descripción de qué hace]
---

Genera el componente: $ARGUMENTS

Primero lee el proyecto para entender:
- ¿React, Next.js o Vue? ¿Qué versión?
- ¿Qué librería de estilos usa? (Tailwind, CSS Modules, styled-components, UnoCSS)
- ¿Hay componentes similares ya creados? Seguir sus patrones.
- ¿Usa shadcn/ui, Radix, Headless UI o similar?

---

## REACT / NEXT.JS

### Estructura base
```tsx
// ✅ Named export siempre (salvo páginas Next.js)
// ✅ Props interface separada y nombrada
// ✅ JSDoc en la interfaz si las props no son obvias

interface ButtonProps {
  /** Variante visual del botón */
  variant?: 'primary' | 'secondary' | 'ghost' | 'destructive'
  size?: 'sm' | 'md' | 'lg'
  isLoading?: boolean
  disabled?: boolean
  onClick?: (event: React.MouseEvent<HTMLButtonElement>) => void
  children: React.ReactNode
  /** Para forwarding al elemento DOM */
  className?: string
}

export function Button({
  variant = 'primary',
  size = 'md',
  isLoading = false,
  disabled = false,
  onClick,
  children,
  className,
}: ButtonProps) {
  // ...
}
```

### Reglas estrictas

**Estado:**
- Si el estado puede derivarse de props, NO usar `useState` — calcularlo
- Si la lógica de estado es compleja (>3 useState relacionados), extraer a `use<ComponentName>`
- Preferir `useReducer` cuando el siguiente estado depende del anterior

**Efectos:**
- `useEffect` solo para sincronizar con sistemas externos (DOM, APIs externas, suscripciones)
- Nunca `useEffect` para transformar datos — hacerlo durante el render o con `useMemo`
- Siempre incluir cleanup si el efecto crea suscripciones o timers

**Server vs Client en Next.js:**
- Default: Server Component — no poner `"use client"` hasta necesitarlo
- Necesita `"use client"` cuando usa: useState, useEffect, event handlers, browser APIs
- Si solo una parte pequeña necesita client, extraer esa parte como subcomponente client

**Refs:**
- `useRef` para valores que no deben causar re-render (timers, instancias, valores previos)
- `forwardRef` cuando el componente necesita exponer su DOM al padre

**Performance:**
- `memo()` solo cuando el padre re-renderiza frecuentemente y el hijo es caro
- `useCallback` solo para funciones pasadas a componentes memoizados o como dependencias de effects
- `useMemo` solo para cálculos realmente costosos (no para objetos simples)

### Accesibilidad — obligatorio
- Usar elementos semánticos (`button`, `nav`, `main`, `article`) antes que divs
- `aria-label` en botones que solo tienen iconos
- `aria-expanded`, `aria-controls` en toggles y dropdowns
- Navegación por teclado: todos los elementos interactivos accesibles con Tab y Enter/Space
- Contraste de colores suficiente (WCAG AA mínimo)
- `role` solo cuando el elemento semántico correcto no existe

### Estados de UI — todos los componentes deben manejar:
- **Loading** — skeleton, spinner, o estado deshabilitado según el contexto
- **Error** — mensaje claro, opción de reintentar si aplica
- **Empty** — estado vacío con mensaje y acción sugerida
- **Success** — feedback visual claro

---

## VUE 3 (Composition API)

```vue
<script setup lang="ts">
// Props siempre tipadas con defineProps<{}>()
// Emits siempre tipados con defineEmits<{}>()
// Lógica compleja en composables separados

interface Props {
  modelValue: string
  placeholder?: string
  disabled?: boolean
}

const props = defineProps<Props>()
const emit = defineEmits<{
  'update:modelValue': [value: string]
  'blur': [event: FocusEvent]
}>()

// Si hay >30 líneas de lógica, extraer a useXxx()
</script>

<template>
  <!-- Un solo elemento raíz o Fragment explícito -->
</template>
```

**Reglas Vue:**
- `computed` para valores derivados, nunca `watch` para calcular
- `watch` solo para side effects (llamadas a API, DOM manipulation)
- `watchEffect` cuando las dependencias son obvias del código
- Composables (`useXxx`) para lógica reutilizable — un archivo por composable
- `v-model` con `defineModel()` en Vue 3.4+

---

## ENTREGA SIEMPRE:

1. **El componente completo** con todos los tipos y estados de UI
2. **Hook/composable** si tiene lógica de estado no trivial
3. **Test con Vitest + Testing Library:**
   - Render sin props opcionales (defaults funcionan)
   - Render con cada estado importante
   - Interacción del usuario (click, input)
   - Accesibilidad básica (getByRole en vez de getByTestId cuando sea posible)
4. **Ejemplo de uso** con los casos más comunes
5. **Notas de decisión** — si hiciste algo no obvio, explicar por qué

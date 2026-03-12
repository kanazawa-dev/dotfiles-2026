---
name: design
description: Revisa y mejora UI/UX de componentes y páginas. Evalúa jerarquía visual, espaciado, tipografía, accesibilidad, estados de UI, consistencia con el design system y mobile. Produce código Tailwind/CSS mejorado con justificación de cada decisión.
argument-hint: [componente o página a revisar/diseñar]
---

Revisa y mejora el diseño de: $ARGUMENTS

Primero lee el componente/página existente y el design system del proyecto (tokens, colores, tipografía). Si usa shadcn/ui o Radix, entender qué componentes base están disponibles antes de crear nuevos.

---

## JERARQUÍA VISUAL

La jerarquía guía al usuario hacia la acción más importante. Evalúa:

**Tamaño y peso tipográfico:**
```tsx
// ❌ Todo con el mismo peso — sin jerarquía
<h1 className="text-lg">Título de página</h1>
<p className="text-lg">Subtítulo</p>
<p className="text-lg">Descripción</p>

// ✅ Escala tipográfica clara
<h1 className="text-3xl font-bold tracking-tight">Título de página</h1>
<p className="text-lg text-muted-foreground">Subtítulo descriptivo</p>
<p className="text-sm text-muted-foreground">Descripción de apoyo</p>
```

**Contraste y color:**
- La acción primaria debe ser la más llamativa
- Máximo 2 acciones primarias por vista
- Destructive actions: rojo, pero no el botón más grande
- Estados disabled: 50% opacity, no el mismo color que enabled

**Escala de espaciado — usar siempre múltiplos del base (4px):**
```
Dentro de un componente:   gap-2 (8px),  gap-3 (12px), gap-4 (16px)
Entre secciones:           gap-6 (24px), gap-8 (32px)
Entre secciones grandes:   gap-12 (48px), gap-16 (64px)
Padding de contenedores:   px-4 sm:px-6 lg:px-8
```

---

## TIPOGRAFÍA

```tsx
// Escala recomendada para aplicaciones
// Heading principal: text-3xl font-bold tracking-tight (30px)
// Heading sección:   text-2xl font-semibold (24px)
// Subheading:        text-xl font-medium (20px)
// Body:              text-base (16px) — default, no declarar explícitamente
// Small/caption:     text-sm text-muted-foreground (14px)
// Tiny:              text-xs (12px) — solo metadata y labels de form

// Line height — siempre con texto largo
<p className="text-base leading-7">  {/* leading-7 para párrafos */}

// Medida máxima de línea (legibilidad óptima: 65-75 chars)
<article className="prose max-w-prose">
// o
<p className="max-w-[65ch]">
```

---

## ESPACIADO Y LAYOUT

```tsx
// Padding consistente en contenedores
<main className="container mx-auto px-4 sm:px-6 lg:px-8 py-8">

// Cards con padding interno consistente
<div className="rounded-lg border bg-card p-6">  {/* p-6 = 24px */}

// Stack vertical — usar gap en lugar de margin-bottom
<div className="flex flex-col gap-4">
  <Component />
  <Component />
</div>

// ❌ Margin-bottom en el hijo — difícil de mantener y predecir
<div className="mb-4">...</div>
```

---

## ESTADOS DE UI — TODOS OBLIGATORIOS

```tsx
// Todo elemento interactivo necesita todos estos estados:
<button
  className={cn(
    // Base
    "rounded-md px-4 py-2 text-sm font-medium transition-colors",
    // Idle
    "bg-primary text-primary-foreground",
    // Hover — feedback visual inmediato
    "hover:bg-primary/90",
    // Focus — accesibilidad, nunca quitar outline sin alternativa
    "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
    // Active — feedback de click
    "active:scale-[0.98]",
    // Disabled
    "disabled:opacity-50 disabled:cursor-not-allowed",
    // Loading
    isLoading && "cursor-wait",
  )}
/>
```

**Estados de datos en cada vista:**
```tsx
// Siempre diseñar los 4 estados:

// 1. Loading — skeleton preferible sobre spinner para contenido
<div className="animate-pulse">
  <div className="h-4 bg-muted rounded w-3/4 mb-2" />
  <div className="h-4 bg-muted rounded w-1/2" />
</div>

// 2. Error — con opción de reintentar
<div className="rounded-lg border border-destructive/50 bg-destructive/10 p-4">
  <p className="text-sm text-destructive">Error cargando datos</p>
  <Button variant="outline" size="sm" onClick={retry}>Reintentar</Button>
</div>

// 3. Empty — con acción sugerida, no solo "No hay datos"
<div className="flex flex-col items-center gap-4 py-12 text-center">
  <Icon className="h-12 w-12 text-muted-foreground" />
  <div>
    <p className="font-medium">No hay usuarios aún</p>
    <p className="text-sm text-muted-foreground">Crea el primero para comenzar</p>
  </div>
  <Button>Crear usuario</Button>
</div>

// 4. Success — datos reales con el diseño final
```

---

## RESPONSIVE

```tsx
// Mobile-first siempre — luego expandir
<div className="
  grid
  grid-cols-1        // mobile: 1 columna
  sm:grid-cols-2     // tablet: 2 columnas
  lg:grid-cols-3     // desktop: 3 columnas
  gap-4
  sm:gap-6
">

// Tipografía responsive
<h1 className="text-2xl sm:text-3xl lg:text-4xl font-bold">

// Padding responsive
<section className="px-4 sm:px-6 lg:px-8 py-8 sm:py-12 lg:py-16">

// Ocultar en mobile cuando necesario (pero pensar si realmente debe ocultarse)
<aside className="hidden lg:block">
```

---

## ACCESIBILIDAD

```tsx
// Focus visible — nunca quitar sin alternativa
// outline-none solo con focus-visible:ring como reemplazo

// Contraste mínimo WCAG AA:
// Texto normal: 4.5:1
// Texto grande (>18px o >14px bold): 3:1
// Componentes UI: 3:1

// Labels en formularios — SIEMPRE asociados
<div className="space-y-2">
  <Label htmlFor="email">Email</Label>  {/* htmlFor = id del input */}
  <Input id="email" type="email" />
</div>

// Botones con solo iconos
<Button aria-label="Cerrar modal" size="icon">
  <X className="h-4 w-4" aria-hidden />
</Button>

// Imágenes
<Image alt="Descripción real de la imagen" />  // no "image" ni ""
<Image alt="" aria-hidden />  // si es decorativa

// Landmarks semánticos
<header>, <main>, <nav>, <aside>, <footer>
// aria-label en múltiples <nav>: <nav aria-label="Principal">
```

---

## ANIMACIONES

```tsx
// Sutiles — 150-300ms para micro-interacciones
// Más largas — 400-600ms para transiciones de página

// Respetar preferencias del sistema
<div className="transition-transform duration-200 motion-reduce:transition-none">

// Preferir transform y opacity (GPU) sobre top/left/width (layout thrashing)
// ✅
className="transition-transform hover:scale-105"
// ❌
className="transition-all hover:top-1"  // causa layout recalc
```

---

## ENTREGA

1. **Código mejorado** con Tailwind — no solo la lista de problemas
2. **Justificación** de cada decisión visual importante
3. **Todos los estados de UI** implementados (loading, error, empty, success)
4. **Responsive** mobile-first
5. **Accesibilidad** — al menos focus, labels y contraste
6. **Qué no cambiar** — si algo ya está bien, decirlo explícitamente

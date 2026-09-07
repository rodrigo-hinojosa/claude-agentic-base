# Ejemplo — Tarea con desvíos sembrados

Caso de prueba del modo auditar. Contiene desvíos **conocidos de antemano**; auditarlo debe detectarlos todos, cada uno con ubicación y corrección. Datos sintéticos; la clave `ABC-99` es inventada.

> **Es un fixture, no una transcripción**: no tiene cifras de un día que puedan caducar. Lo que caduca es la **lista de desvíos sembrados**, si cambia el estándar contra el que se los sembró.
>
> **Contrastado contra `SKILL.md` §2 y §5 el 06-09-2026.**

## Desvíos sembrados (referencia del corrector, no parte del ticket)

1. **Título con prefijo de clave** — arranca con "ABC-99:" (la plantilla exige título sin prefijo).
2. **Descripción que replica el título** — la sección Objetivo repite el título en vez de aportar propósito.
3. **Falta la sección Contexto** — el orden fijo de cinco secciones está incompleto.
4. **Secciones fuera de orden** — Entregable aparece antes que Alcance.
5. **"Próximos pasos" no es checklist** — va como lista con viñetas, no con casillas.
6. **Sin labels** — el issue queda invisible a toda agrupación del tablero.
7. **Criterios de aceptación y estimación indebidos** — contrarios a la omisión declarada de la plantilla de gestión.

---

**Título**: ABC-99: Migrar usuarios

**Tipo**: Tarea

**Labels**: (ninguna)

## Objetivo

Migrar usuarios.

## Alcance

Mover los usuarios del sistema legado al nuevo tenant.

## Entregable

Usuarios migrados.

## Criterios de aceptación

- El 100 % de los usuarios quedan migrados.
- La migración no supera las 2 horas.

**Estimación**: 5 puntos.

## Próximos pasos

- Exportar los usuarios del sistema legado.
- Cargar los usuarios en el nuevo tenant.

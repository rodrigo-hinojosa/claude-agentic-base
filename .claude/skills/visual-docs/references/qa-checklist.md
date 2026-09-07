# Checklist de calidad

## Formato

- [ ] La paleta usa únicamente los tokens monocromáticos definidos.
- [ ] Tipografía, spacing, bordes y radios son consistentes entre páginas.
- [ ] La navegación numerada y el footer forman una ruta completa.
- [ ] Cada página tiene un solo `h1` y cada sección una pregunta clara.
- [ ] No aparecen estilos de producto final ni colores de marca no solicitados.

## Diagramas

- [ ] Cada diagrama usa el tipo apropiado para la pregunta.
- [ ] Las formas y líneas respetan su semántica estándar.
- [ ] Decisiones y ramas están etiquetadas.
- [ ] No hay texto cortado, conectores sobre etiquetas ni cajas innecesarias.
- [ ] Cada SVG tiene `role="img"`, `aria-labelledby`, `<title>` y `<desc>`.
- [ ] Los IDs y marcadores son únicos dentro de cada página.

## Wireframes

- [ ] Todos están rotulados `LOW-FI` y son claramente conceptuales.
- [ ] El flujo comienza en el punto de entrada real.
- [ ] Camino principal y alternativos relevantes se entienden sin explicación oral.
- [ ] Cada caso técnico incluye una `CAPA SISTÉMICA` coherente.
- [ ] Los datos de ejemplo están enmascarados o son ficticios.

## Técnica y visual

- [ ] `node "<skill-dir>/scripts/validate_docs.mjs" <directorio>` finaliza sin errores.
- [ ] La documentación funciona directamente desde `file://`.
- [ ] Todos los enlaces internos y assets relativos existen.
- [ ] No hay dependencias externas necesarias para renderizar.
- [ ] La consola del navegador no muestra errores.
- [ ] Se revisaron viewport ancho y estrecho.
- [ ] Tablas, diagramas y wireflows conservan lectura mediante scroll cuando corresponde.

## Cobertura automatizada de la skill

Antes de publicar cambios en el paquete, ejecuta `node .claude/skills/visual-docs/tests/run-tests.mjs` desde la raíz del repositorio. El arnés debe comprobar:

- [ ] frontmatter, activación, exclusión de UI final y enlaces directos a las cinco referencias;
- [ ] paridad entre tokens JSON, variables CSS y los seis assets del starter;
- [ ] scaffold sobre destinos nuevos o vacíos y rechazo no destructivo de tres destinos no vacíos;
- [ ] operación offline y navegación relativa de fixtures generales y visuales;
- [ ] accesibilidad SVG, unicidad de IDs, etiquetas `LOW-FI`, datos enmascarados y `CAPA SISTÉMICA`;
- [ ] detección de enlace roto, asset ausente, ID duplicado, dependencia externa y cantidad inválida de `h1`;
- [ ] códigos de salida y separación entre errores bloqueantes y advertencias.

La automatización no sustituye la revisión visual: recortes, solapamientos, legibilidad y consola se confirman en un navegador real.

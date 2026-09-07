# Lenguaje visual

## Paleta

La documentación es deliberadamente monocromática. Esto comunica que se trata de un artefacto de análisis y revisión, no de una interfaz final.

| Token | Valor | Uso |
|---|---:|---|
| `--bg` | `#ececea` | Lienzo general y separación entre páginas/secciones |
| `--paper` | `#ffffff` | Superficies principales, dispositivos y diagramas |
| `--ink` | `#141414` | Texto principal, acciones primarias y énfasis |
| `--muted` | `#666662` | Texto auxiliar, metadata y explicaciones |
| `--line` | `#b8b8b3` | Bordes secundarios y divisores |
| `--line-strong` | `#242424` | Bordes estructurales y estados destacados |
| `--soft` | `#e4e4e1` | Controles simulados y superficies de apoyo |
| `--soft-2` | `#f7f7f5` | Tarjetas y notas suaves |
| fondo de código | `#202020` | Contratos, eventos y snapshots técnicos |

No incorpores colores de marca ni semáforos. Representa estados con texto explícito, fondo claro/oscuro, borde normal/grueso y línea continua/punteada.

## Tipografía

- Sans: `Inter, ui-sans-serif, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif`.
- Monospace: `"SFMono-Regular", Consolas, monospace`.
- `h1`: tamaño fluido entre 42 y 76 px, peso alto y tracking cerrado.
- `h2`: entre 28 y 42 px.
- `h3`: 19 px en documentación y 22 px dentro de wireframes.
- Lead: 20 px, ancho de línea controlado.
- Metadata: 8–11 px, monospace, mayúsculas y tracking abierto.
- Cuerpo: 12–14 px con interlineado cercano a 1.5.

Usa monospace para IDs, estados, contratos, nombres de mensajes, claves y etiquetas de diagrama; no para párrafos explicativos.

## Ritmo y geometría

- Ancho máximo del contenido: 1580 px.
- Margen lateral habitual: 20 px; 12 px en viewport estrecho.
- Separación entre grandes secciones: 20 px.
- Padding de sección: 34–38 px; 22 px en móvil.
- Padding del hero: 44–48 px.
- Gaps frecuentes: 7, 10, 14, 18, 20, 24, 30 y 72 px.
- Radio de tarjeta: 8 px; radio de controles: 3–6 px.
- Bordes: 1 px para estructura normal y 2 px para énfasis.

La geometría debe sentirse editorial y técnica: grandes superficies rectangulares, jerarquía clara y ornamentación mínima.

## Superficies y estados

- `hero-main`, `hero-side` y `section`: papel blanco con borde fuerte.
- `card`: fondo suave, borde secundario y radio de 8 px.
- `card emphasis`: blanco y borde fuerte de 2 px.
- `tag`: píldora pequeña de metadata; negra solo para el contexto principal.
- `decision`: tira con estado a la izquierda y contenido a la derecha.
- `proposed` u `open`: borde punteado y texto explícito.
- `callout`: borde fuerte; punteado cuando comunica una definición abierta.
- `contract` y `data-snapshot`: bloque oscuro únicamente para información técnica literal.

## Accesibilidad y responsive

- Mantén contraste suficiente dentro de la paleta.
- No dependas del color para comunicar información.
- Permite scroll horizontal en navegación, tablas, diagramas y wireflows.
- Cambia grids a una columna cuando el viewport no permite lectura cómoda.
- Conserva el tamaño del texto del diagrama y expande el lienzo antes de reducirlo.
- Cada SVG informativo debe tener `role="img"`, `aria-labelledby`, `<title>` y `<desc>`.

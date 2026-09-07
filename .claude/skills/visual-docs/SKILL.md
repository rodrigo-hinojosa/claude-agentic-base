---
name: visual-docs
description: Produce sitios HTML de revisión técnica navegables sin servidor, con sistema visual monocromático, diagramas de arquitectura elegidos por la pregunta que responden y wireframes low-fi con capa sistémica. Úsala cuando el entregable es un sitio visual que alguien recorre para revisar una solución. Para prosa normada en Confluence o en archivos del repo, la autoridad es confluence-docs; para un ticket, jira-management. No usar para implementar una UI de producción ni una interfaz final con marca.
argument-hint: tema o fuentes + directorio de destino
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

# visual-docs

Solicitud:

$ARGUMENTS

Aplica el sistema documental incluido al tema y a las fuentes del usuario. Esta skill gobierna la presentación y la gramática visual; no debe importar hechos, entidades, fases, proveedores ni decisiones desde los ejemplos incluidos.

## Seleccionar la guía necesaria

- Para cada artefacto nuevo o rediseño amplio, lee [visual-language.md](references/visual-language.md) y [page-composition.md](references/page-composition.md).
- Cuando el artefacto contenga diagramas de arquitectura, flujo, secuencia, estados o datos, lee [diagram-system.md](references/diagram-system.md).
- Cuando incluya ejemplos de pantallas o recorridos de usuario, lee [wireframe-system.md](references/wireframe-system.md).
- Antes de entregar, aplica [qa-checklist.md](references/qa-checklist.md).

Lee solo las referencias que correspondan al trabajo actual, salvo `qa-checklist.md`, que siempre se usa al finalizar.

## Establecer el contenido antes de dibujar

Inspecciona primero el material fuente y el directorio de destino. Determina:

- la audiencia y el objetivo de revisión;
- las preguntas que debe responder cada página;
- el orden de lectura;
- los hechos confirmados, las propuestas y las decisiones abiertas;
- qué relaciones necesitan un diagrama y cuáles son más claras como prosa o tabla;
- qué estados de usuario realmente se benefician de un wireframe.

No inventes contenido de la solución para completar el formato. Usa datos de ejemplo breves y neutros solo cuando una visualización los necesite, y márcalos como conceptuales.

## Usar el starter como kit visual

Resuelve `<skill-dir>` como el directorio que contiene este `SKILL.md`.

Para un sitio nuevo, ejecuta:

```bash
node "<skill-dir>/scripts/scaffold_docs.mjs" <directorio-destino>
```

El helper copia `assets/starter/` únicamente a un directorio nuevo o vacío y se niega a sobrescribir trabajo existente. Si el destino ya contiene archivos, inspecciónalos y modifica solo lo solicitado.

El starter contiene:

- `index.html`: colores, tipografía, superficies y anatomía de página;
- `diagrams.html`: ejemplos canónicos de los tipos de diagrama soportados;
- `wireframes.html`: ejemplos canónicos de flujo de pantallas y capa sistémica;
- `page-patterns.html`: estructuras reutilizables de contenido técnico;
- `documentation.css`: hoja de estilos offline completa;
- `design-tokens.json`: tokens visuales legibles por máquina.

Reutiliza las clases CSS y los tokens antes de crear otros. Sustituye el contenido de muestra neutral sin alterar las reglas visuales. Mantén enlaces relativos y funcionamiento completo desde `file://`. No añadas fuentes, scripts, bibliotecas de iconos ni CDN externos.

## Preservar la firma visual

- Usa una paleta monocromática: lienzo gris cálido, papel blanco, tinta casi negra, grises neutros y sin codificación semántica por color.
- Usa jerarquía tipográfica fuerte, metadata monospace compacta y espacio en blanco generoso.
- Compón las páginas con navegación sticky numerada, hero de dos columnas, secciones de papel con borde y una ruta lineal en el footer.
- Usa formas y conectores semánticos estándar en los diagramas, no cajas indiferenciadas.
- Mantén los wireframes claramente low-fi, monocromáticos y rotulados `LOW-FI`.
- Acompaña cada wireframe con una sección `CAPA SISTÉMICA` cuando forme parte de un recorrido técnico.
- Distingue estados mediante texto, grosor de borde, relleno y patrones punteados; nunca solo mediante color.
- Habilita scroll horizontal en diagramas y wireflows anchos antes de reducir las etiquetas hasta volverlas ilegibles.

## Validar

Ejecuta:

```bash
node "<skill-dir>/scripts/validate_docs.mjs" <directorio-documentacion>
```

Corrige los errores y vuelve a ejecutar el validador hasta obtener cero errores. Después abre `index.html` en un navegador real, recorre la navegación visible, revisa viewports ancho y estrecho, y corrige recortes, solapamientos, conectores rotos, assets ausentes y errores de consola.

No declares terminada la documentación sin realizar tanto la validación automática como la revisión visual, salvo que el entorno impida una de ellas; en ese caso, indica exactamente qué revisión quedó pendiente.

## Entregar

Proporciona un enlace o ruta directa a `index.html`, un mapa breve de páginas, los supuestos de formato y cualquier validación pendiente. Menciona las decisiones de contenido no resueltas solo cuando afecten la comprensión de la documentación.

## Reglas de operación de la propia skill

- **Escribe en el directorio de destino que le indiquen, y en ninguno más.** El scaffold se niega a sobrescribir un destino no vacío; ante uno con contenido, inspecciona y modifica solo lo solicitado.
- **No importa hechos desde el starter.** Los ejemplos incluidos son referencias visuales neutrales, no fuente de entidades, proveedores ni decisiones. Un entregable que reproduce un nombre del starter como si fuera del usuario es no conforme.
- **No publica.** No toca Confluence, ni Jira, ni ningún sistema compartido: entrega archivos locales y una ruta.
- **Nunca emite secretos ni datos personales.** Los datos ilustrativos son ficticios o enmascarados, y se marcan como conceptuales.
- **Declara lo que no verificó.** Si el entorno impide la validación automática o la revisión en navegador, dice cuál faltó en vez de afirmar que se hizo.

### Qué sostiene cada restricción

| Restricción | Garantía |
| --- | --- |
| No tocar Confluence ni Jira | **Permisos** — ninguna herramienta de Atlassian está declarada en `allowed-tools` |
| No consultar la red al generar | **Permisos** — no hay `WebFetch` ni `WebSearch` declarados |
| No sobrescribir un destino con contenido | **Proceso** — lo impone `scaffold_docs.mjs`, y una escritura directa con `Write` lo evadiría |
| Escribir solo en el destino indicado | **Proceso** — `Write` y `Edit` no están acotados por ruta |
| Ejecutar solo los dos scripts de la skill | **Proceso** — `Bash` está declarado completo, no restringido a esos dos comandos |
| No importar hechos desde el starter | **Proceso** — nada lo impide salvo esta instrucción |

> **`Bash` completo es la concesión más amplia de este allowlist, y se declara como tal.** La skill lo necesita porque su scaffold y su validador son scripts de Node, y el allowlist no admite acotar por comando. Lo que impide que se use para otra cosa es esta instrucción, no el permiso: es garantía de proceso donde las otras skills de dominio tienen una de permisos. Quien audite esta skill debe mirar ahí primero.

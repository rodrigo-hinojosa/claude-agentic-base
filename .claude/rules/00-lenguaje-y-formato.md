# Lenguaje y formato

<!-- Sin frontmatter `paths`: aplica a toda sesión sobre este repositorio. -->

## Idioma

- Español con acento neutro (Chile). Tono profesional, directo y cercano.
- Código, identificadores, comandos, rutas y mensajes de log en inglés cuando sea la convención del proyecto.
- Términos técnicos: usa el término establecido (no traducir forzado). Ej: "deploy", "endpoint", "commit", "pull request".

## Formato general

- Markdown estructurado: encabezados jerárquicos, listas, tablas y bloques de código con lenguaje declarado.
- Bloques listos para copiar y pegar cuando el contenido es reutilizable (comandos, plantillas, configuraciones).
- Tablas para comparaciones, matrices de decisión y datos estructurados.

## Estilo visual

- **Sin emojis** en ningún contexto: respuestas, código, commits, documentación, tickets.
- No los uses en encabezados de ningún nivel (H1–H6) ni como parte de un título.
- No los antepongas a bullets, listas ni ítems. Nada de `✅`, `🔬`, `🔑` o `📌` abriendo una línea.
- Para destacar estados o categorías usa texto (`Pendiente`, `Validado`, `En curso`) o formato Markdown: negritas, código inline, tablas.
- Un ícono solo es admisible si lo pido de forma explícita, o si forma parte literal de un contenido que se está citando.

### Fechas

- **En prosa dirigida a personas**: `DD-MM-YYYY`, y `DD-MM-YYYY hh:mm:ss` cuando la hora importa. Hora local de Santiago de Chile.
- **En identificadores, nombres de archivo, nombres de directorio y campos de metadato**: ISO 8601 (`YYYY-MM-DD`, o `YYYYMMDD` si el identificador no admite separadores). Ahí la ordenación lexicográfica coincide con la cronológica, y de eso dependen numeraciones, trazas y ordenamientos.
- Criterio para resolver el caso dudoso: si algo se ordena, se busca o se referencia por ese campo, es identificador.

## Estilo de redacción

- Resumen ejecutivo primero, detalle después. La conclusión no debe quedar enterrada.
- Conciso: una idea por frase, sin relleno ni preámbulos vacíos ("Excelente pregunta", "Como sabes").
- Profundidad cuando el tema lo exige; brevedad cuando no.
- Evita la adulación y los cierres genéricos. Termina cuando la respuesta está completa.

## Estructura para temas complejos

Cuando el tema tenga aristas, organiza así:

1. **Contexto** — situación y supuestos.
2. **Problema** — qué hay que resolver, con precisión.
3. **Análisis** — factores, restricciones, trade-offs.
4. **Opciones** — alternativas con pros y contras.
5. **Recomendación** — qué harías y por qué.
6. **Próximos pasos** — acciones concretas, secuenciadas.

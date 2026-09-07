# Composición de páginas

## Estructura global

Cada sitio debe tener una ruta de lectura visible:

1. encabezado sticky con marca breve y navegación numerada;
2. hero de dos columnas;
3. secciones de papel blanco separadas por el lienzo gris;
4. footer con página anterior y siguiente;
5. enlaces relativos para funcionar sin servidor.

El número de páginas depende del contenido. No impongas cinco páginas por defecto. Separa una página cuando responde una pregunta distinta o cuando un diagrama/wireflow necesita espacio propio.

## Hero

La columna principal contiene:

- eyebrow con número, tipo de artefacto y alcance;
- título que expresa un resultado o pregunta;
- lead de una o dos frases;
- tags de alcance, audiencia o estado.

La columna lateral contiene reglas de lectura, invariantes, audiencia o el resumen de alcance. No la conviertas en una segunda introducción extensa.

## Encabezado de sección

Usa dos columnas: título a la izquierda y explicación breve a la derecha. Debajo puede aparecer uno de estos patrones:

- cards para conceptos paralelos;
- tabla para mapeos exactos;
- decision ledger para confirmaciones/propuestas/dudas;
- diagram shell para una relación visual;
- contract para payload o API;
- wireflow para estados de pantalla;
- checklist para criterios de revisión.

## Narrativa

Ordena de lo general a lo específico:

- contexto y problema;
- mapa o arquitectura;
- proceso y decisiones;
- interacción temporal;
- datos o contratos;
- experiencia y estados alternativos;
- decisiones abiertas.

Usa una persona o escenario coherente solo cuando ayuda a seguir un proceso. En documentación puramente sistémica, usa un escenario operacional neutral.

## Densidad

- Una sección responde una pregunta principal.
- Un diagrama grande por sección suele ser suficiente.
- Los párrafos introducen; las formas muestran relaciones; las tablas comparan exactitudes.
- Evita repetir en tarjetas todo el texto que ya está dentro del diagrama.
- Deja espacio visual entre la evidencia, la interpretación y la decisión.

## Estados editoriales

Usa tres estados consistentes cuando el documento contiene decisiones:

- **Confirmado:** borde continuo y etiqueta sólida o normal.
- **Propuesto:** borde punteado y palabra “Propuesto”.
- **Abierto:** borde punteado, pregunta explícita e impacto.

No uses comparaciones con versiones anteriores dentro de la narrativa principal salvo que el usuario solicite un change log.

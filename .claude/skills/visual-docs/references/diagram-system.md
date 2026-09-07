# Sistema de diagramas

## Selección

Elige el tipo por la pregunta que debe responder:

| Pregunta | Diagrama |
|---|---|
| ¿Qué componentes existen y dónde están sus límites? | Arquitectura / containers |
| ¿Qué decisiones cambian el resultado? | Flowchart |
| ¿Quién llama a quién y en qué orden? | Secuencia |
| ¿Qué estados puede tener algo? | Máquina de estados |
| ¿Qué entidades persisten y cómo se relacionan? | Entidad-relación |
| ¿Cómo se despliega una capacidad en el tiempo? | Timeline o roadmap |

No uses un diagrama cuando una lista corta o una tabla comunica mejor la relación.

## Formas canónicas

- Actor/canal: rectángulo pequeño, etiqueta centrada.
- Proceso/servicio: rectángulo blanco con borde fuerte y radio de 4–5 px.
- Sistema externo: rectángulo con borde punteado o dentro de un trust boundary diferenciado.
- Almacén/dato: rectángulo de clase `data`; añade el tipo en texto, no con color.
- Inicio/fin: elipse.
- Decisión: rombo con una pregunta y salidas etiquetadas.
- Nota/alternativa: rectángulo claro de borde punteado.
- Trust zone/bounded context: gran contenedor gris claro de borde punteado.
- Entidad ERD: rectángulo con cabecera gris, nombre monospace y filas alineadas.

## Conectores

- `message`: línea continua oscura con flecha; request, comando o camino principal.
- `return`: línea punteada gris con flecha; respuesta, callback o camino secundario.
- `lifeline`: línea vertical punteada en secuencias.
- Línea sin flecha: asociación estática en ERD.
- Escribe el verbo o mensaje cerca de la línea sin atravesarla.

Define un solo bloque `<defs>` por página con `arrow` y `arrow-muted`. Todos los IDs SVG deben ser únicos dentro del HTML.

## Arquitectura

- Agrupa por límites reales: dispositivo, contexto, red, ownership o tercero.
- Ordena de canal a core y luego a dependencias externas.
- Explica la semántica de línea continua y punteada en una leyenda.
- No mezcles el mapa de despliegue con los pasos de una sesión.

## Flowchart

- Avanza en una dirección dominante, normalmente izquierda a derecha.
- Formula cada rombo como pregunta.
- Etiqueta todas las salidas, por ejemplo `sí`, `no`, `cancelar` o `timeout`.
- Toda rama termina o vuelve al camino principal de manera explícita.
- Muestra errores materiales; no dibujes cada excepción técnica posible.

## Secuencia

- Ordena actores de izquierda a derecha por responsabilidad.
- Nombra mensajes como operaciones observables.
- Usa bloques `ALT`, `OPT` o notas punteadas para condiciones.
- Expresa los saltos de tiempo cuando una acción ocurre en otra sesión.
- Diferencia llamada, respuesta y evento.

## Máquina de estados

- Usa nodos con nombre de estado, no acciones.
- Etiqueta la transición con el evento o condición.
- Marca estado inicial y estados terminales.
- Evita duplicar el flowchart de UI; muestra el ciclo de vida persistido.

## ERD

- Señala PK, FK y restricciones únicas relevantes.
- Muestra cardinalidad en ambos extremos.
- Separa conceptos cuando tienen ciclos de vida distintos.
- Distingue modelo lógico y decisión de almacenamiento físico.
- Usa nombres y datos neutros en la plantilla; el dominio real proviene de las fuentes del usuario.

## Legibilidad

- Mantén texto interno de 10–15 px según jerarquía.
- Aumenta el `viewBox` y habilita scroll antes de comprimir.
- Divide etiquetas largas en dos líneas.
- Evita conectores atravesando cajas o textos.
- Usa `<title>` y `<desc>` que expliquen el objetivo del diagrama, no cada nodo.

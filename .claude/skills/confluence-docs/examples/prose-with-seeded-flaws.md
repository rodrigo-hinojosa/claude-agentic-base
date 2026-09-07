<!--
Caso de prueba de las reglas de prosa (SKILL.md §3 y §4, rules.md → "Reglas de prosa").
Contiene un desvío sembrado A PROPOSITO por cada regla 26 a 32, y solo uno por regla,
para que una auditoria que no los encuentre todos este fallando.

Es un fixture, no una transcripcion: no tiene cifras de un dia que caduquen.
Lo que caduca es la lista de desvios sembrados, si cambia rules.md.

Desvios sembrados, con su regla:
- R26: parrafo "El cache se limpia los domingos." — una sola oracion, no es definicion ni veredicto.
- R27: la oracion del pipeline pasa de 30 palabras.
- R28: la negrita del segundo parrafo cubre una oracion entera, no un termino.
- R29: el parrafo del proceso nocturno lleva dos incisos con guion largo.
- R30: "gobierna" y "sostiene" donde corresponde "define" y "respalda".
- R31: el parrafo de cierre de la seccion Alcance repite el de Contexto con otras palabras.
- R32: la seccion Resultados cierra con una sentencia en vez de un dato.

Contrastado contra rules.md el 06-09-2026.
-->

# Notas sobre el módulo de reportes semanales

Documento de referencia para el modo `auditar` de `confluence-docs`. Ejemplo con datos sintéticos.

## Contexto

El módulo genera los reportes semanales que el equipo revisa cada lunes. Toma los datos de tres orígenes distintos, los combina y los deja listos para el tablero interno.

El cache se limpia los domingos.

## Alcance

El sistema **gobierna** la generación de reportes y **sostiene** la consistencia de los datos que expone al tablero.

El pipeline agrega los datos de los tres orígenes, aplica las reglas de negocio vigentes sobre cada campo, valida que ningún registro llegue incompleto al destino final, y recién entonces los expone por el endpoint que consume el tablero semanal.

El módulo toma los datos de tres orígenes y los deja listos para que el equipo los revise cada semana en su tablero interno.

## Proceso nocturno

El proceso —que corre a las tres de la madrugada— actualiza el caché completo —salvo en los días feriados— antes de que el equipo llegue a revisar el tablero.

**El sistema procesa el lote completo antes de exponerlo al endpoint** y por eso el tablero nunca muestra un estado a medio actualizar.

## Resultados

El reporte de la semana pasada tardó cuatro minutos en generarse, dos menos que el promedio del mes anterior. Y eso es lo que hace que el equipo confíe en el sistema.

<!--
Caso de prueba de las reglas de prosa (SKILL.md §3 y §4, rules.md → "Reglas de prosa").
Contiene un desvío sembrado A PROPOSITO por cada regla 26 a 32, y solo uno por regla,
para que una auditoria que no los encuentre todos este fallando.

Es un fixture, no una transcripcion: no tiene cifras de un dia que caduquen.
Lo que caduca es la lista de desvios sembrados, si cambia rules.md.

Desvios sembrados, con su regla:
- R26 (Comando): el segundo parrafo de Alcance tiene cinco oraciones; una idea no se
  fragmenta en parrafos de una oracion, y cinco oraciones ya no sostienen una sola idea.
- R27 (Comando): la primera oracion de ese mismo parrafo pasa de 30 palabras.
- R28 (Comando): la negrita del segundo parrafo de Proceso nocturno cubre una oracion
  entera, no un termino.
- R29 (Comando): el primer parrafo de Proceso nocturno lleva dos incisos con guion largo.
- R30 (Juicio): "gobierna" y "sostiene" donde corresponde "define" y "respalda".
- R31 (Juicio): el ultimo parrafo de Alcance repite el primero de Contexto con otras
  palabras.
- R32 (Juicio): la seccion Resultados cierra con una sentencia en vez de un dato.

Contrastado contra rules.md el 15-09-2026 (feature 003-concision-confluence-docs).
Salida del comando ampliado sobre este archivo, misma fecha:
  R26 parrafos de 5 o mas    : 1 de 7 = 14%
  R27 oraciones de 30+ pal   : 1 de 14 = 7%
  R28 negrita larga /1000 pal: 4.0
  R29 guiones inciso /1000   : 15.8
  R29 parrafos con 2+ incisos: 1
  R33 muletillas (lista)     : 0
-->

# Notas sobre el módulo de reportes semanales

## Contexto

El módulo genera los reportes semanales que el equipo revisa cada lunes. Toma los datos de tres orígenes distintos, los combina y los deja listos para el tablero interno. El cache se limpia los domingos.

## Alcance

El sistema **gobierna** la generación de reportes y **sostiene** la consistencia de los datos que expone al tablero.

El pipeline agrega los datos de los tres orígenes, aplica las reglas de negocio vigentes sobre cada campo, valida que ningún registro llegue incompleto al destino final, y recién entonces los expone por el endpoint que consume el tablero semanal. Un registro incompleto se reintenta hasta tres veces antes de descartarse. El resultado se expone en formato JSON, con un campo de checksum por lote. Los destinatarios del tablero reciben además una notificación por Slack cuando el lote queda listo. Un lote descartado por completo genera una alerta al equipo de datos.

El módulo toma los datos de tres orígenes y los deja listos para que el equipo los revise cada semana en su tablero interno.

## Proceso nocturno

El proceso —que corre a las tres de la madrugada— actualiza el caché completo —salvo en los días feriados— antes de que el equipo llegue a revisar el tablero.

**El sistema procesa el lote completo antes de exponerlo al endpoint** y por eso el tablero nunca muestra un estado a medio actualizar.

## Resultados

El reporte de la semana pasada tardó cuatro minutos en generarse, dos menos que el promedio del mes anterior. Y eso es lo que hace que el equipo confíe en el sistema.

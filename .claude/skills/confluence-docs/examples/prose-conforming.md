<!--
Caso de prueba de las reglas de prosa (SKILL.md §3 y §4, rules.md → "Reglas de prosa").
Mismo tema que prose-with-seeded-flaws.md, escrito conforme a las ocho reglas.
Una auditoria contra este archivo debe devolver cero hallazgos de prosa.

Es un fixture, no una transcripcion: no tiene cifras de un dia que caduquen.
Contrastado contra rules.md el 15-09-2026 (feature 003-concision-confluence-docs).
Salida del comando ampliado sobre este archivo, misma fecha:
  R26 parrafos de 5 o mas    : 0 de 5 = 0%
  R27 oraciones de 30+ pal   : 0 de 11 = 0%
  R28 negrita larga /1000 pal: 0.0
  R29 guiones inciso /1000   : 0.0
  R29 parrafos con 2+ incisos: 0
  R33 muletillas (lista)     : 0
-->

# Notas sobre el módulo de reportes semanales

## Contexto

El módulo genera los reportes semanales que el equipo revisa cada lunes. Toma los datos de tres orígenes distintos, los combina y los deja listos para el tablero interno. El caché se limpia cada domingo, antes de que empiece el ciclo siguiente.

## Alcance

El sistema define la generación de reportes y respalda la consistencia de los datos que expone al tablero. El pipeline agrega los datos de los tres orígenes y aplica las reglas de negocio vigentes sobre cada campo. Valida que ningún registro llegue incompleto al destino, y recién entonces lo expone por el endpoint que consume el tablero semanal.

## Proceso nocturno

El proceso corre a las tres de la madrugada y actualiza el caché completo antes de que el equipo llegue a revisar el tablero. Se salta los días feriados, según el calendario configurado en el entorno.

El `endpoint` procesa el lote completo antes de exponerlo. El tablero nunca muestra un estado a medio actualizar, porque la escritura es atómica.

## Resultados

El reporte de la semana pasada tardó cuatro minutos en generarse, dos menos que el promedio del mes anterior.

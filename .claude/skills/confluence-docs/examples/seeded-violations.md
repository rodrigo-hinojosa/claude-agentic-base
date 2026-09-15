<!--
Caso de prueba del modo AUDITAR (ver SKILL.md §4).
Contiene violaciones sembradas A PROPÓSITO para verificar que la skill las detecta.
El "secreto" de más abajo es un dato SINTÉTICO de prueba, no una credencial real.

Es un fixture, no una transcripcion: no tiene cifras de un dia que caduquen.
Lo que caduca es la lista de violaciones sembradas, si cambia rules.md.

Violaciones sembradas, con su regla y método. La ubicación es una cita del
cuerpo, no un número de línea: crece la cabecera, no el cuerpo.
- R16 (Comando/lectura): secretos sintéticos en el bloque de código, tras "Config de conexión usada en pruebas".
- R1 (lectura): "It handles data aggregation and rendering" mezclado en prosa, primer párrafo.
- R2 (lectura): emoji en el título.
- R33 (Comando): apertura "Este documento explica", primer párrafo.
- R10 (Juicio): "El proyecto avanza según lo planeado... la API es rápida y el sistema es robusto", segundo párrafo.
- R4 (Juicio): apertura de tres oraciones que mezcla propósito, muletilla y detalle técnico, primer párrafo.
- R5 (lectura): sin cierre con próximos pasos, pendientes o referencias, ni línea marcada.
- R9 (lectura): "según el business case original" sin cita de fuente, párrafo del roadmap.
- R27 (Comando): oración del roadmap de más de 30 palabras.
- R32 (Juicio): cierre "En resumen, el módulo cumple su objetivo...", sección Conclusión.

Auditar este archivo debe producir exactamente esos diez hallazgos: nueve de
severidad alta y uno media (R32). Contrastado contra rules.md el 15-09-2026
(feature 003-concision-confluence-docs).
Salida del comando ampliado sobre este archivo, misma fecha (el número de
línea del hallazgo R33 depende del tamaño de esta cabecera; se recomputa si
la cabecera vuelve a cambiar):
  R26 parrafos de 5 o mas    : 0 de 5 = 0%
  R27 oraciones de 30+ pal   : 1 de 8 = 12%
  R28 negrita larga /1000 pal: 0.0
  R29 guiones inciso /1000   : 0.0
  R29 parrafos con 2+ incisos: 0
  R33 muletillas (lista)     : 1
    (una coincidencia, en el primer párrafo del cuerpo: "Este documento explica")

EXENCION DECLARADA: este archivo contiene emojis A PROPOSITO, porque la regla 00
los prohibe y el fixture existe para que la auditoria detecte esa violacion.
Todo barrido de emojis sobre el repositorio debe eximirlo con este motivo escrito,
no silenciar el patron. Mismo criterio que la cita de emojis en rules/00.
-->

# Notas sobre el modulo de reportes 🎉

Este documento explica el modulo de reportes que construimos para el dashboard interno. It handles data aggregation and rendering para los reportes semanales del equipo. Usamos un pipeline que agrega, transforma y expone los datos vía un endpoint interno.

El proyecto avanza según lo planeado y el equipo está conforme con los resultados. La API es rápida y el sistema es robusto.

El roadmap del proyecto es: Fase 1 (10-06 al 12-06) organización, Fase 2 (11-06 al 17-06) definiciones internas, Fase 3 (18-06) workshop de cierre, Fase 4 (19-06 al 26-06) absorción, Go Live estimado para octubre 2026 según el business case original.

Config de conexión usada en pruebas:

```
API_KEY=sk-test-EXAMPLE1234567890abcdef
DB_PASSWORD=correcthorsebattery
```

## Conclusión

En resumen, el módulo cumple su objetivo y el equipo puede seguir usándolo sin cambios adicionales por ahora.

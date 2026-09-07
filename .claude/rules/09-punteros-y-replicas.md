# Punteros y réplicas

## Principio

Cuando un artefacto del repositorio necesita un dato que vive en otro, tiene dos formas de usarlo: **citarlo** o **copiarlo**. No son equivalentes, y la diferencia no se nota el día que se escribe — se nota meses después, cuando el origen cambió.

> **Un puntero sobrevive al cambio del origen. Una réplica queda falsa en silencio.**

Esta regla no es una preferencia de estilo: está sostenida por un resultado observado, no por un argumento. En el repositorio donde se destiló (caso ajeno citado, 2026-08), tras relevar una fuente se revisó qué artefactos la citaban: los tres que citaban sin reproducir sobrevivieron intactos; **todas** las réplicas —nueve puntos en cuatro archivos— caducaron. El único puntero problemático remitía a una entrada que nunca existió: también una falla, pero de la clase **ruidosa**, detectable buscando el identificador citado. Esa asimetría es todo el argumento: las réplicas fallan en silencio; los punteros fallan avisando.

## La distinción

| | **Puntero** | **Réplica** |
| --- | --- | --- |
| Qué hace | Cita el origen por identificador o enlace | Copia el contenido |
| Al cambiar el origen | Sigue siendo correcto | **Queda falso, sin señal** |
| Cómo se rompe | El identificador citado deja de existir: **es ruidoso** y se detecta | Nada lo delata |
| Cuándo es admisible | **Siempre** | Solo **declarada**, con su fecha y su fuente |

**Una réplica encubierta** —contenido copiado que se presenta como afirmación propia— **es no conforme.** Es el caso que esta regla existe para prevenir.

**Una réplica declarada** es admisible: dice que es copia, de dónde y de cuándo. Sigue siendo una copia que hay que mantener, pero al menos quien la lee sabe que puede haber caducado.

## Reglas

1. **Cuando un dato lo consumen varios lugares, vive en uno y los demás lo citan.** El que lo aloja es su autoridad.
2. **Reproducir contenido de otro cuerpo exige declararlo** como copia, con su fuente y su fecha. Sin esa declaración, es no conforme.
3. **Un puntero cita un identificador que existe.** Citar algo inexistente es una falla, aunque sea de las detectables.
4. **Toda cifra derivada de una tabla se acompaña de su origen**, de modo que se pueda recomputar. Un agregado que no se puede rehacer es una réplica del resultado de un cálculo.
5. **Una regla de `.claude/rules/` contiene su texto íntegro** y no remite fuera del repositorio para completarse.

## Cómo se verifica

Dos barridos sobre los archivos del repositorio:

```bash
# A. Quién referencia un catálogo — encuentra los punteros
grep -rn "<nombre-del-catalogo>" --include="*.md" .

# B. Quién replica una afirmación, aunque no cite su fuente
grep -rn "<frase-que-podria-estar-replicada>" --include="*.md" .
```

**El segundo es el que importa.** El primero encuentra a quienes citan, que son justamente los que no dan problema; el segundo busca a los que copiaron sin decirlo, que son los que caducan.

### El límite, y hay que nombrarlo

**Este procedimiento no prueba ausencia de réplicas.**

El segundo barrido exige conocer de antemano las frases a buscar. Un resultado limpio significa **"no encontré las que busqué"**, nunca **"no hay"**. Quien lo ejecute debe reportar **qué frases usó**, porque de eso depende cuánto vale el resultado.

**La ejecución es manual.** No hay integración continua ni gancho que la dispare. Se corre cuando alguien releva una fuente y quiere saber qué quedó caduco.

Un procedimiento que se cree exhaustivo es más peligroso que ninguno: produce la confianza de haber verificado sin haberlo hecho.

## Alcance

Esta regla rige la relación **entre artefactos del propio repositorio**. Si el proyecto además define una fuente única externa (por ejemplo, un espacio de documentación como SSOT), el mismo criterio —referenciar, no duplicar— rige la relación entre el repositorio y esa fuente; conviene fijarlo en la constitución del proyecto.

Caso particular declarado de esta plantilla: las reglas de `.claude/rules/` son réplica deliberada del set global del usuario (`~/.claude-personal/rules/`). Se declara aquí porque la copia del proyecto viaja con la plantilla al clonar y la global no; quien detecte divergencia entre ambas debe reconciliarlas de forma explícita, no asumir cuál rige.

# Continuidad y contexto

<!-- Cómo sostener el hilo entre sesiones y entre proyectos paralelos. -->

## Principio

Asume que trabajo **varios proyectos en paralelo**, profesionales y personales, y que retomo cada uno después de días. El contexto de una sesión no sobrevive solo: hay que reconstruirlo desde lo ya registrado, no desde cero ni desde suposiciones.

## Al retomar un tema

- **Recapitula brevemente el estado actual antes de avanzar**, apoyándote en el contexto ya registrado: memoria, archivos del proyecto, historial, documentación.
- La recapitulación es para orientar, no para demostrar que leíste. Dos o tres frases con dónde quedó la cosa y qué sigue.
- Si el estado registrado y el estado real difieren —el repo cambió, un ticket se movió—, dilo antes de continuar en vez de operar sobre el registro caduco.

## Uso de la memoria y del contexto ya disponible

- **No pidas datos que ya existen.** Antes de preguntar, revisa la memoria base, los archivos del proyecto y lo ya validado en la conversación.
- **Reutiliza un dato solo cuando sea relevante para la acción actual.** Traerlo porque está disponible es ruido.
- **No recites toda la memoria en cada respuesta.** Resume solo lo necesario para avanzar con precisión.
- Un dato recordado refleja lo que era cierto cuando se escribió. Si nombra un archivo, una función o un estado, verifícalo antes de apoyarte en él.

## Priorización de la información

Distingue siempre en qué categoría cae lo que estás manejando, porque cada una se mantiene distinto:

| Categoría | Qué es | Dónde vive | Cómo se actualiza |
| --- | --- | --- | --- |
| **Permanente** | Lo que define al proyecto o a mí: equipo, stack, convenciones, accesos | Memoria base, configuración, catálogos versionados | Rara vez; su caducidad debe ser detectable |
| **Operativa** | Lo que está en curso ahora: features abiertas, tickets activos, decisiones en vuelo | Artefactos del proyecto, tableros | Continuamente |
| **Histórica** | Lo que ya ocurrió: bitácoras, decisiones tomadas, specs integradas | Registro fechado | **No se reescribe.** Reescribir historia falsea la traza |
| **Pendiente** | Lo que hay que hacer y todavía no se hizo | Tickets, listas de tareas | Se cierra o se declara caduco |

Confundir categorías es el error caro: tratar información permanente como operativa la deja sin mantención, y tratar información histórica como viva lleva a corregirla en vez de superarla.

## Orden del sistema

- **No mezcles contenido de distintos proyectos** salvo que exista una relación explícita entre ellos.
- Favorece una estructura escalable, limpia y mantenible: convenciones claras, nombres consistentes, ubicación predecible.
- Cuando un dato lo consumen varios lugares, que viva en uno solo y los demás lo **citen**. Una réplica se desincroniza en silencio; un puntero no.

## Modo de trabajo ante información nueva

No solo respondas: **estructura**. Ante información nueva, transfórmala en algo utilizable —organiza, clasifica, resume— y **propón dónde debe quedar documentada**, en qué categoría de las de arriba y con qué nombre.

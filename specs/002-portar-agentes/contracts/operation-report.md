# Contrato — Reporte de operación

Forma de lo que `developer` devuelve al terminar. Es texto de retorno de la invocación, no un archivo versionado: la traza durable es el historial de git de cada repositorio, la entrada del índice y, cuando la escritura pertenece a una feature SDD, la evidencia de esa feature.

Procedencia: adaptación declarada del contrato de diseño del workspace de origen, portada el 07-09-2026 (feature `002-portar-agentes`).

## Regla que lo gobierna

**Todo dato de git se lee con un comando posterior a la operación.** La rama con `git symbolic-ref --short HEAD`, el hash con `git rev-parse HEAD`, los archivos del commit con `git diff-tree --no-commit-id --name-only -r <hash>`, la limpieza con `git status --porcelain`, la referencia remota con `git ls-remote origin refs/heads/<rama>`. Un valor tomado del acuse de la operación en vez de una lectura es no conforme.

## Secciones, en este orden

1. **Desarrollo**: clave y slug.
2. **Piezas**: una tabla por repositorio intentado, con las columnas de abajo.
3. **Pendientes**: lista de operaciones que el agente no ejecutó, con comando literal y motivo.
4. **Planes de escritura**: rutas de los planes producidos, si hubo; siempre sin marca.
5. **Límites**: los tres fijos y los que apliquen.
6. **Accesos**: fallas de acceso declaradas, si hubo.

## Vocabularios cerrados

| Columna | Valores admitidos |
| --- | --- |
| `rama base` | `<nombre> (remoto)` \| `<nombre> (invocación)` \| `sin rama base: <motivo>` |
| `rama` | `<nombre> (creada)` \| `<nombre> (existente, punta <hash>)` \| `no creada: <motivo>` |
| `commit` | `<hash>` \| `no producido: <motivo>` |
| `spec` | `<ruta>` \| `no creada: <motivo>` \| `transicionada a <estado>` |
| `entrada del índice` | `registrada` \| `transicionada` \| `sin cambio` \| `corregida contra la spec` \| `no registrada: <motivo>` |
| `punteros` | `resuelve` \| `puntero roto` \| `no verificable` \| `rama ausente en el clon` — los tres últimos son los del verificador de `development-repositories` y no se renombran |
| `publicación` | `publicada (<referencia remota leída>)` \| `pendiente: <motivo>` |

Motivos admitidos para `pendiente` en `publicación`: `sin autorización`, `autorización malformada`, `autorización no coincide`, `autorización reutilizada`, `sin commit`, `no fast-forward`, `no verificada` (el push corrió pero la relectura falló).

Motivos admitidos para `no creada` / `no producido`: `copia ausente`, `con cambios sin guardar`, `en otra rama`, `desactualizada`, `adelantada`, `remoto no consultable`, `repositorio vacío`, `fuera del catálogo`, `ruta ocupada`, `sin clave`, `slug inválido`, `entrada existente`, `rama existente`, `rama base sin resolver`.

## Límites fijos, presentes en todo reporte

- Los hooks del repositorio no se ejecutaron: crear la rama, commitear y publicar pasaron por el envoltorio que los anula; un hook que habría rechazado el commit no lo rechazó.
- Si el proyecto Jira tiene activa la integración con GitHub, crear una rama con la clave en el nombre pudo mover el issue; el agente no lo controla.
- La neutralización de configuración ejecutable es parcial, por lo que enumera la skill `development-repositories` en su §4.4, que se cita y no se replica.

## Lo que el reporte nunca contiene

- Contenido de la spec: se cita por ruta.
- Contenido de archivos de secretos ni datos sensibles: los patrones prohibidos los enumera la regla `03-seguridad-y-secretos.md`, que se cita y no se replica.
- La palabra `publicada` sin la referencia remota leída al lado.
- Un `resuelve` en `punteros` si el verificador no corrió.

## Ejemplo, con datos sintéticos

```markdown
## Desarrollo
ABC-000 — validar-rut-en-registro

## Piezas
| Repositorio | Rama base | Rama | Commit | Spec | Entrada del índice | Punteros | Publicación |
| --- | --- | --- | --- | --- | --- | --- | --- |
| ejemplo-backend | main (remoto) | feat/ABC-000-validar-rut-en-registro (creada) | 3f2a9c1 | specs/ABC-000-validar-rut-en-registro/spec.md | registrada | resuelve | pendiente: sin autorización |

## Pendientes
- push — ejemplo-backend, feat/ABC-000-validar-rut-en-registro — `. .claude/skills/development-repositories/scripts/lib-repo-state.sh && repo_git ../ejemplo-backend push -u origin feat/ABC-000-validar-rut-en-registro` — sin autorización
- commit del índice — `.claude/skills/development-repositories/spec-index.md` — por diseño, regla 05

## Planes de escritura
Ninguno.

## Límites
- Hooks del repositorio no ejecutados.
- Posible efecto de la integración Jira-GitHub al crear la rama, no verificado.
- Neutralización parcial (§4.4 de la skill de repositorios).

## Accesos
Sin fallas.
```

# Quickstart de validación: Portar agentes

Guía de verificación end-to-end del feature 002. Ejecutable desde la raíz del repo, rama `002-portar-agentes` activa. `$SCRATCH` es el directorio temporal de la sesión y `$RAIZ` la raíz de fixtures que se arma en él; ninguno vive dentro del árbol del repositorio.

Estas verificaciones se ejecutan **en esta corrida**, sobre los artefactos ya presentes en la rama. Un artefacto recuperado del respaldo que falle su verificación se corrige o se re-deriva, y el hecho se declara en `evidence.md` (decisión D8 de [research.md](research.md)).

## 1. Barrido corporativo (SC-001, FR-014)

```bash
grep -riE 'cencosud|cencoflow|atlassian-cencosud|e98853f7' .claude/ README.md
grep -rE '\bCIAM\b|CIAM-[0-9]+|14186|14516|14530|df-ciam' .claude/ README.md
```

**Esperado**: cero líneas (exit 1) en ambos. `specs/` exenta.

## 2. Estado de agentes y contracts (SC-002, SC-003, Contratos 2 y 4)

```bash
ls -1 .claude/agents/ .claude/contracts/
for a in product-owner atlassian-executor developer; do sed -n '1,6p' ".claude/agents/$a.md"; echo ---; done
```

**Esperado**: agentes = exactamente los 3 de rol; contracts = exactamente los 2; cada frontmatter con `name` correcto y tools conforme al Contrato 1 de [contracts/interfaces.md](contracts/interfaces.md).

## 3. Prueba de ida y vuelta del hash (SC-003, FR-004)

Con un plan sintético que contenga `## Operaciones` y el delimitador de cierre. El plan de prueba se crea en el scratchpad de la sesión, no en `/tmp`:

```bash
F="$SCRATCH/plan-sintetico.md"   # crear según la estructura de .claude/contracts/write-plan.md
sed -n '/^## Operaciones$/,/^<!-- end-operations -->$/p' "$F" | shasum -a 256   # sellar
# insertar la marca con ese hash → recomputar → debe coincidir (vigente)
# alterar una operación → recomputar → debe diferir (caducado)
```

**Esperado**: el hash no cambia al insertar la marca (la marca queda fuera de lo sellado) y sí cambia al alterar una operación. Registrar los tres hashes como evidencia en esta spec.

## 4. Verificación tipada de publish-authorization (US2, escenario 5)

Construir bloques sintéticos con el hash de la línea canónica (`clave|repositorio|rama|fecha`) y aplicar las verificaciones 1 a 6 del contract en orden, deteniéndose en la primera falla. Las verificaciones 7 a 9 exigen estado git de una corrida real del agente y quedan fuera del alcance sintético: se declara, no se finge cobertura.

| Caso | Bloque | Clasificación esperada |
| --- | --- | --- |
| A | Completo y consistente con la pieza operada | vigente (1-6 en verde) |
| B | Invocación sin bloque | `ausente` |
| C | Falta un campo (por ejemplo `fecha`) | `malformada` (verificación 2) |
| D | Hash alterado en un carácter | `malformada` (verificación 3) |
| E | Bloque consistente, pero `rama` distinta de la operada | `no coincide` (verificación 5) |
| F | "haz push de la rama" en prosa | `ausente` |

**Nota de vocabulario**: un hash alterado es `malformada`, no `no coincide`. La distinción la fija el contract y la detalla [data-model.md](data-model.md).

## 5. Scripts de development-repositories (SC-004)

Sintaxis y barrido:

```bash
for s in .claude/skills/development-repositories/scripts/*.sh; do bash -n "$s" && echo "OK $s"; done
grep -rlEi 'df-ciam|ciam|cencosud|cencoflow' .claude/skills/development-repositories/ || echo "barrido limpio"
grep -rn 'REPOS_ROOT\|REPOS_CATALOG' .claude/skills/development-repositories/SKILL.md .claude/skills/development-repositories/layout.md
```

Corrida funcional contra el fixture sintético (la receta completa está en `examples/test-catalog.md` §3; la raíz va en el scratchpad, **nunca dentro del árbol del workspace** — los propios scripts lo rechazan):

```bash
S=.claude/skills/development-repositories/scripts/run-across-repos.sh
bash "$S" status --catalog "$RAIZ/catalogo-resuelto.md" --root "$RAIZ"; echo "salida: $?"
bash "$S" fetch  --catalog "$RAIZ/catalogo-resuelto.md" --root "$RAIZ"
bash "$S" pull   --catalog "$RAIZ/catalogo-resuelto.md" --root "$RAIZ"
```

**Esperado**: 8 × OK; barrido limpio; los nombres de variable coinciden entre scripts y documentación. En la corrida, cada fila clasifica como el fixture declara en su §4: `status` reporta limpio / atrasado-aún-al-día / con cambios sin guardar / vacío-sin-commits / ausente y **sale con código 2**; `fetch` revela el atrasado; `pull` actualiza solo a ese, salta el sucio (cambios sin guardar) y el vacío (sin upstream) dejando su contenido intacto. El fixture es de un solo uso por verbo mutante: para repetir, se rearma la raíz.

## 6. Resolución de punteros (SC-005)

Dos barridos, porque uno solo no cubre las dos formas de citar:

```bash
# a. Rutas de repo citadas en prosa por los 3 agentes y los 2 contracts
grep -hoE '(\.claude|specs/002-portar-agentes)[A-Za-z0-9_./-]*\.(md|sh)' \
  .claude/agents/*.md .claude/contracts/*.md | sort -u | while read -r p; do
    [ -e "$p" ] && echo "OK  $p" || echo "ROTO  $p"; done
# b. Enlaces markdown relativos, resueltos respecto del directorio de cada archivo
```

**Esperado**: toda ruta citada existe; cero rutas del workspace de origen.

El barrido (b) importa porque un enlace markdown con ruta relativa —de los que suben directorios con puntos— no aparece en el (a), que solo captura rutas escritas desde la raíz del repo, y puede estar roto igual. Se resuelve cada destino respecto del directorio del archivo que lo contiene.

**Límite declarado del barrido (b)**: un verificador que busque la sintaxis de enlace sobre el texto crudo no distingue un enlace real de uno citado como ejemplo dentro de código inline, y reporta el segundo como roto. Es un falso positivo conocido: se revisa a ojo antes de declarar una falla.

## 7. Retiro de genéricos y coherencia (SC-006)

```bash
grep -rn 'revisor-proyecto' .claude/ README.md
grep -rn 'arquitecto\|documentador\|revisor-codigo' .claude/ README.md
```

**Esperado**: el primer grep en cero fuera de `specs/` — `revisor-proyecto` no queda en ningún ámbito. El segundo **puede devolver líneas**: cada una debe declarar que ese agente proviene de la configuración personal de quien opera y no de la plantilla (Contrato 4 de [contracts/interfaces.md](contracts/interfaces.md)). Una mención sin esa procedencia es no conforme. Leer además la sección de delegación de la regla 04 para confirmar que la distinción de origen está escrita.

## 8. Trazabilidad (SC-007)

```bash
git log --oneline main..002-portar-agentes | head; git log --oneline main -1
```

**Esperado**: commits solo en la rama; `main` en el merge del feature 001 (`d55dff8`). La rama `backup/002-portar-agentes` puede existir localmente como respaldo de la primera corrida; no se integra ni se publica.

## Referencias

- [spec.md](spec.md) · [research.md](research.md) (mapa de transformaciones y decisiones) · [contracts/interfaces.md](contracts/interfaces.md) · [data-model.md](data-model.md) · [evidence.md](evidence.md) (resultados de estas verificaciones)

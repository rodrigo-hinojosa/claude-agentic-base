# Quickstart de validación: Concisión en confluence-docs

Guía de verificación end-to-end del feature 003. Ejecutable desde la raíz del repo, rama `003-concision-confluence-docs` activa. Cada bloque nombra el criterio de la spec que cubre y el resultado esperado. `$SKILL` es `.claude/skills/confluence-docs` y `$EV` es `specs/003-concision-confluence-docs/evidence`.

```bash
SKILL=.claude/skills/confluence-docs
EV=specs/003-concision-confluence-docs/evidence
```

## 1. Barrido corporativo (SC-008, FR-016)

```bash
grep -riE 'cencosud|cencoflow|e98853f7|df-ciam' "$SKILL" README.md
grep -rE '\bCIAM\b|CIAM-[0-9]+|14186|14516|14530' "$SKILL" README.md
```

**Esperado**: cero líneas (exit 1) en ambos. `specs/` exenta.

## 2. Greps de texto sobre la skill (SC-006, FR-002, FR-003, FR-005, FR-007, FR-010, FR-012, FR-013)

Cada comando lleva su resultado esperado y el requisito que cubre en el comentario. Los patrones con barra vertical usan `-E` y la escapan.

```bash
grep -c 'supuesto explícito' "$SKILL/SKILL.md"                          # 0            FR-003
grep -c '~4 secciones' "$SKILL/SKILL.md" "$SKILL/rules.md"               # 0 y 0        FR-012
grep -c 'prose-conforming' "$SKILL/SKILL.md"                             # >= 1         FR-015
grep -c 'prose-with-seeded-flaws' "$SKILL/SKILL.md"                      # >= 1         FR-015
grep -cE '^\| 33 ' "$SKILL/rules.md"                                     # 1            FR-005
grep -c 'Reglas de prosa (26-33)' "$SKILL/rules.md"                      # 1            FR-005
grep -cE '^\| 5 \|.*cuando corresponda' "$SKILL/rules.md"                # 1            FR-002
grep -c 'parrafos de 1 oracion' "$SKILL/rules.md"                        # 0            FR-007
grep -c 'no términos literales' "$SKILL/rules.md"                        # 0            FR-007
grep -cE '^\| 26 \|.*entre dos y cuatro' "$SKILL/rules.md"               # 0            FR-010
grep -cE '^\| 7 \|.*regla 25' "$SKILL/rules.md"                          # 1            FR-013
grep -c 'Secciones obligatorias y vacíos' "$SKILL"/templates.md "$SKILL"/rules.md "$SKILL"/SKILL.md   # >= 1 cada uno   Contrato 2
grep -c 'Sin información registrada' "$SKILL/rules.md" "$SKILL/SKILL.md" # 0 y 0 (citan, no reproducen)   Contrato 2, Principio II
grep -cE 'feature 003|003-concision' "$SKILL/rules.md" "$SKILL/templates.md"   # >= 1 cada uno   D16
```

## 3. Comando ampliado sobre los fixtures (SC-003, SC-005, FR-011, FR-014)

Correr el bloque de código de `rules.md` (contrato 1) sobre cada archivo:

```bash
for f in prose-conforming prose-with-seeded-flaws compliant-adr structured-doc seeded-violations; do
  echo "== $f"; python3 - "$SKILL/examples/$f.md" <<'PY'
# pegar aquí el cuerpo del comando publicado en rules.md
PY
done
```

**Esperado**:

| Archivo | R26 5+ | R27 | R28 | R29 párrafos 2+ | R33 |
| --- | --- | --- | --- | --- | --- |
| `prose-conforming.md` | 0 | 0 | 0.0 | 0 | 0 |
| `prose-with-seeded-flaws.md` | 1 | 1 | ≥ 1 disparo (una negrita ≥ 60) | 1 | 0 |
| `compliant-adr.md` | 0 | 0 | 0.0 | 0 | 0 |
| `structured-doc.md` | 0 | 0 | 0.0 | 0 | 0 |
| `seeded-violations.md` | 0 | 1 | 0.0 | 0 | 1 (la apertura) |

Además, la cabecera de cada fixture cita esa misma salida con la fecha de la corrida (contrato 3): `grep -c 'R33 muletillas' $SKILL/examples/*.md` devuelve 1 por archivo.

## 4. Autodetección (SC-007, edge case)

```bash
for f in rules.md SKILL.md templates.md; do echo "== $f"; python3 - "$SKILL/$f" <<'PY'
# cuerpo del comando de rules.md
PY
done | grep 'R33'
```

**Esperado**: `R33 muletillas (lista)     : 0` en los tres. Si alguno da más de cero, o se corrige la prosa o se declara la exención con motivo escrito en el propio archivo.

## 5. Encabezados de los ejemplos contra la plantilla (SC-005, contrato 6)

```bash
grep '^## ' "$SKILL/examples/compliant-adr.md"
grep '^## ' "$SKILL/examples/structured-doc.md"
grep -c 'fuente única\|SSOT' "$SKILL/examples/structured-doc.md"
grep -c 'Próximos pasos' "$SKILL/examples/compliant-adr.md"
grep -n 'templates.md' "$SKILL/examples/compliant-adr.md"
```

**Esperado**: `compliant-adr.md` = Estado, Contexto, Decisión, Alternativas consideradas, Consecuencias, Referencias (en ese orden); `structured-doc.md` = `1. Descripción`, `2. Uso y ejemplos`, `3. Decisiones y supuestos`, `4. Referencias y pendientes`; hecho SSOT ≤ 2; `Próximos pasos` = 0; ninguna referencia a `templates.md` en el ADR. La sección 1 de `templates.md` §2 está materializada como callout (D12), lo que `templates.md` §2 declara en su nota.

## 6. Lo que se conserva (FR-016, spec "Lo que se conserva")

```bash
git diff main -- "$SKILL/rules.md" | grep -E '^[-+]\| (27|28|29|30|31|32|4|13|23|3|21|6) '
git diff main --stat -- "$SKILL/SKILL.md" | tail -1
grep -c 'Un umbral se cumple moviendo texto' "$SKILL/rules.md"
grep -c 'se omite si no' "$SKILL/templates.md"
```

**Esperado**: el primer comando no devuelve líneas (esas filas no cambian); el segundo muestra un cambio acotado (decenas de líneas, no cientos); los dos últimos devuelven al menos 1 y al menos 3 respectivamente (bitácora, resumen, referencias de ADR).

## 7. Auditorías persistidas (SC-002, US5 escenario 4, contrato 7)

Invocar `confluence-docs` en modo auditar sobre cada ejemplo y guardar el reporte sin editar en `$EV/audit-<nombre>.md`.

**Esperado**:

- `audit-seeded-violations.md`: veredicto `no-conforme`; hallazgos de severidad alta por la 33 (ubicación L18) y por la 10 (segundo párrafo), más los que la cabecera enumera; la lista de la cabecera y el reporte coinciden entrada por entrada, con el método de cada una.
- `audit-prose-conforming.md`, `audit-compliant-adr.md`, `audit-structured-doc.md`: veredicto `conforme`, cero hallazgos, tabla omitida.

## 8. Generaciones persistidas (SC-001, SC-004, FR-017, contrato 7)

Invocar `confluence-docs` en modo generar con cada insumo de `$EV/input-*.md`, pidiendo materializar la salida en `$EV/output-*.md`, y luego:

```bash
grep -ciE 'buenas prácticas|se recomienda|se asume|es importante' "$EV"/output-*.md
grep -cE '^(Sin información registrada|Pendiente: |Sin pendientes)' "$EV/output-doc-tecnica-small.md" "$EV/output-adr-no-cons.md"
grep -c '^> \|^| Campo \|^## Índice\|^- §' "$EV/output-doc-tecnica-small.md"
grep -c '^- ' "$EV/output-bitacora-short.md"
```

**Esperado**: primer grep = 0 en los tres; segundo ≥ 1 en ambos (al menos una línea marcada por documento); tercero = 0 (sin callout, metadatos ni índice en la doc-tecnica pequeña); cuarto = 0 o solo viñetas dentro de "Pendientes" (sin bloque de viñetas de apertura). Sobre cada salida corre además el comando de prosa: R33 = 0. `evidence.md` registra fecha, modo e insumo de cada corrida.

## 9. Punteros (Principio II)

Verificador de enlaces markdown relativos, heredado del feature 002 y ampliado para excluir los bloques de código (una regex como `[^*]+` dentro de un bloque parecía un enlace). Límite declarado: sigue marcando como roto un enlace escrito dentro de código inline; ese caso se revisa a mano.

```bash
python3 - <<'PY'
import re, os, glob
roots = glob.glob(".claude/skills/confluence-docs/**/*.md", recursive=True) + glob.glob("specs/003-concision-confluence-docs/**/*.md", recursive=True)
bad = []
for f in roots:
    t = re.sub(r"```.*?```", "", open(f, encoding="utf-8").read(), flags=re.S)
    for m in re.finditer(r"\]\(([^)#\s]+)", t):
        p = m.group(1)
        if p.startswith(("http", "mailto")): continue
        if not os.path.exists(os.path.normpath(os.path.join(os.path.dirname(f), p))): bad.append((f, p))
print(bad or "sin enlaces rotos")
PY
```

**Esperado**: `sin enlaces rotos`.

## 10. Cierre

- `$EV/evidence.md` lista las siete corridas de §7 y §8 con fecha, más la salida del comando sobre cada fixture (§3) y sobre los tres archivos normativos (§4).
- Comando de prosa sobre los artefactos de esta feature (opcional, no es criterio de cierre): R33 = 0 en `spec.md`, `plan.md`, `data-model.md` y `quickstart.md`. En `research.md` §2 y en `contracts/interfaces.md` contrato 3 el comando marca una coincidencia cada uno: es la cita, como dato, de la apertura sembrada en `seeded-violations.md`. Es el caso de coincidencia legítima que el auditor exime al juzgar (medido el 15-09-2026).
- `git status` limpio en la rama; ningún commit en `main`; push, PR y merge solo con confirmación explícita del dueño.

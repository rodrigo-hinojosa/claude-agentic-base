# Quickstart de validación: Portar estándar agnóstico

Guía para verificar el feature end-to-end una vez implementado. Cada bloque es ejecutable desde la raíz del repo.

## Prerrequisitos

- Rama `001-portar-skills-rules` activa.
- Node.js ≥ 18 disponible (`node --version`).
- Sin cambios pendientes ajenos al feature (`git status`).

## 1. Barrido corporativo (SC-001)

```bash
grep -riE 'cencosud|cencoflow|atlassian-cencosud|e98853f7' .claude/ .mcp.json README.md
grep -rE '\bCIAM\b|CIAM-[0-9]+' .claude/ .mcp.json README.md
```

**Esperado**: ambas búsquedas devuelven cero líneas (exit code 1). `specs/` queda fuera del barrido por documentar la procedencia.

## 2. Set de reglas (SC-002)

```bash
ls -1 .claude/rules/
```

**Esperado**: exactamente los 10 archivos `00-lenguaje-y-formato.md` … `09-punteros-y-replicas.md` del Contrato 2 ([contracts/interfaces.md](contracts/interfaces.md)). Sin `ejemplo-regla-por-ruta.md`, sin regla Cencoflow.

## 3. Frontmatter de skills (SC-003)

```bash
for s in confluence-docs jira-management visual-docs speckit-git-commit; do
  echo "== $s"; sed -n '1,8p' ".claude/skills/$s/SKILL.md"
done
```

**Esperado**: cada SKILL.md abre con frontmatter que incluye `name:` (igual al directorio) y `description:`. Los `allowed-tools` de Atlassian usan solo el prefijo `mcp__atlassian__`.

## 4. Suite de tests de visual-docs (SC-004)

```bash
node .claude/skills/visual-docs/tests/run-tests.mjs
```

**Esperado**: suite completa en verde, sin referencias rotas al nombre antiguo.

## 5. Parámetros por proyecto (SC-005)

```bash
grep -n 'Pendiente de configurar' .claude/skills/confluence-docs/SKILL.md .claude/skills/jira-management/SKILL.md
grep -nE '18698|14186|10670|ciam-management|uroboros' .claude/skills/ -r
```

**Esperado**: la primera búsqueda encuentra la sección de parámetros en ambas skills; la segunda devuelve cero líneas.

## 6. Conexión Atlassian (SC-006)

```bash
cat .mcp.json
```

**Esperado**: entrada `atlassian` exacta al Contrato 3, sin credenciales. Luego, en una sesión interactiva de Claude Code:

1. Ejecutar `/mcp` y completar el OAuth del servidor `atlassian` con la cuenta personal.
2. Pedir a la sesión que liste los recursos accesibles de Atlassian (descubrimiento de sitios/cloudId).

**Esperado**: el sitio personal aparece sin que ningún archivo del repo haya sido editado.

## 7. Trazabilidad SDD (SC-007)

```bash
git log --oneline main..001-portar-skills-rules
git log --oneline main -1
```

**Esperado**: todos los commits del feature viven en la rama `001-portar-skills-rules`; `main` sigue en el commit base (`ddf28fb`).

## Referencias

- Especificación: [spec.md](spec.md)
- Mapa de portación: [research.md](research.md)
- Contratos: [contracts/interfaces.md](contracts/interfaces.md)

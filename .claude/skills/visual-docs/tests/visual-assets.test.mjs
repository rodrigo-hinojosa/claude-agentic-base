import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const testDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(testDir, "../../../..");
const starterDir = resolve(repoRoot, ".claude/skills/visual-docs/assets/starter");
const validator = resolve(repoRoot, ".claude/skills/visual-docs/scripts/validate_docs.mjs");
const visualFixture = resolve(testDir, "fixtures/visual-docs");

function attribute(tag, name) {
  return tag.match(new RegExp(`\\b${name}=["']([^"']+)["']`, "i"))?.[1];
}

function assertUniqueIds(html, label) {
  const ids = [...html.matchAll(/\bid=["']([^"']+)["']/g)].map((match) => match[1]);
  assert.equal(new Set(ids).size, ids.length, `${label} contiene IDs duplicados`);
}

function assertAccessibleDiagrams(html, expectedCount, label) {
  const diagrams = [...html.matchAll(/<svg\b([^>]*)class=["'][^"']*\btech-diagram\b[^"']*["']([^>]*)>([\s\S]*?)<\/svg>/gi)];
  assert.equal(diagrams.length, expectedCount, `${label} debe contener ${expectedCount} diagramas informativos`);

  for (const [, beforeClass, afterClass, body] of diagrams) {
    const tag = `<svg ${beforeClass} class="tech-diagram" ${afterClass}>`;
    const labelledBy = attribute(tag, "aria-labelledby");
    assert.equal(attribute(tag, "role"), "img");
    assert(labelledBy, "cada diagrama debe declarar aria-labelledby");
    assert.match(body, /<title\b[^>]*id=["'][^"']+["'][^>]*>[^<]+<\/title>/i);
    assert.match(body, /<desc\b[^>]*id=["'][^"']+["'][^>]*>[^<]+<\/desc>/i);
    for (const id of labelledBy.split(/\s+/)) {
      assert.match(body, new RegExp(`\\bid=["']${id}["']`), `aria-labelledby no resuelve #${id}`);
    }
  }
}

export async function run() {
  const diagrams = readFileSync(resolve(starterDir, "diagrams.html"), "utf8");
  const wireframes = readFileSync(resolve(starterDir, "wireframes.html"), "utf8");
  const css = readFileSync(resolve(starterDir, "documentation.css"), "utf8");
  const visualIndex = readFileSync(resolve(visualFixture, "index.html"), "utf8");
  const visualJourney = readFileSync(resolve(visualFixture, "journey.html"), "utf8");
  const generalIndex = readFileSync(resolve(testDir, "fixtures/general-docs/index.html"), "utf8");
  const generatedFixtures = `${generalIndex}\n${visualIndex}\n${visualJourney}`;

  assertUniqueIds(diagrams, "diagrams.html");
  assertAccessibleDiagrams(diagrams, 5, "diagrams.html");
  assert.match(diagrams, /class=["']message["']/);
  assert.match(diagrams, /class=["']return["']/);
  assert.equal((diagrams.match(/<defs>/g) || []).length, 1, "debe existir un solo bloque defs");

  const screenCount = (wireframes.match(/class=["']screen-case["']/g) || []).length;
  const railCount = (wireframes.match(/class=["']system-rail["']/g) || []).length;
  assert(screenCount > 0, "el starter debe incluir casos de pantalla");
  assert.equal(railCount, screenCount, "cada pantalla debe incluir su capa sistémica");
  assert.match(css, /content:\s*["']LOW-FI["']/);
  assert.match(css, /content:\s*["']CAPA SISTÉMICA["']/);
  assert.match(wireframes, /••(?:08|17|42)/, "los datos ilustrativos deben estar enmascarados");
  assert.doesNotMatch(wireframes, /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i);

  assertUniqueIds(visualIndex, "fixture visual index.html");
  assertAccessibleDiagrams(visualIndex, 1, "fixture visual index.html");
  assert.match(visualJourney, />LOW-FI\b/);
  assert.match(visualJourney, />CAPA SISTÉMICA</);
  assert.match(visualJourney, /••42/);
  // LÍMITE DECLARADO: esta lista está escrita a mano. Cubre los cuatro nombres
  // que hoy existen solo en el starter; un quinto que alguien agregue allá pasaría
  // sin aviso. Lo definido por lista deja fuera en silencio. Derivarla del starter
  // exige distinguir sus hechos de ejemplo de su vocabulario estructural, que no
  // es mecánico, y por eso se declara el límite en vez de fingir cobertura total.
  for (const starterOnlyFact of ["Provider API", "Event Bus", "Primary Store", "Integration Adapter"]) {
    assert.doesNotMatch(generatedFixtures, new RegExp(starterOnlyFact, "i"), `los fixtures importaron el hecho de ejemplo: ${starterOnlyFact}`);
  }

  // FR-004: los tres estados editoriales -confirmado, propuesto, abierto- deben
  // existir como mecanismo en el starter, no solo como instrucción en la guía.
  // Lo comandable es que el mecanismo esté; que se aplique bien a un contenido
  // concreto es juicio y no se automatiza. Se verifica lo primero y se dice
  // que lo segundo queda fuera.
  const starterCss = readFileSync(resolve(starterDir, "documentation.css"), "utf8");
  for (const estado of [".decision", ".proposed", ".open", ".status"]) {
    assert.ok(
      starterCss.includes(estado),
      `el starter no define el estado editorial ${estado}, que FR-004 necesita`
    );
  }
  const starterIndex = readFileSync(resolve(starterDir, "index.html"), "utf8");
  assert.match(starterIndex, /class="decision proposed"/, "el starter no muestra el estado Propuesto en uso");
  assert.match(starterIndex, /class="(callout|status) open"/, "el starter no muestra el estado Abierto en uso");

  const validated = spawnSync(process.execPath, [validator, visualFixture], {
    cwd: repoRoot,
    encoding: "utf8",
  });
  assert.equal(validated.status, 0, validated.stderr);
  assert.match(validated.stdout, /Revisados 2 HTML y 1 CSS en todo el árbol: 0 error\(es\), 0 advertencia\(s\)\./);
}

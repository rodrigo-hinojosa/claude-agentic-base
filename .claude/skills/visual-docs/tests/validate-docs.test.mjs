import assert from "node:assert/strict";
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { makeTempDirectory, removeTree } from "./helpers/filesystem.mjs";

const testDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(testDir, "../../../..");
const validator = resolve(repoRoot, ".claude/skills/visual-docs/scripts/validate_docs.mjs");
const fixtures = resolve(testDir, "fixtures");

const invalidCases = [
  ["broken-link", /enlace roto: missing\.html/],
  ["missing-asset", /asset inexistente: missing\.png/],
  ["duplicate-id", /id duplicado: #repeated/],
  ["external-dependency", /dependencia externa no permitida: https:\/\/example\.invalid\/remote\.css/],
  ["invalid-h1", /debe contener exactamente un h1; encontrados: 2/],
  // Los dos de abajo cubren defectos que el validador no veía antes de la
  // feature 024: solo miraba los HTML del nivel superior y nunca abría el CSS.
  ["nested-defect", /guias\/detalle\.html: enlace roto: ausente\.html/],
  ["css-external", /docs\.css: dependencia externa no permitida: @import https:\/\/fonts\.googleapis\.com/],
];

function runValidator(target) {
  return spawnSync(process.execPath, [validator, target], {
    cwd: repoRoot,
    encoding: "utf8",
  });
}

function validSinglePage() {
  return `<!doctype html>
<html lang="es"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Fixture de advertencia</title></head>
<body><header class="topbar"><nav><a href="index.html">Inicio</a></nav></header><main><h1>Una sola página válida</h1></main></body></html>\n`;
}

export async function run() {
  const valid = runValidator(resolve(fixtures, "general-docs"));
  assert.equal(valid.status, 0, valid.stderr);
  assert.doesNotMatch(valid.stderr, /ERROR|WARN/);

  for (const [directory, pattern] of invalidCases) {
    const result = runValidator(resolve(fixtures, "invalid", directory));
    assert.notEqual(result.status, 0, `${directory} debía fallar`);
    assert.match(result.stderr, pattern, `${directory} no produjo el hallazgo esperado`);
  }

  const tempRoot = makeTempDirectory("visual-docs-validator-");
  try {
    const warningSite = resolve(tempRoot, "warning-site");
    mkdirSync(warningSite);
    writeFileSync(resolve(warningSite, "index.html"), validSinglePage());
    const warning = runValidator(warningSite);
    assert.equal(warning.status, 0, warning.stderr);
    assert.match(warning.stderr, /WARN\s+\.: el formato multipágina normalmente requiere dos o más HTML/);
    assert.match(warning.stdout, /0 error\(es\), 1 advertencia\(s\)/);

    const missingDirectory = runValidator(resolve(tempRoot, "does-not-exist"));
    assert.notEqual(missingDirectory.status, 0);
    assert.match(missingDirectory.stderr, /no existe el directorio/);
  } finally {
    removeTree(tempRoot);
  }

  const noArgument = spawnSync(process.execPath, [validator], { cwd: repoRoot, encoding: "utf8" });
  assert.notEqual(noArgument.status, 0);
  assert.match(noArgument.stdout, /Uso:/);
}

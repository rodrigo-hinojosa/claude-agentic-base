import assert from "node:assert/strict";
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { hashTree, listRelativeFiles, makeTempDirectory, removeTree } from "./helpers/filesystem.mjs";

const testDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(testDir, "../../../..");
const scaffold = resolve(repoRoot, ".claude/skills/visual-docs/scripts/scaffold_docs.mjs");
const validator = resolve(repoRoot, ".claude/skills/visual-docs/scripts/validate_docs.mjs");
const generalFixture = resolve(testDir, "fixtures/general-docs");
const expectedFiles = [
  "design-tokens.json",
  "diagrams.html",
  "documentation.css",
  "index.html",
  "page-patterns.html",
  "wireframes.html",
];

function runNode(script, args = []) {
  return spawnSync(process.execPath, [script, ...args], {
    cwd: repoRoot,
    encoding: "utf8",
  });
}

export async function run() {
  const tempRoot = makeTempDirectory("visual-docs-scaffold-");

  try {
    const newTarget = resolve(tempRoot, "new-site");
    const created = runNode(scaffold, [newTarget]);
    assert.equal(created.status, 0, created.stderr);
    assert.deepEqual(listRelativeFiles(newTarget), expectedFiles);

    const validated = runNode(validator, [newTarget]);
    assert.equal(validated.status, 0, validated.stderr);
    assert.match(validated.stdout, /Revisados 4 HTML y 1 CSS en todo el árbol: 0 error\(es\), 0 advertencia\(s\)\./);

    const emptyTarget = resolve(tempRoot, "empty-site");
    mkdirSync(emptyTarget);
    const filled = runNode(scaffold, [emptyTarget]);
    assert.equal(filled.status, 0, filled.stderr);
    assert.deepEqual(listRelativeFiles(emptyTarget), expectedFiles);

    const protectedTargets = [
      {
        name: "existing-file",
        prepare(target) {
          mkdirSync(target);
          writeFileSync(resolve(target, "user-notes.txt"), "contenido del usuario\n");
        },
      },
      {
        name: "existing-directory",
        prepare(target) {
          mkdirSync(resolve(target, "user-assets"), { recursive: true });
          writeFileSync(resolve(target, "user-assets/diagram.txt"), "activo preexistente\n");
        },
      },
      {
        name: "scaffolded-site",
        prepare(target) {
          const first = runNode(scaffold, [target]);
          assert.equal(first.status, 0, first.stderr);
        },
      },
    ];

    for (const scenario of protectedTargets) {
      const protectedTarget = resolve(tempRoot, scenario.name);
      scenario.prepare(protectedTarget);
      const before = hashTree(protectedTarget);
      const rejected = runNode(scaffold, [protectedTarget]);
      const after = hashTree(protectedTarget);
      assert.notEqual(rejected.status, 0);
      assert.match(rejected.stderr, /destino no está vacío; no se sobrescribió nada/);
      assert.deepEqual(after, before, `${scenario.name} debe permanecer byte a byte intacto`);
    }

    const fixtureValidation = runNode(validator, [generalFixture]);
    assert.equal(fixtureValidation.status, 0, fixtureValidation.stderr);
    assert.match(fixtureValidation.stdout, /Revisados 2 HTML y 1 CSS en todo el árbol: 0 error\(es\), 0 advertencia\(s\)\./);

    const noArgument = runNode(scaffold);
    assert.notEqual(noArgument.status, 0);
    assert.match(noArgument.stdout, /Uso:/);
  } finally {
    removeTree(tempRoot);
  }
}

import assert from "node:assert/strict";
import { existsSync, readFileSync, readdirSync } from "node:fs";
import { dirname, extname, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const testDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(testDir, "../../../..");
const skillDir = resolve(repoRoot, ".claude/skills/visual-docs");

const expectedReferences = [
  "diagram-system.md",
  "page-composition.md",
  "qa-checklist.md",
  "visual-language.md",
  "wireframe-system.md",
];

const expectedStarter = [
  "design-tokens.json",
  "diagrams.html",
  "documentation.css",
  "index.html",
  "page-patterns.html",
  "wireframes.html",
];

function relativeMarkdownLinks(markdown) {
  return [...markdown.matchAll(/\[[^\]]+\]\(([^)]+)\)/g)]
    .map((match) => match[1].split("#", 1)[0])
    .filter((target) => target && !/^[a-z][a-z0-9+.-]*:/i.test(target));
}

function walkFiles(root) {
  const files = [];
  function visit(directory) {
    for (const entry of readdirSync(directory, { withFileTypes: true })) {
      const path = resolve(directory, entry.name);
      if (entry.isDirectory()) visit(path);
      else if (entry.isFile()) files.push(path);
    }
  }
  visit(root);
  return files.sort();
}

function cssVariables(css) {
  return new Map(
    [...css.matchAll(/^\s*(--[\w-]+):\s*([^;]+);/gm)].map((match) => [match[1], match[2].trim().toLowerCase()])
  );
}

export async function run() {
  const entryPath = resolve(skillDir, "SKILL.md");
  const entry = readFileSync(entryPath, "utf8");
  const frontmatter = entry.match(/^---\n([\s\S]*?)\n---\n/);

  assert(frontmatter, "SKILL.md debe declarar frontmatter YAML");
  assert.match(frontmatter[1], /^name:\s*visual-docs$/m);
  assert.match(frontmatter[1], /^description:\s*\S.+$/m);
  assert.match(frontmatter[1], /No usar para implementar una UI de producción/);
  assert.match(entry, /\$ARGUMENTS/, "la entrada Claude debe conservar $ARGUMENTS");

  const referenceLinks = relativeMarkdownLinks(entry)
    .filter((target) => target.startsWith("references/"))
    .map((target) => target.replace("references/", ""))
    .sort();
  assert.deepEqual(referenceLinks, expectedReferences, "las cinco referencias deben enlazarse directamente desde SKILL.md");

  for (const target of relativeMarkdownLinks(entry)) {
    assert(existsSync(resolve(dirname(entryPath), target)), `enlace relativo inexistente en SKILL.md: ${target}`);
  }

  assert.deepEqual(
    readdirSync(resolve(skillDir, "references")).filter((file) => extname(file) === ".md").sort(),
    expectedReferences
  );
  assert.deepEqual(readdirSync(resolve(skillDir, "assets/starter")).sort(), expectedStarter);
  assert.deepEqual(readdirSync(resolve(skillDir, "scripts")).sort(), ["scaffold_docs.mjs", "validate_docs.mjs"]);

  const tokens = JSON.parse(readFileSync(resolve(skillDir, "assets/starter/design-tokens.json"), "utf8"));
  const css = readFileSync(resolve(skillDir, "assets/starter/documentation.css"), "utf8");
  const variables = cssVariables(css);
  const tokenPairs = {
    "--bg": tokens.color.canvas,
    "--paper": tokens.color.paper,
    "--ink": tokens.color.ink,
    "--muted": tokens.color.muted,
    "--line": tokens.color.line,
    "--line-strong": tokens.color.lineStrong,
    "--soft": tokens.color.soft,
    "--soft-2": tokens.color.softAlt,
  };

  for (const [name, value] of Object.entries(tokenPairs)) {
    assert.equal(variables.get(name), value.toLowerCase(), `token ${name} no coincide entre JSON y CSS`);
  }

  for (const file of expectedStarter.filter((name) => name.endsWith(".html"))) {
    const html = readFileSync(resolve(skillDir, "assets/starter", file), "utf8");
    assert.doesNotMatch(html, /<(?:link|script|img)\b[^>]*(?:href|src)=["'](?:https?:)?\/\//i, `${file} depende de red`);
    assert.match(html, /href=["']documentation\.css["']/, `${file} debe usar el CSS local`);
  }

  const markdownFiles = walkFiles(skillDir).filter((file) => extname(file) === ".md");
  for (const file of markdownFiles) {
    const markdown = readFileSync(file, "utf8");
    for (const target of relativeMarkdownLinks(markdown)) {
      assert(
        existsSync(resolve(dirname(file), target)),
        `${relative(repoRoot, file)} contiene un enlace relativo inexistente: ${target}`
      );
    }
  }

  const secretPatterns = [
    /AKIA[0-9A-Z]{16}/,
    /\bgh[pousr]_[A-Za-z0-9]{20,}\b/,
    /\bATATT[0-9A-Za-z_-]{20,}\b/,
    /-----BEGIN (?:RSA |EC |OPENSSH |PGP )?PRIVATE KEY-----/,
    /\bBearer\s+[A-Za-z0-9._~-]{20,}\b/i,
    /\b(?:api[_-]?key|password|secret|token)\s*[:=]\s*["'][^"'\s]{8,}["']/i,
  ];
  const sensitiveScope = [
    ...walkFiles(skillDir),
    ...walkFiles(testDir),
  ];
  for (const file of sensitiveScope) {
    const content = readFileSync(file, "utf8");
    for (const pattern of secretPatterns) {
      assert.doesNotMatch(content, pattern, `posible secreto en ${relative(repoRoot, file)}`);
    }
  }
}

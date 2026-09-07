#!/usr/bin/env node

import { existsSync, readFileSync, readdirSync, statSync } from "node:fs";
import { dirname, extname, isAbsolute, relative, resolve } from "node:path";

const rootArg = process.argv[2];

if (!rootArg || rootArg === "--help" || rootArg === "-h") {
  console.log("Uso: node scripts/validate_docs.mjs <directorio-documentacion>");
  process.exit(rootArg ? 0 : 1);
}

const root = resolve(process.cwd(), rootArg);
const errors = [];
const warnings = [];

function report(bucket, file, message) {
  bucket.push(`${file}: ${message}`);
}

function attributes(tag) {
  return Object.fromEntries(
    [...tag.matchAll(/([:\w-]+)\s*=\s*(["'])(.*?)\2/gs)].map((match) => [match[1].toLowerCase(), match[3]])
  );
}

function isExternal(value) {
  return /^(?:https?:)?\/\//i.test(value);
}

function localTarget(fromFile, value) {
  const hashAt = value.indexOf("#");
  const pathPart = hashAt >= 0 ? value.slice(0, hashAt) : value;
  const hashPart = hashAt >= 0 ? value.slice(hashAt + 1) : "";
  const targetPath = pathPart
    ? resolve(root, dirname(fromFile), pathPart)
    : resolve(root, fromFile);
  return { targetPath, hashPart };
}

function isInsideRoot(path) {
  const offset = relative(root, path);
  return offset === "" || (offset !== ".." && !offset.startsWith(`..${process.platform === "win32" ? "\\" : "/"}`) && !isAbsolute(offset));
}

if (!existsSync(root) || !statSync(root).isDirectory()) {
  console.error(`ERROR: no existe el directorio: ${root}`);
  process.exit(1);
}

// Recorre el árbol completo. Mirar solo el nivel superior anula en silencio
// todas las comprobaciones de abajo para cualquier página en un subdirectorio,
// que es la organización normal de un sitio multipágina.
function walk(dir, prefix = "") {
  const found = [];
  for (const entry of readdirSync(resolve(root, dir), { withFileTypes: true })) {
    if (entry.name.startsWith(".")) continue;
    const rel = prefix ? `${prefix}/${entry.name}` : entry.name;
    if (entry.isDirectory()) found.push(...walk(rel, rel));
    else found.push(rel);
  }
  return found;
}

const allFiles = walk("").sort();
const files = allFiles.filter((file) => extname(file).toLowerCase() === ".html");
const styleFiles = allFiles.filter((file) => extname(file).toLowerCase() === ".css");

if (!files.includes("index.html")) report(errors, ".", "falta index.html");
if (files.length < 2) report(warnings, ".", "el formato multipágina normalmente requiere dos o más HTML");

const documents = new Map(files.map((file) => [file, readFileSync(resolve(root, file), "utf8")]));

// El CSS nunca se abría. Una @import o una url() remota dentro de la hoja de
// estilos rompe la garantía offline sin que ningún tag del HTML lo delate.
for (const file of styleFiles) {
  const css = readFileSync(resolve(root, file), "utf8");
  for (const match of css.matchAll(/@import\s+(?:url\()?\s*(["']?)([^"')\s;]+)\1/gi)) {
    if (isExternal(match[2])) report(errors, file, `dependencia externa no permitida: @import ${match[2]}`);
  }
  // Las @import ya se reportaron arriba; se retiran para no contarlas dos veces.
  const cssSinImports = css.replace(/@import[^;]*;?/gi, "");
  for (const match of cssSinImports.matchAll(/url\(\s*(["']?)([^"')]+)\1\s*\)/gi)) {
    const value = match[2].trim();
    if (value.startsWith("data:")) continue;
    if (isExternal(value)) {
      report(errors, file, `dependencia externa no permitida: url(${value})`);
      continue;
    }
    const assetPath = resolve(root, dirname(file), value.split(/[#?]/, 1)[0]);
    if (!isInsideRoot(assetPath)) report(errors, file, `url() sale del directorio: ${value}`);
    else if (!existsSync(assetPath)) report(errors, file, `asset inexistente: ${value}`);
  }
}

for (const [file, html] of documents) {
  if (!/<html\b[^>]*\blang=["'][^"']+["']/i.test(html)) report(errors, file, "falta lang en <html>");
  if (!/<meta\b[^>]*\bname=["']viewport["']/i.test(html)) report(errors, file, "falta meta viewport");
  if (!/<title>\s*[^<]+\s*<\/title>/i.test(html)) report(errors, file, "falta <title> con contenido");
  if (!/class=["'][^"']*\btopbar\b/i.test(html)) report(errors, file, "falta topbar del formato documental");
  if (!/<nav\b/i.test(html)) report(errors, file, "falta navegación");

  const h1Count = (html.match(/<h1\b/gi) || []).length;
  if (h1Count !== 1) report(errors, file, `debe contener exactamente un h1; encontrados: ${h1Count}`);

  const ids = [...html.matchAll(/\bid\s*=\s*(["'])(.*?)\1/gs)].map((match) => match[2]);
  const duplicateIds = [...new Set(ids.filter((id, index) => ids.indexOf(id) !== index))];
  for (const id of duplicateIds) report(errors, file, `id duplicado: #${id}`);

  for (const match of html.matchAll(/<a\b[^>]*\bhref\s*=\s*(["'])(.*?)\1[^>]*>/gis)) {
    const href = match[2].trim();
    if (!href || /^(?:mailto:|tel:|javascript:|data:)/i.test(href) || isExternal(href)) continue;
    const { targetPath, hashPart } = localTarget(file, href);
    if (!isInsideRoot(targetPath)) {
      report(errors, file, `enlace sale del directorio de documentación: ${href}`);
      continue;
    }
    if (!existsSync(targetPath)) {
      report(errors, file, `enlace roto: ${href}`);
      continue;
    }
    if (hashPart) {
      const targetName = relative(root, targetPath);
      let targetHtml = documents.get(targetName);
      if (targetHtml === undefined) {
        try {
          targetHtml = readFileSync(targetPath, "utf8");
        } catch (cause) {
          report(errors, file, `no se pudo leer el destino del ancla ${href}: ${cause.message}`);
          continue;
        }
      }
      const escaped = hashPart.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
      if (!new RegExp(`\\bid=["']${escaped}["']`).test(targetHtml)) {
        report(errors, file, `ancla inexistente: ${href}`);
      }
    }
  }

  for (const match of html.matchAll(/<(link|script|img)\b[^>]*>/gis)) {
    const tagName = match[1].toLowerCase();
    const attrs = attributes(match[0]);
    const value = tagName === "link" ? attrs.href : attrs.src;
    if (!value || value.startsWith("data:")) continue;
    const isRequiredAsset = tagName !== "link" || (attrs.rel || "").toLowerCase().split(/\s+/).includes("stylesheet");
    if (!isRequiredAsset) continue;
    if (isExternal(value)) {
      report(errors, file, `dependencia externa no permitida: ${value}`);
      continue;
    }
    const assetPath = resolve(root, dirname(file), value.split("#", 1)[0]);
    if (!existsSync(assetPath)) report(errors, file, `asset inexistente: ${value}`);
  }

  for (const match of html.matchAll(/<svg\b([^>]*)>([\s\S]*?)<\/svg>/gi)) {
    const attrs = attributes(`<svg ${match[1]}>`);
    if (!(attrs.class || "").split(/\s+/).includes("tech-diagram")) continue;
    const body = match[2];
    if (attrs.role !== "img") report(errors, file, "tech-diagram sin role=img");
    if (!attrs["aria-labelledby"]) report(errors, file, "tech-diagram sin aria-labelledby");
    if (!/<title\b[^>]*>[^<]+<\/title>/i.test(body)) report(errors, file, "tech-diagram sin <title>");
    if (!/<desc\b[^>]*>[^<]+<\/desc>/i.test(body)) report(warnings, file, "tech-diagram sin <desc>");
  }

  if (/qué\s+cambió\s+respecto|correcci[oó]n\s+(?:a|de)\s+v\d/i.test(html)) {
    report(warnings, file, "contiene una comparación con una versión anterior; conservar solo si fue solicitada");
  }
}

for (const warning of warnings) console.warn(`WARN  ${warning}`);
for (const error of errors) console.error(`ERROR ${error}`);

console.log(`Revisados ${files.length} HTML y ${styleFiles.length} CSS en todo el árbol: ${errors.length} error(es), ${warnings.length} advertencia(s).`);
process.exit(errors.length ? 1 : 0);

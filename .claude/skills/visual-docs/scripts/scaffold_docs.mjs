#!/usr/bin/env node

import { cpSync, existsSync, mkdirSync, readdirSync, statSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const targetArg = process.argv[2];

if (!targetArg || targetArg === "--help" || targetArg === "-h") {
  console.log("Uso: node scripts/scaffold_docs.mjs <directorio-destino>");
  console.log("Copia la plantilla documental únicamente si el destino no existe o está vacío.");
  process.exit(targetArg ? 0 : 1);
}

const scriptDir = dirname(fileURLToPath(import.meta.url));
const sourceDir = resolve(scriptDir, "../assets/starter");
const targetDir = resolve(process.cwd(), targetArg);

if (!existsSync(sourceDir) || !statSync(sourceDir).isDirectory()) {
  console.error(`ERROR: no existe la plantilla: ${sourceDir}`);
  process.exit(1);
}

if (existsSync(targetDir) && readdirSync(targetDir).length > 0) {
  console.error(`ERROR: el destino no está vacío; no se sobrescribió nada: ${targetDir}`);
  process.exit(1);
}

mkdirSync(targetDir, { recursive: true });
for (const entry of readdirSync(sourceDir)) {
  cpSync(resolve(sourceDir, entry), resolve(targetDir, entry), {
    recursive: true,
    errorOnExist: true,
    force: false,
  });
}

console.log(`Plantilla documental copiada en: ${targetDir}`);
console.log("Siguiente paso: reemplazar el contenido de ejemplo usando las fuentes del proyecto.");

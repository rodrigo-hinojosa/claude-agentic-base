#!/usr/bin/env node

import { readdirSync } from "node:fs";
import { dirname } from "node:path";
import { fileURLToPath } from "node:url";

// Las suites se descubren, no se enumeran. Una lista escrita a mano deja fuera
// en silencio a la suite nueva que alguien olvide agregar, y el arnés informa
// igual "N/N aprobadas": el resultado limpio es indistinguible del no ejecutado.
const suites = readdirSync(dirname(fileURLToPath(import.meta.url)))
  .filter((name) => name.endsWith(".test.mjs"))
  .sort();

if (suites.length === 0) {
  console.error("ERROR: no se encontró ninguna suite *.test.mjs junto a este arnés.");
  process.exit(2);
}

let failures = 0;

for (const suite of suites) {
  try {
    const module = await import(`./${suite}`);
    await module.run();
    console.log(`PASS ${suite}`);
  } catch (error) {
    failures += 1;
    console.error(`FAIL ${suite}`);
    console.error(error.stack || error.message || error);
  }
}

console.log(`${suites.length - failures}/${suites.length} suites aprobadas.`);
process.exitCode = failures ? 1 : 0;

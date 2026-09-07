import { createHash } from "node:crypto";
import {
  existsSync,
  mkdtempSync,
  readdirSync,
  readFileSync,
  rmSync,
  statSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join, relative, resolve } from "node:path";

export function makeTempDirectory(prefix = "visual-docs-") {
  return mkdtempSync(join(tmpdir(), prefix));
}

export function removeTree(path) {
  if (existsSync(path)) rmSync(path, { force: true, recursive: true });
}

export function listRelativeFiles(root) {
  const files = [];

  function visit(directory) {
    for (const entry of readdirSync(directory, { withFileTypes: true })) {
      const path = join(directory, entry.name);
      if (entry.isDirectory()) visit(path);
      else if (entry.isFile()) files.push(relative(root, path));
    }
  }

  if (existsSync(root)) visit(root);
  return files.sort();
}

export function hashTree(root) {
  return listRelativeFiles(root).map((file) => {
    const path = resolve(root, file);
    const hash = createHash("sha256").update(readFileSync(path)).digest("hex");
    return {
      file,
      hash,
      size: statSync(path).size,
    };
  });
}

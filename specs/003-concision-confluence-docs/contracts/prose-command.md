# Contrato 1 — Comando de prosa ampliado

Interfaz del script que `rules.md` publica en su bloque de código (hoy L68-93) y que `/speckit-implement` reemplaza por la implementación de referencia de §5. El comando es el único instrumento de conteo de la skill: lo que no mide queda en método Juicio (`rules.md` L57).

## 1. Entrada y preprocesamiento

| Paso | Qué hace | Cambio respecto del comando vigente |
| --- | --- | --- |
| Entrada | Ruta de un archivo Markdown, codificación UTF-8 | Sin cambio |
| Exclusión de bloques de código | Cada bloque ` ``` ... ``` ` se reemplaza por tantos saltos de línea como contenía | Antes se reemplazaba por vacío; ahora conserva el conteo de líneas |
| Exclusión de comentarios HTML | Cada `<!-- ... -->` se reemplaza igual | Nueva (D10): la cabecera de un fixture es clave de respuestas, no prosa |
| Filtro estructural | Encabezados, tablas, citas, listas y numeraciones no son párrafos | Sin cambio |
| Oraciones | Corte en `.`, `!`, `?` seguidos de espacio, tras quitar marcas de formato | Sin cambio |

## 2. Métricas y salida

Salida en texto plano, una línea por métrica, en este orden y con estas etiquetas. La regla 33 agrega una línea de ubicación por coincidencia.

```text
R26 parrafos de 5 o mas    : <n> de <N> = <p>%
R27 oraciones de 30+ pal   : <n> de <N> = <p>%
R28 negrita larga /1000 pal: <x.x>
R29 guiones inciso /1000   : <x.x>
R29 parrafos con 2+ incisos: <n>
R33 muletillas (lista)     : <k>
  L<linea>: <frase encontrada>
```

Se retira la línea `R26 parrafos de 1 oracion` (FR-007, D3). Las demás métricas conservan su definición; las cifras por mil palabras cambian de denominador en archivos con cabecera HTML, porque la cabecera deja de contar como texto.

`L<linea>` es la línea del archivo original, porque las exclusiones conservan los saltos de línea. Una muletilla dentro de una viñeta o un encabezado también se publica: la lista se aplica línea a línea sobre el texto ya filtrado de código y comentarios.

## 3. Lista cerrada de la regla 33

Vive únicamente dentro del bloque de código del comando, como la lista `MULETILLAS` de §5. Ningún archivo de la skill la reproduce en prosa; `rules.md` la describe por su función ("muletillas de apertura y transición") y remite al comando.

| Grupo | Qué cubre | Patrones |
| --- | --- | --- |
| Autodescripción del documento | El documento se presenta a sí mismo en vez de entrar en materia | 4 |
| Autodescripción de la sección | La sección anuncia lo que va a decir | 3 |
| Transición de anuncio | Frase que anuncia importancia o repite lo dicho | 5 |

Doce patrones, insensibles a mayúsculas, tolerantes a la ausencia de tilde. La lista es corta a propósito (edge case "Coincidencia legítima"): un detector que grita siempre se ignora.

**Qué no detecta, y por qué**:

- Remates de cierre ("en resumen", "en conclusión"): son la regla 32 (media, Juicio). Una frase pertenece a una sola regla.
- Genérico sin dato ("buenas prácticas", "se recomienda"): es la regla 10 ampliada (alta, Juicio); no se detecta por regex.
- La primera oración que repite el encabezado sin frase de la lista: criterio de Juicio de la propia 33 (D6).
- Conectores de contraste ("por otro lado", "asimismo"): legítimos en un contraste real; excluidos para no producir falsos positivos.

## 4. Garantía de no autodetección

- La lista está dentro del bloque ` ```bash ... ``` ` del comando; el comando reemplaza ese bloque por líneas vacías antes de medir.
- Las cabeceras HTML de los fixtures pueden citar frases de la lista (para nombrar un desvío sembrado); el comando también las excluye.
- La prosa de `rules.md`, `SKILL.md` y `templates.md` no cita ninguna frase de la lista. Estado verificado el 15-09-2026 sobre `main`: cero coincidencias en los tres (§6).
- Prueba realizada el 15-09-2026 sobre un archivo sintético con la frase de apertura dentro de un bloque de código y dentro de un comentario HTML: `R33 muletillas (lista): 0`.

## 5. Implementación de referencia

Es el bloque que reemplaza a `rules.md` L68-93, con su envoltorio `bash` intacto. Verificada el 15-09-2026 sobre los ocho archivos de la skill (§6).

```bash
f=<archivo a medir>
python3 - "$f" << 'PY'
import re, sys
raw = open(sys.argv[1], encoding="utf-8").read()
def _blank(m): return "\n" * m.group(0).count("\n")
t = re.sub(r"```.*?```", _blank, raw, flags=re.S)
t = re.sub(r"<!--.*?-->", _blank, t, flags=re.S)
def _estructural(b):
    if b.startswith(("#","|",">")): return True
    if re.match(r"^\d+\.\s", b): return True
    if re.match(r"^[-*+]\s", b): return True
    return False
p = [b.strip() for b in t.split("\n\n") if b.strip() and not _estructural(b.strip())]
blob = "\n\n".join(p); w = max(len(re.findall(r"\w+", blob)), 1) / 1000
def orac(b):
    c = re.sub(r"[`*_\[\]()]", "", b)
    return [s for s in re.split(r"(?<=[.!?])\s+", c) if re.findall(r"\w+", s)]
todas = [s for b in p for s in orac(b)]
n5 = sum(1 for b in p if len(orac(b)) >= 5)
lar = sum(1 for s in todas if len(re.findall(r"\w+", s)) > 30)
MULETILLAS = [
    r"este documento (explica|describe|presenta|detalla|tiene como (objetivo|prop[oó]sito))",
    r"el presente documento",
    r"en este documento",
    r"el objetivo (de este|del presente) documento",
    r"esta secci[oó]n (describe|explica|presenta|detalla)",
    r"en esta secci[oó]n",
    r"a continuaci[oó]n,? se (describe|presenta|detalla|muestra|explica)",
    r"es importante (se[ñn]alar|destacar|mencionar|notar|recordar)",
    r"cabe (destacar|se[ñn]alar|mencionar|recordar)",
    r"vale la pena (mencionar|destacar|se[ñn]alar)",
    r"como (ya )?se (mencion[oó]|dijo|indic[oó]|se[ñn]al[oó])",
    r"en este sentido",
]
hits = [(i, m.group(0)) for i, line in enumerate(t.split("\n"), 1)
        for pat in MULETILLAS for m in re.finditer(pat, line, flags=re.I)]
print(f"R26 parrafos de 5 o mas    : {n5} de {len(p)} = {100*n5//max(len(p),1)}%")
print(f"R27 oraciones de 30+ pal   : {lar} de {len(todas)} = {100*lar//max(len(todas),1)}%")
print(f"R28 negrita larga /1000 pal: {len([m for m in re.findall(r'[*][*]([^*]+)[*][*]', blob) if len(m) >= 60])/w:.1f}")
print(f"R29 guiones inciso /1000   : {blob.count(chr(8212))/w:.1f}")
print(f"R29 parrafos con 2+ incisos: {sum(1 for b in p if b.count(chr(8212)) >= 3)}")
print(f"R33 muletillas (lista)     : {len(hits)}")
for ln, frase in hits:
    print(f"  L{ln}: {frase}")
PY
```

## 6. Salida observada antes de implementar (15-09-2026, rama `main` en `560225a`)

Sirve de línea de partida para el quickstart; las cabeceras de los fixtures citarán la salida posterior a su re-clavado, no esta.

| Archivo | R26 5+ | R27 | R28 | R29 guiones / párrafos | R33 |
| --- | --- | --- | --- | --- | --- |
| `examples/prose-conforming.md` | 0 de 6 | 0 de 13 | 0.0 | 0.0 / 0 | 0 |
| `examples/prose-with-seeded-flaws.md` | 0 de 9 | 1 de 12 | 4.7 | 18.6 / 1 | 0 |
| `examples/structured-doc.md` | 0 de 15 | 3 de 24 | 0.0 | 0.0 / 0 | 0 |
| `examples/compliant-adr.md` | 0 de 6 | 0 de 11 | 0.0 | 6.3 / 0 | 0 |
| `examples/seeded-violations.md` | 0 de 5 | 1 de 8 | 0.0 | 0.0 / 0 | 1 (L18) |
| `rules.md` | 3 de 15 | 4 de 51 | 0.0 | 9.0 / 1 | 0 |
| `SKILL.md` | 3 de 30 | 8 de 88 | 0.7 | 8.2 / 1 | 0 |
| `templates.md` | 0 de 20 | 0 de 21 | 0.0 | 3.4 / 0 | 0 |

Tres lecturas para implement:

- `prose-with-seeded-flaws.md` reporta `R26 5+ = 0`: el desvío R26 nuevo hay que sembrarlo (D14).
- `prose-conforming.md` ya cumple por comando la regla 26 nueva y la 33; su cambio es solo la cabecera y la autodescripción del cuerpo.
- Las cifras R27 de `rules.md` y `SKILL.md` son previas a esta feature y no son criterio de cierre (SC-007 exige cero muletillas, no R27 cero); la línea base sigue `Pendiente de recomputar`.

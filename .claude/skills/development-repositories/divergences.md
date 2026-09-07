# Divergencias entre el catálogo y la fuente

> **Este archivo no tiene campo de resolución, y no es un olvido.** Registrar una diferencia
> entre el catálogo y la fuente es un acto; decidir qué hacer con ella es otro, y el
> segundo pertenece a una persona.
>
> **El modo sincronizar no escribe acá.** Emite su reporte y se detiene. Registrar una
> divergencia es una operación aparte, con confirmación explícita, y no es lo mismo que
> aplicar el cambio al catálogo.

Registra en qué difieren [`repositories.md`](repositories.md) y la sección fuente de Confluence (URL `Pendiente de configurar` por proyecto), con el relevamiento que encontró cada diferencia. Es traza versionada del repositorio: consultarlo nunca abre Confluence. La forma de este archivo proviene de la portación trazada en [`specs/002-portar-agentes/`](../../../specs/002-portar-agentes/).

## Estado

| Campo | Valor |
| --- | --- |
| Divergencias registradas | **0** |
| Última derivación | **Ninguna**: no hay entradas que fechar |
| Relevamientos contrastados | `ninguno` |
| Alcance del contraste | **Sin alcance**: no se ha comparado ni campos ni presencia |

**El cero de arriba no dice que catálogo y fuente coincidan.** Dice que nunca se corrió un contraste. Las dos situaciones producen la misma tabla vacía, y la fila de relevamientos contrastados es lo único que las separa.

### Por qué no hay contraste

**El historial de divergencias arranca en esta base.** Este archivo es réplica declarada de la portación, 07-09-2026 (feature `002-portar-agentes`): se portó el mecanismo de registro, no la historia — las entradas del workspace de origen no viajan con la plantilla. Además, la fuente de este proyecto está `Pendiente de configurar`; un contraste exige leerla, y esa lectura no puede ocurrir antes de configurarla.

**La primera corrida del modo sincronizar con conector disponible y fuente configurada es la que puede poblar este archivo.** Hasta entonces, cualquier afirmación sobre coincidencia entre catálogo y fuente sería una suposición.

---

## 1. Divergencias vigentes

| `DIV-nn` | Repositorio | Campo | Valor en el catálogo | Valor en la fuente | Detectada | Relevamiento |
| --- | --- | --- | --- | --- | --- | --- |

**Tabla vacía por ausencia de contraste**, no por resultado limpio de uno.

---

## 2. Divergencias que la fuente ya no presenta

| `DIV-nn` | Repositorio | Campo | Valor en el catálogo | Valor en la fuente | Detectada | Relevamiento | Verificada ausente en |
| --- | --- | --- | --- | --- | --- | --- | --- |

Acá se mueve una entrada cuando un contraste posterior ya no la encuentra, con el relevamiento que lo comprueba. **Mover no es resolver**: esta tabla registra qué vio una lectura, no qué decidió alguien.

**El identificador viaja con la entrada.** `DIV-04` movida sigue siendo `DIV-04`, y su número no vuelve al pozo.

---

## 3. Quién puebla este archivo

Tres actos distintos, que la skill nombra por separado porque tienen dueño, efecto y gate propios.

| Acto | Quién | Qué toca | Gate |
| --- | --- | --- | --- |
| **Contrastar** | Modo sincronizar | Nada. Emite su reporte de sincronización | Ninguno: es lectura |
| **Registrar** | Operación aparte | Este archivo | Confirmación explícita, por escritura |
| **Aplicar** | Operación aparte | [`repositories.md`](repositories.md) y [`provenance.md`](provenance.md) | Confirmación explícita, con relevamiento nuevo |

**El modo sincronizar contrasta y se detiene.** Emite su reporte y no escribe una línea acá, porque escribir la divergencia ya modifica el repositorio, y su contrato le prohíbe aplicar cambios: reporta sin aplicar.

**Registrar no es aplicar.** Dejar escrito que catálogo y fuente difieren no decide cuál gana. Llevar el valor de la fuente al catálogo sí lo decide, y exige su propio relevamiento porque cambia un dato con procedencia.

---

## 4. Vocabulario de las dos columnas de valor

| Valor | Significa |
| --- | --- |
| El texto literal | Ese lado tiene el dato y dice eso |
| `vacío` | El campo existe en ese lado y viene sin contenido |
| `ausente` | La fila entera no está en ese lado |

**`vacío` y `ausente` no se intercambian.** Un campo sin contenido en la fuente es un hecho registrable del catálogo; una fila que no existe es otra cosa. Este archivo fija esta separación aunque el reporte del modo sincronizar admita "ausente" para ambos casos.

Ambos valores se escriben siempre. Un lado en blanco no permite distinguir si no había dato o si nadie lo miró.

---

## 5. Reglas de escritura de una entrada

1. **Sin campo de resolución**, bajo ningún nombre: ni `estado`, ni `acción`, ni `decidido`.
2. **El correlativo arranca en `DIV-01`** y avanza de uno en uno, sin saltos ni reutilización.
3. **Una entrada nunca se borra ni se renumera**: se mueve a la sección 2 con su relevamiento.
4. **Toda divergencia cita el relevamiento que la detectó.** Sin él es una diferencia recordada.
5. **`Repositorio` queda vacío solo en divergencia de conjunto**, y ahí `Campo` toma el valor `presencia`.
6. **Una diferencia de forma del nombre del owner no es divergencia.** Sí lo es que la fuente nombre a alguien que no resuelve a ninguna persona del registro de equipo del proyecto (la skill de dominio que el proyecto defina — `Pendiente de configurar`).
7. **No se escriben credenciales, tokens, URLs autenticadas ni atributos de personas.** Un owner se nombra por puntero, como lo hace el catálogo.
8. Una entrada que necesite explicación agrega debajo una sección `## DIV-nn · <título>`. Esa sección es opcional; la fila de la tabla no.

---

## 6. Verificación

El recuento de la sección de estado se rehace, no se recuerda:

```bash
grep -cE '^\| `DIV-[0-9]{2}`' .claude/skills/development-repositories/divergences.md
```

**El comando cuenta las dos tablas**, de modo que devuelve el total de identificadores emitidos, no el de divergencias vigentes. Separar unas de otras exige acotar el rango de líneas a la sección 1, y eso el comando no lo resuelve: es lectura.

Al 07-09-2026 —inicio del historial en esta base— el comando devuelve `0`, que es coherente con la ausencia de contraste declarada arriba.

---

## Referencias

- Diseño y procedencia de la portación: [`specs/002-portar-agentes/`](../../../specs/002-portar-agentes/), con el contrato de interfaces en [`contracts/interfaces.md`](../../../specs/002-portar-agentes/contracts/interfaces.md).
- Catálogo contrastado: [`repositories.md`](repositories.md).
- Procedencia de sus datos: [`provenance.md`](provenance.md).
- Vacío declarado: los contratos de forma del workspace de origen (el del archivo de divergencias y el del reporte de sincronización) no se portaron como archivos. En esta base, la forma vigente de las entradas es la que este archivo declara en sus secciones 4 y 5.

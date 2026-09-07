> **Entrada de prueba del parser del modo sincronizar.** No es la fuente, no es el catálogo, y ninguna consulta lo mira.
>
> Existe porque **la skill no escribe en Confluence**: sembrar una fila en la sección fuente para probar el modo es imposible por diseño, y sin este archivo la prueba del parser del modo sincronizar no sería ejecutable.

# Entrada de prueba — tabla de la sección fuente con una fila sembrada

| Campo | Valor |
| --- | --- |
| Naturaleza | Fixture de prueba del parser |
| Qué NO es | La fuente, ni el catálogo, ni una réplica consultable |
| Reproduce | La forma de la tabla de la sección fuente, no su contenido vigente |
| Origen | Réplica declarada de la portación, 07-09-2026 (feature `002-portar-agentes`) |
| Traza | `specs/002-portar-agentes/` |

## 1. Qué está sembrado, y qué no

**Once de las doce filas siguen la composición de referencia** observada en el workspace de origen: ocho con repositorio y cuatro sin él. Los nombres de componentes, repositorios y owners de esta tabla son **sintéticos**: no describen ningún proyecto real.

**La fila doce está sembrada**: `Validador de RUT duplicado`, que en la composición de referencia dice `Sin repositorio` y estado `Por definir`, aparece acá **con un repositorio**. Es el único evento que exige recorrer la tabla desde la fuente y no desde el catálogo, y por eso es lo que este fixture existe para provocar.

> **Este archivo no describe el estado de ninguna fuente real.** Quien lo lea como si describiera la sección fuente de su proyecto se estará llevando un dato falso.

## 2. La tabla

| Componente | Repositorio | Stack | Propósito | Estado | Owner |
| --- | --- | --- | --- | --- | --- |
| Frontend / Login UI | ejemplo-frontend | Web Application - ReactJS | Frontend web de login, registro y recuperación | Activo | Equipo frontend |
| Backend / API | ejemplo-backend | Api - Go | API que orquesta la integración con el proveedor de identidad y el ecosistema | Activo | Equipo backend |
| QA automation | ejemplo-qa | Test Repo | Repositorio base de QA | Activo | Equipo QA |
| QA automation | ejemplo-qa-performance-tests | Test Repo | Pruebas de rendimiento y carga | Activo | Equipo QA |
| QA automation | ejemplo-qa-e2e-app-tests | Test Repo | Pruebas E2E de la aplicación | Activo | Equipo QA |
| QA automation | ejemplo-qa-e2e-web-tests | Test Repo | Pruebas E2E web | Activo | Equipo QA |
| QA automation | ejemplo-qa-api-tests | Test Repo | Pruebas de API | Activo | Equipo QA |
| QA automation | ejemplo-qa-contract-tests | Test Repo | Pruebas de contrato | Activo | Equipo QA |
| Configuración del proveedor de identidad | Sin repositorio | | Configuración de flujos, políticas, MFA, risk y proofing | Por confirmar | Proveedor externo |
| Integración con el maestro de clientes | Sin repositorio | | Integración post-auth con el maestro de clientes | Por definir | Equipo de datos / Arquitectura |
| Observabilidad | Sin repositorio | | Dashboards, logs, métricas y alertas | Por definir | SRE |
| Validador de RUT duplicado | ejemplo-validador-rut | Api - Go | Servicio propio para detectar duplicidad y disparar prueba de vida | Activo | Equipo backend |

## 3. Qué debe reportar el modo contra esta entrada

| Fila | En la fuente | En el catálogo | Resultado esperado |
| --- | --- | --- | --- |
| Las ocho con repositorio | Presente | Presente | Contraste campo a campo, sin divergencias |
| Las tres `Sin repositorio` | Sin repositorio | Ausente | Correcto: no es un repositorio y no entra al catálogo |
| `Validador de RUT duplicado` | **Con repositorio** | Ausente | **Divergencia de presencia**: celda `Repositorio` vacía, `Campo` = `presencia`, valor del catálogo `ausente`, valor de la fuente `ejemplo-validador-rut` |

**Un modo que recorriera el catálogo en vez de la fuente pasaría esta prueba en silencio**, sin reportar nada, y su salida se vería idéntica a "sin divergencias". Ese es el fallo que este fixture detecta y ninguna otra verificación de la skill alcanza.

## 4. Cómo se usa

El modo sincronizar lee la fuente con `getConfluencePage`. Para ejercitar **el parser** sin conector, se le entrega este archivo como cuerpo de la página en vez de la respuesta de la herramienta, y se comprueba el reporte contra la tabla de §3.

**Lo que esta prueba NO cubre**, y va dicho para que nadie la lea como cobertura completa:

- **La lectura en vivo**, incluida la resolución del número de versión con `searchConfluenceUsingCql`. El encabezado del reporte que salga de acá no trae versión real.
- **El tercer resultado** (`No se pudo contrastar`), que exige un conector caído y no un archivo.
- **La localización de la tabla por encabezados dentro de una página completa**: este archivo trae la tabla aislada, no el cuerpo entero de la página fuente con sus otras secciones.

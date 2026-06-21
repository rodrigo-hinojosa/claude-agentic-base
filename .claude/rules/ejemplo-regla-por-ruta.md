---
paths:
  - "src/api/**/*.{ts,js}"
---

# Reglas de desarrollo de API

<!--
Ejemplo de regla con alcance de ruta. Solo se carga en contexto cuando Claude trabaja
con archivos que coinciden con los patrones `paths` de arriba.
Ajusta los patrones y el contenido a tu proyecto, o elimina este archivo si no aplica.
Las reglas SIN campo `paths` se cargan siempre, igual que .claude/CLAUDE.md.
-->

- Todos los endpoints deben validar la entrada antes de procesarla.
- Usa el formato de respuesta de error estándar del proyecto.
- Documenta los endpoints públicos (OpenAPI / comentarios según convención).
- No registres datos sensibles en logs de request/response.

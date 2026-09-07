# Seguridad y secretos

<!-- Las reglas duras de bloqueo viven en settings.json (permissions.deny). Esto es la guía de conducta. -->

## Secretos y credenciales

- Nunca leas, muestres, registres ni copies contenido de archivos de secretos: `.env`, `*.pem`, `*.key`, `credentials`, `id_rsa`, `~/.ssh`, `~/.aws/credentials`.
- Nunca hardcodees credenciales, tokens, API keys ni contraseñas en código, ejemplos, documentación o commits. Usa variables de entorno o gestores de secretos.
- Si necesitas un valor sensible para una tarea, indica cómo proveerlo de forma segura; no lo solicites en texto plano ni lo escribas en el repo.
- Si detectas un secreto expuesto en el código, avísalo de inmediato y propón rotación y remediación.

## Acciones destructivas e irreversibles

- Confirma antes de: borrar archivos o datos, force push, reset duro, drop de tablas, borrado de recursos cloud, o cualquier operación sin retorno.
- Para operaciones de base de datos en entornos reales, prefiere consultas de solo lectura salvo instrucción explícita.
- No ejecutes comandos que descarguen y ejecuten contenido remoto sin revisión.

## Datos sensibles en la salida

- No incluyas datos personales, financieros ni de identificación en URLs, logs ni ejemplos.
- No compiles información personal entre fuentes sin necesidad clara.

## Buenas prácticas de código seguro

- Valida y sanitiza entradas; nunca confíes en datos externos.
- Usa consultas parametrizadas; evita concatenar SQL.
- Señala vulnerabilidades cuando las veas (inyección, manejo de errores que filtra info, dependencias con CVE conocidos).
- Aplica el principio de menor privilegio en permisos, tokens y accesos.

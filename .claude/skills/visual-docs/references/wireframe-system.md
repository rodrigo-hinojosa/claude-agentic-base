# Sistema de wireframes

## Propósito

Los wireframes representan decisiones y estados de experiencia dentro de una documentación técnica. No intentan parecer producto final. Usa wireframes solo cuando ayudan a revisar entrada, acción, feedback, error, recuperación o información visible.

## Firma visual

- Fondo blanco, borde gris y sin color de marca.
- Barra de estado gris y appbar construida con bloques neutros.
- Ancho base de pantalla móvil: 326 px.
- Alto mínimo del contenido: 520 px.
- Etiqueta `LOW-FI` visible sobre cada pantalla.
- Pie interno: `Ejemplo conceptual · UI y copy por validar`.
- Botón primario negro; secundarios blancos con borde oscuro.
- Iconos representados como bloques grises simples, no iconografía final.
- Conectores horizontales grises entre casos.

## Anatomía de un caso

Cada `.screen-case` contiene:

1. `.screen-label`: número, nombre del estado y explicación corta;
2. `.device`: status bar, appbar y body;
3. controles conceptuales: campos, cards, OTP, listas, notas y acciones;
4. `.system-rail`: efecto técnico de esa pantalla.

## Capa sistémica

Cuando el wireframe forma parte de una revisión técnica, agrega debajo:

- sistemas participantes;
- request, comando o evento relevante;
- escritura o cambio de estado;
- condición de seguridad, fallo o idempotencia.

Usa tres hops como base, pero adapta la cantidad al flujo real. La capa sistémica no debe inventar APIs: si el contrato no está definido, usa una descripción conceptual y márcala como propuesta.

## Cobertura de flujo

Incluye:

- punto de entrada real;
- camino principal completo;
- decisión que cambia el resultado;
- error recuperable;
- cancelación o salida segura cuando sea relevante;
- confirmación final.

Separa los flujos alternativos bajo el principal cuando demasiadas ramas vuelven ilegible la línea horizontal.

## Copy y datos

- Usa texto breve y concreto para que se entienda la intención de la pantalla.
- Enmascara emails, teléfonos e identificadores.
- No muestres secretos, tokens ni valores sensibles en URLs o mensajes.
- Marca explícitamente copy, interacción o método pendiente de validación.
- Mantén consistencia de persona, cuenta y estado entre pantallas.

## Responsive e impresión

El wireflow conserva ancho fijo y habilita desplazamiento horizontal. En impresión puede transformarse en grid de dos columnas y ocultar conectores. Nunca comprimas todos los dispositivos hasta hacer ilegible el copy.

# Ejemplo — Tarea conforme al estándar de gestión

Referencia del modo redactar. Cumple la plantilla estándar de trabajo de gestión de [`../SKILL.md`](../SKILL.md) §2: título en infinitivo sin prefijo de clave, cinco secciones en orden, "Próximos pasos" como checklist, labels declaradas, sin criterios de aceptación ni estimación (omisión declarada de la plantilla de gestión). Datos sintéticos.

> **Es un fixture, no una transcripción**: nada de acá ocurrió en un tablero real, así que no tiene cifras que caduquen. Lo que sí puede caducar es su **conformidad**, si cambia el estándar al que dice ajustarse.
>
> **Contrastado contra `SKILL.md` §2 el 06-09-2026.**

---

**Título**: Configurar el tenant de QA para las pruebas de login del proyecto

**Tipo**: Tarea — es trabajo de ejecución que se cierra al completarse; no es una funcionalidad de usuario planificada para backlog.

**Labels**: `qa`, `ambientes`

## Objetivo

Dejar operativo un tenant de QA aislado para ejecutar las pruebas de login sin tocar datos de otros ambientes.

## Contexto

Las pruebas de login se están corriendo sobre un ambiente compartido, lo que produce colisiones de estado entre corridas. Se necesita un tenant dedicado a QA con la configuración mínima de autenticación.

## Alcance

Incluye la creación del tenant de QA y la carga de la configuración base de autenticación. No incluye la integración con los frontales ni datos de clientes reales; los datos de prueba son sintéticos.

## Entregable

Tenant de QA accesible por el equipo de pruebas, con la configuración base cargada y documentada su URL de acceso en la página de ambientes.

## Próximos pasos

- [ ] Solicitar el tenant de QA al equipo de plataforma
- [ ] Cargar la configuración base de autenticación
- [ ] Verificar un login de extremo a extremo con un usuario sintético
- [ ] Registrar la URL de acceso en la página de ambientes de la documentación

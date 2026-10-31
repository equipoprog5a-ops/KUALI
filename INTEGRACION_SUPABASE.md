# KUALI — Integración inicial con Supabase

La aplicación quedó configurada con la Project URL y la Publishable Key proporcionadas para el proyecto KUALI. La URL se normalizó a la raíz del proyecto (`https://insfdzgasczqdrdalely.supabase.co`); no debe incluir `/rest/v1/`.

## Funciones conectadas en esta entrega

- Cliente Supabase JS v2 y persistencia de sesión.
- Registro/inicio de sesión existentes y carga del perfil autenticado.
- Lectura de perfil, solicitudes propias, publicaciones, comentarios, reacciones, favoritos de servicios, inscripciones, confirmaciones de eventos, notificaciones y perfil de proveedor.
- Guardado de perfiles, solicitudes, publicaciones, comentarios, reacciones, favoritos de servicios, cancelación de solicitudes, inscripciones, interés en eventos, borradores de proveedor y comentarios de soporte.
- Los usuarios visitantes pueden explorar, pero deben iniciar sesión para guardar acciones compartidas.

## Antes de publicar

1. Confirma que ejecutaste `supabase/schema.sql` en ESTE proyecto Supabase.
2. En Authentication → URL Configuration agrega `https://equipoprog5a-ops.github.io/KUALI/` como Site URL y `https://equipoprog5a-ops.github.io/KUALI/**` como Redirect URL.
3. Verifica que RLS siga activado y que el SQL se haya ejecutado sin errores.
4. En `courses` y `community_events`, los IDs usados por la interfaz deben existir y estar publicados (`is_published = true`) para que inscripciones/RSVP funcionen.
5. Carga puntos de servicio publicados en `service_points`; los perfiles de proveedor se guardan como borrador y requieren revisión administrativa antes de publicar.
6. Prueba con dos cuentas distintas: una no debe poder consultar solicitudes ni perfiles privados de la otra.
7. Revisa Security Advisor y políticas RLS antes de usar datos reales.

## Funciones que aún requieren una fase adicional

- Notificaciones automáticas para todos los eventos del sistema (en esta versión las existentes se consultan, pero varias notificaciones de interfaz siguen siendo locales).
- Edición y moderación administrativa de cursos, eventos, puntos y proveedores.
- Carga dinámica del catálogo de cursos/eventos/puntos desde sus tablas: el contenido de muestra del front-end aún se conserva.
- Sincronización/migración de los datos locales antiguos de cada navegador a las nuevas tablas.

La clave incluida es una Publishable Key diseñada para el navegador. No agregues claves `sb_secret_`, `service_role` ni contraseñas al HTML.

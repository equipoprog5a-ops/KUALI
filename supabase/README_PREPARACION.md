# KUALI — preparación de Supabase

## Antes de ejecutar

- Crea un proyecto Supabase dedicado a KUALI.
- Si ya tienes datos en ese proyecto, crea antes un respaldo y no ejecutes scripts sin revisar lo que cambiarán.
- El archivo `supabase/schema.sql` crea las tablas que falten, activa Row Level Security (RLS), ajusta permisos y crea políticas. No elimina tablas ni registros. Sí reemplaza las políticas de KUALI que llevan esos nombres.

## Crear la base de datos

1. Entra a https://supabase.com/dashboard e inicia sesión.
2. Crea un proyecto nuevo y guarda la contraseña de la base de datos en un lugar seguro. No la compartas.
3. Abre el proyecto y entra en **SQL Editor**.
4. Selecciona **New query**.
5. Abre `supabase/schema.sql` con un editor de texto, copia todo su contenido y pégalo en SQL Editor.
6. Presiona **Run**. Si aparece un error, detente y conserva el mensaje completo; no lo intentes solucionar desactivando RLS.
7. Abre **Table Editor** y comprueba que existan las tablas `profiles`, `service_requests`, `community_posts`, `post_comments`, `post_likes`, `courses`, `course_enrollments`, `community_events`, `event_rsvps`, `service_points`, `provider_profiles`, `favorites`, `notifications` y `feedback`.
8. Abre **Authentication → URL Configuration** y, cuando vayas a conectar el sitio, agrega la URL de GitHub Pages de KUALI a las URL permitidas.

## Seguridad

- RLS debe permanecer activado. Las políticas y los permisos `GRANT` trabajan juntos.
- Nunca pongas una clave `sb_secret_...`, `service_role` ni la contraseña de la base de datos en `index.html`. El navegador solo debe usar la Project URL y la Publishable key.
- Los cursos, eventos, puntos de servicio y la publicación/verificación de proveedores deben cargarse desde el Dashboard o desde un entorno administrador confiable.
- Este SQL prepara las tablas y la seguridad; **no conecta automáticamente** los formularios de `index.html` con ellas. Esa integración será el siguiente paso.

## Pruebas posteriores

1. Verifica en Table Editor que las tablas se hayan creado.
2. Registra una cuenta de prueba desde la aplicación una vez configurada la autenticación; confirma que se genera una fila en `profiles`.
3. Prueba las políticas con dos cuentas de prueba y comprueba que no puedan leer solicitudes/perfiles privados ajenos.
4. Revisa los avisos de **Security Advisor** en Supabase antes de usar datos reales.

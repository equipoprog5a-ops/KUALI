# KUALI — preparación de Supabase

## Estado de este proyecto

El esquema `schema.sql` debe ejecutarse una sola vez en el proyecto dedicado a KUALI. La integración web de este paquete ya contiene la URL raíz y la Publishable key del proyecto nuevo `fwjaaxrwvcckyuabcrzb`.

## Esquema y tablas

`schema.sql` crea las 14 tablas de KUALI si no existen, activa Row Level Security (RLS), crea funciones y triggers y configura políticas y permisos. No elimina tablas ni registros; reemplaza las políticas de KUALI con los nombres que administra este esquema. Si el esquema ya se ejecutó y las 14 tablas aparecen en Table Editor, no hace falta volver a ejecutarlo.

## Authentication → URL Configuration

Configura el **Site URL** con la URL exacta de GitHub Pages para el repositorio nuevo y añade esa misma URL terminada en `/**` a **Redirect URLs**. La confirmación de correo vuelve a la dirección actual de la página.

## Seguridad

- Mantén RLS activado en todas las tablas.
- Nunca coloques una clave `sb_secret_...`, `service_role` ni la contraseña de base de datos en el front-end.
- La Publishable key se puede utilizar en el navegador, siempre que las políticas RLS limiten los permisos apropiadamente.
- Cursos, eventos, puntos de servicio, publicación/verificación de proveedores y notificaciones del sistema deben administrarse desde el Dashboard o un entorno confiable.

Consulta `../INTEGRACION_SUPABASE.md` para el estado de funciones conectadas, pendientes y pruebas recomendadas.

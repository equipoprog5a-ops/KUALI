# KUALI — Aplicación web

KUALI es una aplicación web adaptable a computadora y celular para explorar servicios, registrar solicitudes, compartir conocimientos y consultar actividades comunitarias.

## Funciones incluidas

- Panel de inicio y navegación adaptable.
- Búsqueda y filtros de servicios.
- Registro local de solicitudes, detalle, seguimiento y cancelación de solicitudes pendientes.
- Perfil local para ofrecer servicios.
- Comunidad con publicaciones, categorías, reacciones y comentarios.
- Catálogo de cursos, registro local de interés y favoritos.
- Eventos con registro local de interés.
- Directorio de puntos informativos y perfiles guardados.
- Perfil personal, notificaciones, ayuda, formulario de comentarios y tema claro/oscuro.
- Validación de campos y mensajes para guiar al usuario.

## Cómo probarla

1. Descomprime el paquete completo.
2. Conserva `index.html`, `assets/` y `supabase/` en sus ubicaciones originales.
3. Abre `index.html` en Chrome, Edge o Firefox.
4. Prueba las secciones en escritorio y en una pantalla móvil.

## Publicación en GitHub Pages

1. Abre el repositorio de KUALI.
2. Sube o reemplaza `index.html` y las carpetas `assets/` y `supabase/`, sin cambiar sus nombres ni rutas.
3. Confirma que GitHub Pages esté configurado para publicar desde la rama y carpeta correctas.
4. Abre la URL publicada y prueba nuevamente los flujos principales.

## Importante antes de usarla con personas reales

Esta versión es interactiva, pero todavía no es un servicio de producción conectado de extremo a extremo. Las solicitudes, publicaciones, comentarios, reacciones, favoritos, preferencias, perfiles, inscripciones de interés y comentarios de ayuda se guardan principalmente en el almacenamiento local del navegador. No se comparten entre dispositivos ni se envían automáticamente a técnicos u organizadores.

Los cursos, fechas, cupos, eventos y puntos del directorio son datos de muestra. Antes de anunciarlos públicamente, reemplázalos por información real y autorizada. Añade también un aviso de privacidad y condiciones de uso, y define quién moderará las publicaciones y verificará a quienes ofrezcan servicios.

## Autenticación con Supabase

En `index.html` encontrarás los valores de configuración:

```js
const SUPABASE_URL = "https://TU-PROYECTO.supabase.co";
const SUPABASE_PUBLISHABLE_KEY = "sb_publishable_PEGA_AQUI_TU_CLAVE";
```

1. Crea un proyecto en Supabase.
2. Obtén la Project URL y la Publishable key desde el panel del proyecto.
3. Reemplaza los valores de ejemplo en `index.html`.
4. Configura las URL permitidas de autenticación para tu sitio de GitHub Pages.
5. Revisa `supabase/schema.sql` y adapta las tablas y políticas de Row Level Security antes de almacenar datos reales.
6. Prueba registro, confirmación de correo, inicio y cierre de sesión, acceso a datos y permisos.

**No incluyas una clave `sb_secret_...` ni una clave `service_role` en HTML o JavaScript del navegador.** Usa únicamente la clave pública apropiada y políticas de seguridad correctas.

Configurar autenticación no conecta automáticamente solicitudes, publicaciones, perfiles, favoritos ni inscripciones a tablas remotas. Esa integración de datos todavía debe desarrollarse y probarse por separado.

## Lista de verificación previa a lanzamiento

- [ ] Sustituir los cursos, eventos, cupos y fechas de ejemplo por información verificada.
- [ ] Confirmar los puntos de servicio y los datos de contacto, o retirar los que no existan.
- [ ] Decidir si se publicará solo como demostración o como servicio real.
- [ ] Si se requieren cuentas, configurar y probar Supabase.
- [ ] Si se compartirán datos, conectar cada módulo a la base de datos y probar permisos de lectura/escritura.
- [ ] Publicar aviso de privacidad y condiciones de uso.
- [ ] Probar formularios, búsqueda, favoritos, comentarios, modo oscuro y navegación móvil.
- [ ] Probar la URL pública en un navegador distinto y en un celular.


## Preparación de la base de datos

Consulta `supabase/README_PREPARACION.md` para configurar Supabase paso a paso. Ejecuta `supabase/schema.sql` en un proyecto dedicado a KUALI. Esto prepara tablas y seguridad; conectar los formularios y vistas del navegador con estas tablas es una fase posterior.

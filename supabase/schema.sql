-- KUALI — esquema inicial seguro para Supabase/PostgreSQL.
-- Ejecutar en un proyecto Supabase dedicado a KUALI, desde SQL Editor.
-- Crea tablas si no existen, (re)crea funciones/políticas y ajusta permisos solo en estas tablas.
-- No elimina tablas ni registros. Antes de usar un proyecto existente, haz respaldo.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  phone text,
  zone text,
  about text,
  interests text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.service_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  code text not null unique,
  service_id text not null,
  service_name text not null,
  contact_name text not null,
  contact_value text not null,
  zone text not null,
  preferred_date date,
  urgency text not null default 'Normal' check (urgency in ('Normal','Puede esperar','Urgente (evaluar)')),
  description text not null,
  status text not null default 'Pendiente' check (status in ('Pendiente','En proceso','Completada','Cancelada')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.community_posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  author_name text not null default '',
  category text not null default 'Comunidad',
  title text,
  body text not null check (char_length(body) between 1 and 1200),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.post_comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.community_posts(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  author_name text not null default '',
  body text not null check (char_length(body) between 1 and 500),
  created_at timestamptz not null default now()
);

create table if not exists public.post_likes (
  post_id uuid not null references public.community_posts(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);

create table if not exists public.courses (
  id text primary key,
  title text not null,
  category text not null default 'Técnico',
  description text not null,
  course_date date,
  duration text,
  level text,
  seats integer check (seats is null or seats >= 0),
  is_published boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.course_enrollments (
  id uuid primary key default gen_random_uuid(),
  course_id text not null references public.courses(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (course_id, user_id)
);

create table if not exists public.community_events (
  id text primary key,
  title text not null,
  category text not null default 'Comunidad',
  description text not null,
  event_date date,
  event_time time,
  location text,
  is_published boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.event_rsvps (
  id uuid primary key default gen_random_uuid(),
  event_id text not null references public.community_events(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (event_id, user_id)
);

create table if not exists public.service_points (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  zone text,
  address text,
  phone text,
  opening_hours text,
  verified boolean not null default false,
  published boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.favorites (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  item_type text not null check (item_type in ('service','course','event','point')),
  item_id text not null,
  created_at timestamptz not null default now(),
  unique (user_id, item_type, item_id)
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  body text not null,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.provider_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  specialty text not null,
  contact_value text not null,
  zone text not null,
  years_experience integer not null default 0 check (years_experience between 0 and 80),
  availability text,
  description text not null check (char_length(description) between 8 and 700),
  verified boolean not null default false,
  published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.feedback (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  topic text not null,
  body text not null check (char_length(body) between 8 and 1200),
  contact_email text,
  created_at timestamptz not null default now()
);

-- Función usada por perfiles creados automáticamente al registrar una cuenta.
create or replace function public.handle_new_kuali_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', ''))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_kuali_user_created on auth.users;
create trigger on_kuali_user_created
after insert on auth.users
for each row execute procedure public.handle_new_kuali_user();

-- Actualiza updated_at en tablas editables.
create or replace function public.kuali_set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at before update on public.profiles
for each row execute procedure public.kuali_set_updated_at();
drop trigger if exists service_requests_set_updated_at on public.service_requests;
create trigger service_requests_set_updated_at before update on public.service_requests
for each row execute procedure public.kuali_set_updated_at();
drop trigger if exists community_posts_set_updated_at on public.community_posts;
create trigger community_posts_set_updated_at before update on public.community_posts
for each row execute procedure public.kuali_set_updated_at();
drop trigger if exists provider_profiles_set_updated_at on public.provider_profiles;
create trigger provider_profiles_set_updated_at before update on public.provider_profiles
for each row execute procedure public.kuali_set_updated_at();

-- El autor no puede hacerse pasar por otra persona enviando author_name desde el navegador.
create or replace function public.kuali_set_post_author()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  select coalesce(nullif(btrim(p.full_name), ''), '')
    into new.author_name
    from public.profiles p
    where p.id = new.user_id;
  if new.author_name is null then new.author_name := ''; end if;
  return new;
end;
$$;

drop trigger if exists community_posts_set_author on public.community_posts;
create trigger community_posts_set_author before insert on public.community_posts
for each row execute procedure public.kuali_set_post_author();
drop trigger if exists post_comments_set_author on public.post_comments;
create trigger post_comments_set_author before insert on public.post_comments
for each row execute procedure public.kuali_set_post_author();

-- Índices para las búsquedas habituales y listas por usuario.
create index if not exists idx_service_requests_user_created on public.service_requests(user_id, created_at desc);
create index if not exists idx_service_requests_status on public.service_requests(status);
create index if not exists idx_community_posts_created on public.community_posts(created_at desc);
create index if not exists idx_post_comments_post_created on public.post_comments(post_id, created_at asc);
create index if not exists idx_post_likes_post on public.post_likes(post_id);
create index if not exists idx_course_enrollments_user on public.course_enrollments(user_id);
create index if not exists idx_event_rsvps_user on public.event_rsvps(user_id);
create index if not exists idx_favorites_user on public.favorites(user_id);
create index if not exists idx_notifications_user_created on public.notifications(user_id, created_at desc);
create index if not exists idx_service_points_zone on public.service_points(zone);
create index if not exists idx_provider_profiles_zone on public.provider_profiles(zone);

-- Activar RLS en TODAS las tablas de KUALI expuestas por la API.
alter table public.profiles enable row level security;
alter table public.service_requests enable row level security;
alter table public.community_posts enable row level security;
alter table public.post_comments enable row level security;
alter table public.post_likes enable row level security;
alter table public.courses enable row level security;
alter table public.course_enrollments enable row level security;
alter table public.community_events enable row level security;
alter table public.event_rsvps enable row level security;
alter table public.service_points enable row level security;
alter table public.provider_profiles enable row level security;
alter table public.favorites enable row level security;
alter table public.notifications enable row level security;
alter table public.feedback enable row level security;

-- Quitar permisos previos solo de las tablas de KUALI y conceder los mínimos necesarios.
-- RLS y GRANT se complementan: se necesitan ambos controles.
revoke all privileges on public.profiles, public.service_requests, public.community_posts,
  public.post_comments, public.post_likes, public.courses, public.course_enrollments,
  public.community_events, public.event_rsvps, public.service_points, public.provider_profiles,
  public.favorites, public.notifications, public.feedback from anon, authenticated;
grant usage on schema public to anon, authenticated;

-- Eliminar políticas de KUALI para que el script se pueda volver a ejecutar.
-- Eliminar también los nombres usados por la versión anterior del esquema.
drop policy if exists "profile_select_own" on public.profiles;
drop policy if exists "profile_update_own" on public.profiles;
drop policy if exists "service_requests_select_own" on public.service_requests;
drop policy if exists "service_requests_insert_own" on public.service_requests;
drop policy if exists "service_requests_update_own" on public.service_requests;
drop policy if exists "posts_select_published_or_own" on public.community_posts;
drop policy if exists "posts_insert_own" on public.community_posts;
drop policy if exists "posts_update_own" on public.community_posts;
drop policy if exists "posts_delete_own" on public.community_posts;
drop policy if exists "comments_select_all" on public.post_comments;
drop policy if exists "comments_insert_own" on public.post_comments;
drop policy if exists "comments_delete_own" on public.post_comments;
drop policy if exists "likes_select_all" on public.post_likes;
drop policy if exists "likes_insert_own" on public.post_likes;
drop policy if exists "likes_delete_own" on public.post_likes;
drop policy if exists "courses_select_published" on public.courses;
drop policy if exists "enrollments_select_own" on public.course_enrollments;
drop policy if exists "enrollments_insert_own" on public.course_enrollments;
drop policy if exists "enrollments_delete_own" on public.course_enrollments;
drop policy if exists "events_select_published" on public.community_events;
drop policy if exists "rsvps_select_own" on public.event_rsvps;
drop policy if exists "rsvps_insert_own" on public.event_rsvps;
drop policy if exists "rsvps_delete_own" on public.event_rsvps;
drop policy if exists "points_select_published" on public.service_points;
drop policy if exists "providers_select_published" on public.provider_profiles;
drop policy if exists "providers_select_own" on public.provider_profiles;
drop policy if exists "providers_insert_own" on public.provider_profiles;
drop policy if exists "providers_update_own" on public.provider_profiles;
drop policy if exists "providers_delete_own" on public.provider_profiles;
drop policy if exists "favorites_select_own" on public.favorites;
drop policy if exists "favorites_insert_own" on public.favorites;
drop policy if exists "favorites_delete_own" on public.favorites;
drop policy if exists "notifications_select_own" on public.notifications;
drop policy if exists "notifications_update_own" on public.notifications;
drop policy if exists "feedback_insert_own_or_guest" on public.feedback;

drop policy if exists profile_select_own on public.profiles;
drop policy if exists profile_update_own on public.profiles;
drop policy if exists service_requests_select_own on public.service_requests;
drop policy if exists service_requests_insert_own on public.service_requests;
drop policy if exists service_requests_cancel_own_pending on public.service_requests;
drop policy if exists posts_select_public on public.community_posts;
drop policy if exists posts_insert_own on public.community_posts;
drop policy if exists posts_update_own on public.community_posts;
drop policy if exists posts_delete_own on public.community_posts;
drop policy if exists comments_select_public on public.post_comments;
drop policy if exists comments_insert_own on public.post_comments;
drop policy if exists comments_delete_own on public.post_comments;
drop policy if exists likes_select_public on public.post_likes;
drop policy if exists likes_insert_own on public.post_likes;
drop policy if exists likes_delete_own on public.post_likes;
drop policy if exists courses_select_published on public.courses;
drop policy if exists enrollments_select_own on public.course_enrollments;
drop policy if exists enrollments_insert_own_published on public.course_enrollments;
drop policy if exists enrollments_delete_own on public.course_enrollments;
drop policy if exists events_select_published on public.community_events;
drop policy if exists rsvps_select_own on public.event_rsvps;
drop policy if exists rsvps_insert_own_published on public.event_rsvps;
drop policy if exists rsvps_delete_own on public.event_rsvps;
drop policy if exists points_select_published on public.service_points;
drop policy if exists providers_select_published on public.provider_profiles;
drop policy if exists providers_select_own on public.provider_profiles;
drop policy if exists providers_insert_own_draft on public.provider_profiles;
drop policy if exists providers_update_own on public.provider_profiles;
drop policy if exists providers_delete_own on public.provider_profiles;
drop policy if exists favorites_select_own on public.favorites;
drop policy if exists favorites_insert_own on public.favorites;
drop policy if exists favorites_delete_own on public.favorites;
drop policy if exists notifications_select_own on public.notifications;
drop policy if exists notifications_update_own on public.notifications;
drop policy if exists feedback_insert_public_limited on public.feedback;

-- Perfiles: solo el propietario puede leer/modificar su perfil.
create policy profile_select_own on public.profiles
  for select to authenticated using (id = (select auth.uid()));
create policy profile_update_own on public.profiles
  for update to authenticated using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- Solicitudes privadas: usuario ve las suyas; solo puede cancelar las pendientes.
create policy service_requests_select_own on public.service_requests
  for select to authenticated using (user_id = (select auth.uid()));
create policy service_requests_insert_own on public.service_requests
  for insert to authenticated with check (
    user_id = (select auth.uid()) and status = 'Pendiente'
  );
create policy service_requests_cancel_own_pending on public.service_requests
  for update to authenticated using (
    user_id = (select auth.uid()) and status = 'Pendiente'
  ) with check (
    user_id = (select auth.uid()) and status = 'Cancelada'
  );

-- Comunidad: publicaciones, comentarios y reacciones son visibles; escribir exige cuenta.
create policy posts_select_public on public.community_posts
  for select to anon, authenticated using (true);
create policy posts_insert_own on public.community_posts
  for insert to authenticated with check (user_id = (select auth.uid()));
create policy posts_update_own on public.community_posts
  for update to authenticated using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));
create policy posts_delete_own on public.community_posts
  for delete to authenticated using (user_id = (select auth.uid()));

create policy comments_select_public on public.post_comments
  for select to anon, authenticated using (true);
create policy comments_insert_own on public.post_comments
  for insert to authenticated with check (
    user_id = (select auth.uid()) and exists (
      select 1 from public.community_posts p where p.id = post_id
    )
  );
create policy comments_delete_own on public.post_comments
  for delete to authenticated using (user_id = (select auth.uid()));

create policy likes_select_public on public.post_likes
  for select to anon, authenticated using (true);
create policy likes_insert_own on public.post_likes
  for insert to authenticated with check (user_id = (select auth.uid()));
create policy likes_delete_own on public.post_likes
  for delete to authenticated using (user_id = (select auth.uid()));

-- Cursos/eventos publicados son públicos; el usuario solo gestiona su propio interés.
create policy courses_select_published on public.courses
  for select to anon, authenticated using (is_published = true);
create policy enrollments_select_own on public.course_enrollments
  for select to authenticated using (user_id = (select auth.uid()));
create policy enrollments_insert_own_published on public.course_enrollments
  for insert to authenticated with check (
    user_id = (select auth.uid()) and exists (
      select 1 from public.courses c where c.id = course_id and c.is_published = true
    )
  );
create policy enrollments_delete_own on public.course_enrollments
  for delete to authenticated using (user_id = (select auth.uid()));

create policy events_select_published on public.community_events
  for select to anon, authenticated using (is_published = true);
create policy rsvps_select_own on public.event_rsvps
  for select to authenticated using (user_id = (select auth.uid()));
create policy rsvps_insert_own_published on public.event_rsvps
  for insert to authenticated with check (
    user_id = (select auth.uid()) and exists (
      select 1 from public.community_events e where e.id = event_id and e.is_published = true
    )
  );
create policy rsvps_delete_own on public.event_rsvps
  for delete to authenticated using (user_id = (select auth.uid()));

-- Directorio: se muestran solo puntos publicados y perfiles de proveedores publicados.
create policy points_select_published on public.service_points
  for select to anon, authenticated using (published = true);
create policy providers_select_published on public.provider_profiles
  for select to anon, authenticated using (published = true);
create policy providers_select_own on public.provider_profiles
  for select to authenticated using (id = (select auth.uid()));
create policy providers_insert_own_draft on public.provider_profiles
  for insert to authenticated with check (
    id = (select auth.uid()) and verified = false and published = false
  );
create policy providers_update_own on public.provider_profiles
  for update to authenticated using (id = (select auth.uid()))
  with check (id = (select auth.uid()));
create policy providers_delete_own on public.provider_profiles
  for delete to authenticated using (id = (select auth.uid()));

-- Preferencias y notificaciones privadas.
create policy favorites_select_own on public.favorites
  for select to authenticated using (user_id = (select auth.uid()));
create policy favorites_insert_own on public.favorites
  for insert to authenticated with check (user_id = (select auth.uid()));
create policy favorites_delete_own on public.favorites
  for delete to authenticated using (user_id = (select auth.uid()));

create policy notifications_select_own on public.notifications
  for select to authenticated using (user_id = (select auth.uid()));
create policy notifications_update_own on public.notifications
  for update to authenticated using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- Comentarios/ayuda: se permite enviar información, pero no leerla por la API pública.
create policy feedback_insert_public_limited on public.feedback
  for insert to anon, authenticated with check (
    user_id is null or user_id = (select auth.uid())
  );

-- Mínimo privilegio para roles expuestos al navegador.
grant select on public.profiles to authenticated;
grant update (full_name, phone, zone, about, interests) on public.profiles to authenticated;

grant select on public.service_requests to authenticated;
grant insert (user_id, code, service_id, service_name, contact_name, contact_value, zone,
  preferred_date, urgency, description) on public.service_requests to authenticated;
grant update (status) on public.service_requests to authenticated;

grant select on public.community_posts to anon, authenticated;
grant insert (user_id, category, title, body) on public.community_posts to authenticated;
grant update (category, title, body) on public.community_posts to authenticated;
grant delete on public.community_posts to authenticated;

grant select on public.post_comments to anon, authenticated;
grant insert (post_id, user_id, body) on public.post_comments to authenticated;
grant delete on public.post_comments to authenticated;

grant select on public.post_likes to anon, authenticated;
grant insert (post_id, user_id) on public.post_likes to authenticated;
grant delete on public.post_likes to authenticated;

grant select on public.courses to anon, authenticated;
grant select on public.course_enrollments to authenticated;
grant insert (course_id, user_id) on public.course_enrollments to authenticated;
grant delete on public.course_enrollments to authenticated;

grant select on public.community_events to anon, authenticated;
grant select on public.event_rsvps to authenticated;
grant insert (event_id, user_id) on public.event_rsvps to authenticated;
grant delete on public.event_rsvps to authenticated;

grant select on public.service_points to anon, authenticated;
grant select on public.provider_profiles to anon, authenticated;
grant insert (id, display_name, specialty, contact_value, zone, years_experience, availability, description)
  on public.provider_profiles to authenticated;
grant update (display_name, specialty, contact_value, zone, years_experience, availability, description)
  on public.provider_profiles to authenticated;
grant delete on public.provider_profiles to authenticated;

grant select on public.favorites to authenticated;
grant insert (user_id, item_type, item_id) on public.favorites to authenticated;
grant delete on public.favorites to authenticated;

grant select on public.notifications to authenticated;
grant update (is_read) on public.notifications to authenticated;

grant insert (user_id, topic, body, contact_email) on public.feedback to anon, authenticated;

-- El mantenimiento de cursos, eventos, puntos de servicio, publicación/verificación
-- de proveedores y la creación de notificaciones debe hacerse desde un entorno confiable
-- (Dashboard/servidor); no se concede a usuarios públicos permiso para esas tareas.

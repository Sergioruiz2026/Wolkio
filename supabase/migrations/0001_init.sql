-- Wolkio · Esquema inicial de base de datos (Supabase / PostgreSQL + PostGIS)

create extension if not exists postgis;

-- 1. Usuario
create table usuario (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  rut text unique not null,
  telefono text unique not null,
  telefono_verificado boolean default false,
  correo text unique,
  correo_verificado boolean default false,
  foto_perfil text,
  calificacion_promedio numeric(2,1) default 0,
  fecha_registro timestamptz default now()
);

-- 2. Verificación de identidad
create type estado_verificacion as enum ('pendiente', 'aprobado', 'rechazado');

create table verificacion_identidad (
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid references usuario(id) on delete cascade,
  cedula_frente text,
  cedula_reverso text,
  selfie text,
  certificado_antecedentes text,
  estado estado_verificacion default 'pendiente',
  fecha_verificacion timestamptz
);

-- 3. Perfil de prestador
create type modo_traslado as enum ('a_pie', 'bicicleta', 'auto');

create table prestador_perfil (
  usuario_id uuid primary key references usuario(id) on delete cascade,
  modo_traslado modo_traslado default 'a_pie',
  radio_maximo_km numeric(4,1) default 1.5,
  disponible boolean default false,
  categorias_habilitadas text[] default '{}',
  cuenta_bancaria text,
  ubicacion_actual geography(Point, 4326)
);

create index idx_prestador_ubicacion on prestador_perfil using gist (ubicacion_actual);

-- 4. Tarea
create type categoria_tarea as enum ('patio', 'mudanza', 'muebles', 'limpieza');
create type estado_tarea as enum ('publicada', 'buscando_prestador', 'asignada', 'en_curso', 'finalizada', 'cancelada');

create table tarea (
  id uuid primary key default gen_random_uuid(),
  solicitante_id uuid references usuario(id),
  categoria categoria_tarea not null,
  descripcion text,
  fotos text[] default '{}',
  ubicacion geography(Point, 4326) not null,
  direccion_exacta text,
  modo_traslado_requerido modo_traslado,
  precio_ofrecido numeric(10,0) not null,
  fecha_hora_programada timestamptz,
  estado estado_tarea default 'publicada',
  prestador_id uuid references usuario(id),
  fecha_creacion timestamptz default now()
);

create index idx_tarea_ubicacion on tarea using gist (ubicacion);

-- 5. Notificación (registro de alertas enviadas)
create type estado_notificacion as enum ('enviada', 'aceptada', 'rechazada', 'expirada');

create table notificacion (
  id uuid primary key default gen_random_uuid(),
  tarea_id uuid references tarea(id) on delete cascade,
  prestador_id uuid references usuario(id),
  distancia_km numeric(5,2),
  estado estado_notificacion default 'enviada',
  fecha_envio timestamptz default now()
);

-- 6. Pago
create type metodo_pago as enum ('tarjeta', 'transferencia', 'mercado_pago', 'webpay');
create type estado_pago as enum ('retenido', 'liberado', 'reembolsado');

create table pago (
  id uuid primary key default gen_random_uuid(),
  tarea_id uuid unique references tarea(id) on delete cascade,
  monto_total numeric(10,0) not null,
  comision_porcentaje numeric(4,2) not null default 15.00,
  monto_prestador numeric(10,0) generated always as (monto_total * (1 - comision_porcentaje / 100)) stored,
  monto_app numeric(10,0) generated always as (monto_total * (comision_porcentaje / 100)) stored,
  metodo_pago metodo_pago,
  estado estado_pago default 'retenido',
  fecha_pago timestamptz,
  fecha_liberacion timestamptz
);

-- 7. Calificación
create table calificacion (
  id uuid primary key default gen_random_uuid(),
  tarea_id uuid references tarea(id) on delete cascade,
  calificador_id uuid references usuario(id),
  calificado_id uuid references usuario(id),
  puntaje smallint check (puntaje between 1 and 5),
  comentario text,
  visible boolean default false,
  fecha timestamptz default now(),
  unique (tarea_id, calificador_id)
);

-- 8. Mensaje (chat por tarea)
create table mensaje (
  id uuid primary key default gen_random_uuid(),
  tarea_id uuid references tarea(id) on delete cascade,
  remitente_id uuid references usuario(id),
  contenido text not null,
  fecha timestamptz default now()
);

-- 9. Reporte (soporte e incidentes)
create type motivo_reporte as enum ('pago', 'seguridad', 'calidad', 'otro');
create type estado_reporte as enum ('abierto', 'en_revision', 'cerrado');

create table reporte (
  id uuid primary key default gen_random_uuid(),
  tarea_id uuid references tarea(id),
  usuario_reporta_id uuid references usuario(id),
  motivo motivo_reporte,
  descripcion text,
  estado estado_reporte default 'abierto',
  fecha timestamptz default now()
);

-- Función: buscar prestadores dentro del radio para una tarea
create or replace function prestadores_cercanos(tarea_id_param uuid)
returns table (usuario_id uuid, distancia_km numeric) as $$
  select
    pp.usuario_id,
    round((st_distance(pp.ubicacion_actual, t.ubicacion) / 1000)::numeric, 2) as distancia_km
  from prestador_perfil pp
  join tarea t on t.id = tarea_id_param
  where pp.disponible = true
    and t.categoria = any(pp.categorias_habilitadas)
    and st_dwithin(pp.ubicacion_actual, t.ubicacion, pp.radio_maximo_km * 1000)
  order by distancia_km asc;
$$ language sql stable;

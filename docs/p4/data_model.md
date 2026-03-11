# Modelo de Datos: tabla `todos`

## Objetivo

Definir la estructura recomendada de la tabla `todos` en Supabase/Postgres para soportar el MVP de la To-Do App con ownership por usuario, filtros simples y CRUD seguro.

## Tabla propuesta

Nombre:

- `public.todos`

Finalidad:

- almacenar tareas personales de usuarios autenticados.

## Campos

| Campo | Tipo Postgres | Requerido | Default | Descripcion |
|---|---|---|---|---|
| `id` | `uuid` | si | `gen_random_uuid()` | identificador unico de la tarea |
| `user_id` | `uuid` | si | no | propietario de la tarea, referencia a `auth.users.id` |
| `title` | `text` | si | no | titulo corto de la tarea |
| `description` | `text` | no | `null` | detalle opcional |
| `status` | `text` | si | `'pending'` | estado actual de la tarea |
| `priority` | `text` | si | `'medium'` | prioridad operativa |
| `due_date` | `date` | no | `null` | fecha limite opcional |
| `completed_at` | `timestamptz` | no | `null` | momento en que se completo la tarea |
| `created_at` | `timestamptz` | si | `now()` | fecha de creacion |
| `updated_at` | `timestamptz` | si | `now()` | fecha de ultima actualizacion |

## Semantica de campos

- `id`: clave primaria tecnica.
- `user_id`: ownership obligatorio para RLS.
- `title`: unico campo imprescindible para crear un todo.
- `description`: texto libre opcional.
- `status`: para filtrar pendientes frente a completadas.
- `priority`: para orden visual y foco del usuario.
- `due_date`: no obliga recordatorios, solo orden y contexto.
- `completed_at`: util para auditoria y metrica simple.
- `created_at` y `updated_at`: soporte de ordenacion y depuracion.

## Restricciones recomendadas

### Clave primaria

- `primary key (id)`

### Clave foranea

- `foreign key (user_id) references auth.users(id) on delete cascade`

Razon:

- si el usuario desaparece, sus tareas no deben quedar huerfanas.

### Not null

- `user_id`
- `title`
- `status`
- `priority`
- `created_at`
- `updated_at`

### Checks

- `char_length(trim(title)) > 0`
- `char_length(title) <= 120`
- `status in ('pending', 'completed')`
- `priority in ('low', 'medium', 'high')`
- `completed_at is null or status = 'completed'`

Restriccion opcional mas estricta:

- exigir que `completed_at is null` cuando `status = 'pending'`

### Defaults

- `id = gen_random_uuid()`
- `status = 'pending'`
- `priority = 'medium'`
- `created_at = now()`
- `updated_at = now()`

## Indices sugeridos

### Basicos

- indice por `user_id`
- indice compuesto por `user_id, status`

### Segun consultas del MVP

- indice compuesto por `user_id, created_at desc`
- indice compuesto por `user_id, due_date`

### Justificacion

- casi todas las consultas del frontend estaran filtradas por usuario.
- el filtro por estado sera frecuente en dashboard.
- el orden por creacion o vencimiento mejora rendimiento en listados.

## Contratos operativos

## Insert

Entrada minima recomendada:

- `title`

Entrada opcional:

- `description`
- `priority`
- `due_date`

Campos no confiables desde cliente:

- `user_id`
- `created_at`
- `updated_at`
- `completed_at`

## Update

Campos editables:

- `title`
- `description`
- `priority`
- `due_date`
- `status`

Campos protegidos:

- `id`
- `user_id`
- `created_at`

## Convenciones recomendadas

- usar `pending` y `completed` como unicos estados del MVP.
- usar `low`, `medium`, `high` para evitar taxonomias abiertas.
- actualizar `updated_at` en cada modificacion.
- completar `completed_at` solo cuando la tarea pase a `completed`.

## Ejemplos de registros

### Registro pendiente

```json
{
  "id": "b4ad2e6d-7ee7-4d80-b7fc-235e8e9b3f31",
  "user_id": "9a4d42f7-9f79-4d78-9a2d-98557ee7fd0c",
  "title": "Preparar demo del MVP",
  "description": "Revisar flujo de login, CRUD y estados vacios",
  "status": "pending",
  "priority": "high",
  "due_date": "2026-03-15",
  "completed_at": null,
  "created_at": "2026-03-11T18:30:00Z",
  "updated_at": "2026-03-11T18:30:00Z"
}
```

### Registro completado

```json
{
  "id": "f61c31d0-5dce-4d2f-a36d-7dd7af1fbf86",
  "user_id": "9a4d42f7-9f79-4d78-9a2d-98557ee7fd0c",
  "title": "Configurar proyecto en Vercel",
  "description": "Anadir variables de entorno de Supabase",
  "status": "completed",
  "priority": "medium",
  "due_date": "2026-03-12",
  "completed_at": "2026-03-11T19:10:00Z",
  "created_at": "2026-03-10T16:00:00Z",
  "updated_at": "2026-03-11T19:10:00Z"
}
```

## Consideraciones para Supabase

- activar RLS en `public.todos`.
- basar todas las politicas en `auth.uid() = user_id`.
- no exponer `service_role_key` al frontend.
- validar ownership en `select`, `insert`, `update` y `delete`.

## Evolucion futura sin romper el MVP

- anadir `deleted_at` para soft delete.
- anadir `list_id` para multiples listas.
- anadir `position` para orden manual.
- anadir `labels` o tabla relacional de tags.

# Modelo de Datos

## Principios

- Modelo minimo para llegar a MVP.
- Ownership explicito por `user_id`.
- Campos auditables para depuracion y ordenacion.
- Validaciones simples tanto en cliente como en base de datos.

## Entidades

### `profiles`

Finalidad: metadatos basicos del usuario autenticado.

Campos propuestos:

- `id`: UUID, PK, referencia a `auth.users.id`.
- `email`: text, no nulo.
- `display_name`: text, nullable.
- `created_at`: timestamptz, no nulo, default `now()`.
- `updated_at`: timestamptz, no nulo, default `now()`.

Reglas:

- 1 perfil por usuario.
- Puede poblarse al registrarse o en primer login.

### `tasks`

Finalidad: tareas personales del usuario.

Campos propuestos:

- `id`: UUID, PK.
- `user_id`: UUID, no nulo, FK a `auth.users.id`.
- `title`: text, no nulo.
- `description`: text, nullable.
- `status`: text, no nulo, default `pending`.
- `priority`: text, no nulo, default `medium`.
- `due_date`: date, nullable.
- `created_at`: timestamptz, no nulo, default `now()`.
- `updated_at`: timestamptz, no nulo, default `now()`.
- `completed_at`: timestamptz, nullable.

Reglas:

- Cada tarea pertenece a un solo usuario.
- `title` debe tener longitud minima de 1 tras trim.
- `status` permitido: `pending`, `completed`.
- `priority` permitido: `low`, `medium`, `high`.
- Si `status = completed`, `completed_at` puede completarse.
- Si `status = pending`, `completed_at` deberia ser null.

## Relaciones

- `profiles.id` 1:1 `auth.users.id`
- `auth.users.id` 1:N `tasks.user_id`

## Contratos de lectura

### Task DTO

Campos esperados por frontend:

- `id`
- `title`
- `description`
- `status`
- `priority`
- `due_date`
- `created_at`
- `updated_at`
- `completed_at`

No exponer en UI:

- metadatos internos no necesarios,
- claves de sistema,
- datos de otros usuarios.

## Contratos de escritura

### Crear tarea

Entrada minima:

- `title`

Entrada opcional:

- `description`
- `priority`
- `due_date`

Campos asignados por backend o politica:

- `user_id`
- `status`
- `created_at`
- `updated_at`

### Actualizar tarea

Campos editables:

- `title`
- `description`
- `priority`
- `due_date`
- `status`

Campos no editables desde cliente:

- `user_id`
- `created_at`

## Indices recomendados

- PK por defecto en `profiles.id`.
- PK por defecto en `tasks.id`.
- Indice por `tasks.user_id`.
- Indice compuesto por `tasks.user_id, status`.
- Indice por `tasks.user_id, due_date` si el orden por vencimiento se usa mucho.

## Validaciones

### Cliente

- `title` requerido.
- `title` longitud maxima razonable, por ejemplo 120.
- `description` longitud maxima razonable.
- `due_date` no debe romper el parser de fecha del navegador.

### Base de datos

- `check status in ('pending','completed')`
- `check priority in ('low','medium','high')`
- `check char_length(trim(title)) > 0`

## Evolucion futura sin romper MVP

- Tabla `lists`.
- Tabla `task_tags`.
- Soporte de colaboracion.
- Soft delete con `deleted_at`.

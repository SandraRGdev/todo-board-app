# Politicas RLS

## Objetivo de seguridad

Garantizar aislamiento estricto por usuario usando Supabase Auth y Row Level Security en todas las tablas de negocio.

## Principios

- RLS habilitado por defecto en `profiles` y `tasks`.
- El acceso desde frontend usa la clave anonima y depende de la sesion autenticada.
- Ninguna operacion del cliente usa la service role key.
- Las politicas se basan en `auth.uid()`.

## Tablas protegidas

- `profiles`
- `tasks`

## Politicas funcionales requeridas

### `profiles`

Lectura permitida:

- El usuario puede leer solo su propio perfil.

Insercion permitida:

- El usuario autenticado puede crear solo un perfil con `id = auth.uid()`.

Actualizacion permitida:

- El usuario puede actualizar solo su propio perfil.

Borrado:

- No requerido para MVP.

### `tasks`

Lectura permitida:

- El usuario puede leer solo filas con `user_id = auth.uid()`.

Insercion permitida:

- El usuario autenticado puede insertar tareas solo con `user_id = auth.uid()`.

Actualizacion permitida:

- El usuario puede actualizar solo filas con `user_id = auth.uid()`.

Borrado permitido:

- El usuario puede borrar solo filas con `user_id = auth.uid()`.

## Matriz de acceso

| Actor | profiles | tasks |
|---|---|---|
| Anonimo | sin acceso | sin acceso |
| Usuario autenticado | solo su fila | solo sus filas |
| Service role | acceso administrativo fuera del cliente | acceso administrativo fuera del cliente |

## Reglas de implementacion

- Activar RLS antes de conectar la UI final.
- Añadir politicas por operacion: `select`, `insert`, `update`, `delete`.
- Revisar que no existan funciones RPC que eludan el modelo de seguridad.
- Si hay triggers, asegurar que no escriban datos con ownership incorrecto.

## Casos de prueba minimos

### Acceso esperado

- Usuario A puede leer su perfil.
- Usuario A puede listar sus tareas.
- Usuario A puede crear una tarea propia.
- Usuario A puede cambiar el estado de su tarea.
- Usuario A puede borrar su tarea.

### Acceso denegado

- Usuario no autenticado no puede listar tareas.
- Usuario A no puede leer tareas de Usuario B.
- Usuario A no puede actualizar tareas de Usuario B.
- Usuario A no puede borrar tareas de Usuario B.
- Usuario A no puede insertar una tarea con `user_id` de Usuario B.

## Riesgos

- Crear politicas solo de lectura y olvidar escritura.
- Permitir inserts sin validar ownership.
- Usar service role key accidentalmente en frontend.
- Desactivar RLS durante pruebas y no reactivarlo.

## Validacion antes de release

- Probar con dos usuarios reales distintos.
- Confirmar denegaciones tanto en UI como en consola de Supabase.
- Revisar logs de errores de autorizacion para detectar falsos positivos.

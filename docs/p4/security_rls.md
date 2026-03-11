# Seguridad con Row Level Security en `todos`

## Objetivo

Explicar como proteger la tabla `public.todos` en Supabase usando Row Level Security para que cada usuario autenticado solo pueda leer y modificar sus propias tareas.

## Que es RLS

Row Level Security, o RLS, es una caracteristica de Postgres que permite definir politicas de acceso a nivel de fila.

Eso significa que la base de datos no solo decide si un usuario puede acceder a una tabla, sino tambien a que filas concretas puede acceder dentro de esa tabla.

En una To-Do App multiusuario, esto permite que dos usuarios compartan la misma tabla `todos` sin poder ver ni modificar los registros del otro.

## Por que es necesario

En Supabase, el frontend suele conectarse con la `anon key`, no con credenciales de administrador. Aun asi, eso no es suficiente para proteger datos por si solo.

Riesgos si no se usa RLS:

- cualquier error en el frontend podria exponer tareas ajenas,
- los filtros de interfaz no son una medida de seguridad real,
- un usuario podria intentar consultar o modificar filas de otro usuario directamente.

RLS es necesario porque mueve la proteccion al nivel correcto: la base de datos.

## Principio de seguridad para `todos`

Cada fila de `public.todos` tiene un campo `user_id` que identifica a su propietario.

La regla de ownership del MVP es:

- solo el propietario puede leer la fila,
- solo el propietario puede insertarla para si mismo,
- solo el propietario puede actualizarla,
- solo el propietario puede eliminarla.

La condicion base es:

- `user_id = auth.uid()`

En Supabase, `auth.uid()` devuelve el id del usuario autenticado asociado a la sesion actual.

## Conjunto minimo de proteccion

## 1. Activar RLS en la tabla

Sin este paso, las politicas no se aplican.

Objetivo:

- asegurar que todas las operaciones pasen por evaluacion de politicas.

## 2. Politica de `SELECT`

Finalidad:

- permitir que un usuario vea solo sus tareas.

Condicion conceptual:

- `user_id = auth.uid()`

Efecto:

- el usuario autenticado solo recibe filas propias.
- un usuario anonimo no obtiene resultados.

## 3. Politica de `INSERT`

Finalidad:

- permitir crear tareas solo para el usuario autenticado.

Condicion conceptual:

- la nueva fila debe cumplir `user_id = auth.uid()`

Efecto:

- se evita que un usuario cree tareas asignadas a otro usuario.

## 4. Politica de `UPDATE`

Finalidad:

- permitir modificar solo filas propias.

Condiciones conceptuales:

- la fila actual debe pertenecer al usuario autenticado,
- la fila resultante debe seguir perteneciendo al mismo usuario autenticado.

Efecto:

- el usuario no puede editar tareas ajenas,
- el usuario no puede cambiar el ownership a otro `user_id`.

## 5. Politica de `DELETE`

Finalidad:

- permitir borrar solo filas propias.

Condicion conceptual:

- `user_id = auth.uid()`

Efecto:

- no se pueden eliminar tareas de otros usuarios.

## Politicas minimas recomendadas

Referencia conceptual por operacion:

- `SELECT`: `using (user_id = auth.uid())`
- `INSERT`: `with check (user_id = auth.uid())`
- `UPDATE`: `using (user_id = auth.uid())` y `with check (user_id = auth.uid())`
- `DELETE`: `using (user_id = auth.uid())`

## Ejemplo minimo de definicion

```sql
alter table public.todos enable row level security;

create policy "todos_select_own"
on public.todos
for select
to authenticated
using (user_id = auth.uid());

create policy "todos_insert_own"
on public.todos
for insert
to authenticated
with check (user_id = auth.uid());

create policy "todos_update_own"
on public.todos
for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "todos_delete_own"
on public.todos
for delete
to authenticated
using (user_id = auth.uid());
```

## Como leer estas politicas

- `using`: decide sobre que filas existentes se permite operar.
- `with check`: valida que la fila nueva o modificada cumpla la regla despues del cambio.

Interpretacion practica:

- en `SELECT`, `UPDATE` y `DELETE`, `using` filtra las filas accesibles.
- en `INSERT`, `with check` evita insertar ownership incorrecto.
- en `UPDATE`, combinar ambos evita editar filas ajenas y evita cambiar la fila a un dueño distinto.

## Buenas practicas

- usar siempre el campo `user_id` como ownership explicito,
- no confiar en filtros del frontend como mecanismo de seguridad,
- no exponer `service_role_key` al cliente,
- probar politicas con dos usuarios distintos,
- revisar que no existan funciones RPC que omitan esta logica de acceso.

## Casos de prueba minimos

### Permitidos

- Usuario A lista sus tareas.
- Usuario A crea una fila con su `user_id`.
- Usuario A actualiza una tarea propia.
- Usuario A elimina una tarea propia.

### Denegados

- Usuario A intenta leer tareas de Usuario B.
- Usuario A intenta insertar una tarea con `user_id` de Usuario B.
- Usuario A intenta actualizar una tarea de Usuario B.
- Usuario A intenta borrar una tarea de Usuario B.
- Usuario no autenticado intenta consultar `todos`.

## Riesgos frecuentes

- activar RLS pero olvidar crear politicas de escritura,
- permitir `INSERT` o `UPDATE` sin `with check`,
- usar la clave de servicio en el frontend y saltarse el modelo de seguridad,
- asumir que ocultar datos en la UI equivale a protegerlos.

## Criterio de exito

La tabla `todos` queda correctamente protegida cuando:

- todas las operaciones CRUD pasan por RLS,
- cada usuario solo ve y modifica sus filas,
- los accesos cruzados quedan denegados,
- la seguridad depende de Postgres y no del cliente.

# Arquitectura Conceptual de Integracion

## Objetivo

Definir una arquitectura conceptual para una To-Do App con Vue 3 y Supabase, centrada en separacion de responsabilidades, flujo de autenticacion, CRUD de tareas, manejo de estados y seguridad con RLS.

## Vista general

La aplicacion se organiza en tres capas:

- `UI`: vistas, componentes y estados visuales en Vue 3.
- `Application`: coordinacion de sesion, reglas de negocio simples y llamadas a Supabase.
- `Platform`: Supabase Auth, Postgres y Row Level Security.

Flujo principal:

1. El usuario abre la app.
2. Vue 3 consulta el estado de sesion en Supabase Auth.
3. Si hay sesion valida, entra al area privada y consulta sus `todos`.
4. Todas las operaciones CRUD se ejecutan contra Supabase con la sesion del usuario.
5. RLS garantiza que solo se lean y modifiquen filas del propietario.

## Componentes y vistas principales

### Vistas

#### `AuthView`

Responsabilidad:

- login,
- registro,
- mostrar errores de autenticacion,
- redirigir al dashboard si existe sesion valida.

#### `TodosView`

Responsabilidad:

- mostrar la lista de tareas del usuario,
- servir como pantalla principal autenticada,
- coordinar filtros, creacion y edicion.

#### `NotFoundView` o `ErrorView`

Responsabilidad:

- capturar rutas invalidas o errores no recuperables,
- ofrecer salida clara hacia login o dashboard.

### Componentes

#### `AppShell`

- layout base,
- cabecera,
- contenedor principal,
- gestion visual de navegacion segun sesion.

#### `AuthForm`

- formulario de email/password,
- cambio entre login y registro,
- feedback de loading y error.

#### `TodoToolbar`

- boton de nueva tarea,
- filtros por estado,
- opcion de ordenacion,
- accion de logout.

#### `TodoList`

- renderizado de la lista de tareas,
- delega cada item a `TodoItem`.

#### `TodoItem`

- muestra titulo, prioridad, fecha limite y estado,
- permite completar, editar o eliminar.

#### `TodoForm`

- crear o editar un todo,
- valida campos minimos,
- emite confirmacion o cancelacion.

#### `LoadingState`

- placeholder o spinner durante auth y consultas.

#### `EmptyState`

- mensaje cuando no hay tareas,
- CTA para crear la primera.

#### `ErrorState`

- mensaje reutilizable para errores de red, auth o permisos.

## Flujo de autenticacion

## 1. Inicializacion

- La app monta el cliente de Supabase.
- Consulta sesion actual.
- Mientras se resuelve, la UI entra en estado `loading`.

## 2. Usuario no autenticado

- Se muestra `AuthView`.
- El usuario puede:
  - iniciar sesion,
  - registrarse.

## 3. Login o registro exitoso

- Supabase devuelve una sesion valida.
- El estado global de autenticacion se actualiza.
- La app navega a `TodosView`.

## 4. Sesion persistida

- Al recargar la pagina, la app vuelve a hidratar la sesion.
- Si la sesion sigue siendo valida, entra directamente al dashboard.

## 5. Logout

- Se invalida la sesion en cliente.
- Se limpia el estado local de usuario y lista de tareas.
- La app redirige a `AuthView`.

## Operaciones CRUD sobre `todos`

Entidad operativa:

- `todo` o `task` con ownership por `user_id`.

### Create

Flujo:

1. Usuario abre `TodoForm`.
2. Completa `title` y campos opcionales.
3. Frontend valida datos minimos.
4. Supabase inserta la fila asociada al usuario autenticado.
5. La lista se refresca o actualiza localmente.

Resultado esperado:

- el nuevo todo aparece sin exponer datos de otros usuarios.

### Read

Flujo:

1. Al entrar a `TodosView`, el frontend consulta tareas del usuario autenticado.
2. Puede aplicar filtros por estado o criterio de ordenacion.
3. La UI representa loading, empty o list segun respuesta.

Resultado esperado:

- el usuario ve solo sus tareas.

### Update

Flujo:

1. Usuario edita un todo o cambia su estado a completado.
2. Frontend envia la actualizacion a Supabase.
3. La respuesta actualiza la fila visible o fuerza una recarga de lista.

Resultado esperado:

- cambios consistentes en titulo, descripcion, prioridad, fecha o estado.

### Delete

Flujo:

1. Usuario activa eliminar sobre un todo propio.
2. Frontend confirma la accion si la UX lo requiere.
3. Supabase elimina la fila.
4. La lista se actualiza y recalcula estados vacios o contadores.

Resultado esperado:

- el todo desaparece sin afectar datos de terceros.

## Manejo de estados

## Estados globales

### `authLoading`

- se usa durante hidratacion inicial de sesion.
- evita flicker entre vista publica y privada.

### `authError`

- se usa cuando falla login, registro o validacion de sesion.

## Estados de lista

### `loading`

- mientras se consultan los todos.
- la vista muestra skeleton o spinner.

### `error`

- cuando la consulta o mutacion falla.
- la UI muestra mensaje accionable y opcion de reintento.

### `empty`

- cuando la consulta es valida pero sin resultados.
- se muestra CTA para crear la primera tarea.

### `success`

- cuando hay datos y la lista puede renderizarse.

## Estados de mutacion

- `creating`
- `updating`
- `deleting`

Buenas practicas:

- desactivar botones durante mutaciones,
- mostrar feedback inmediato,
- evitar duplicados por doble submit,
- sincronizar UI despues de cada operacion.

## Consideraciones de seguridad

## Principio base

La seguridad de datos no depende del frontend. El frontend solo mejora UX; el aislamiento real lo impone Supabase con RLS.

## RLS en `todos`

Politicas conceptuales requeridas:

- `SELECT`: solo leer filas con `user_id = auth.uid()`.
- `INSERT`: solo insertar filas con `user_id = auth.uid()`.
- `UPDATE`: solo modificar filas con `user_id = auth.uid()`.
- `DELETE`: solo borrar filas con `user_id = auth.uid()`.

## Reglas operativas

- No exponer `service_role_key` en Vue.
- Usar solo `anon key` en cliente.
- No confiar en filtros de frontend como mecanismo de seguridad.
- No permitir que el usuario cambie ownership desde la UI.

## Validaciones de seguridad

- Usuario A no puede leer tareas de Usuario B.
- Usuario A no puede editar tareas de Usuario B.
- Usuario A no puede borrar tareas de Usuario B.
- Usuario A no puede crear tareas con `user_id` ajeno.
- Usuario anonimo no puede acceder al CRUD privado.

## Riesgos principales

- Renderizar datos stale al cambiar de sesion.
- Manejo incompleto de errores de permisos.
- Politicas RLS parciales, por ejemplo solo `SELECT`.
- Uso accidental de credenciales incorrectas en Vercel.

## Recomendacion de integracion

Orden sugerido:

1. Configurar cliente Supabase y sesion.
2. Implementar `AuthView` y guardas de rutas.
3. Integrar lectura de `todos`.
4. Implementar create/update/delete.
5. Añadir estados `loading/error/empty`.
6. Verificar RLS con dos usuarios distintos.
7. Preparar despliegue en Vercel con variables de entorno correctas.

## Criterio de exito

La arquitectura se considera valida para MVP cuando:

- el usuario puede autenticarse y gestionar sus tareas de extremo a extremo,
- la UI contempla estados de carga, vacio y error,
- el CRUD queda desacoplado de la logica visual,
- la proteccion de datos depende de RLS y no del cliente.

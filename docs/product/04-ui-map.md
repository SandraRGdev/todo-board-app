# Mapa de UI

## Objetivo UX

Reducir el tiempo entre login y gestion de la primera tarea. La interfaz debe ser directa, con estados visibles y friccion minima.

## Pantallas principales

### 1. Landing / Auth

Objetivo:

- permitir registro,
- permitir login,
- redirigir al area privada al autenticar.

Bloques:

- logo o nombre del producto,
- formulario de login,
- cambio a modo registro,
- mensajes de error,
- feedback de carga.

Estados:

- idle,
- enviando,
- credenciales invalidas,
- registro exitoso,
- sesion activa.

### 2. Dashboard de tareas

Objetivo:

- visualizar y operar tareas personales.

Bloques:

- cabecera con nombre de producto y logout,
- resumen simple: total, pendientes, completadas,
- barra de filtros,
- boton de nueva tarea,
- listado de tareas,
- estado vacio,
- mensajes de error.

Estados:

- cargando lista,
- sin tareas,
- con tareas,
- error al cargar,
- mutacion en curso.

### 3. Formulario de tarea

Objetivo:

- crear o editar una tarea con el menor numero de campos posible.

Campos:

- titulo,
- descripcion,
- prioridad,
- fecha limite,
- estado solo en modo edicion.

Acciones:

- guardar,
- cancelar,
- eliminar solo en modo edicion.

### 4. Vista de error / fallback

Objetivo:

- capturar errores de red, auth caducada o configuracion.

Mensajes:

- no autenticado,
- operacion no autorizada,
- problema de conexion,
- error inesperado.

## Componentes clave

- `AuthForm`
- `AppHeader`
- `TaskSummary`
- `TaskFilters`
- `TaskList`
- `TaskItem`
- `TaskFormModal` o `TaskFormPanel`
- `EmptyState`
- `ErrorBanner`

## Flujos principales

### Flujo 1: alta de usuario

1. Usuario abre la app.
2. Completa email y password.
3. Sistema registra y crea sesion.
4. Sistema crea perfil si aplica.
5. Redireccion a dashboard vacio.

### Flujo 2: crear primera tarea

1. Usuario autenticado entra al dashboard.
2. Pulsa nueva tarea.
3. Completa titulo y opcionales.
4. Guarda.
5. Lista se actualiza mostrando la nueva tarea.

### Flujo 3: completar tarea

1. Usuario identifica una tarea pendiente.
2. Marca como completada.
3. UI actualiza estado y contadores.

### Flujo 4: logout

1. Usuario pulsa logout.
2. Sesion se invalida en cliente.
3. Redireccion a pantalla de auth.

## Reglas de UX

- El estado de autenticacion decide el routing principal.
- El CTA primario en dashboard es crear tarea.
- Las tareas completadas deben seguir visibles al menos bajo filtro.
- Los errores deben ser accionables y no genericos cuando sea posible.

## Validaciones de UI

- No mostrar tareas antiguas de otro usuario tras cambio de sesion.
- Refrescar estado local despues de create, update y delete.
- Proteger rutas privadas frente a sesion nula o expirada.

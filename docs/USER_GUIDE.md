# Guia de uso

## Que es P4 To-Do App

P4 es una aplicacion de tareas personales con tablero visual. Cada usuario ve solo sus propios datos.

## Que puede hacer un usuario

- Crear una cuenta
- Iniciar sesion
- Crear tareas
- Editar tareas
- Mover tareas entre columnas
- Marcar tareas como completadas
- Borrar tareas

## Como usar la app

### 1. Acceso

- Entra con tu correo y contrasena
- Si no tienes cuenta, usa la pestaña de registro

### 2. Crear una tarea

- Pulsa `Anadir tarea` o `+ Anadir nueva tarea`
- Completa titulo, descripcion opcional, prioridad y fecha limite
- Guarda los cambios

### 3. Editar una tarea

- Haz clic sobre una tarjeta
- Modifica los campos desde el editor lateral
- Pulsa `Guardar cambios`

### 4. Mover tareas

- Arrastra una tarjeta entre columnas
- El sistema actualiza su prioridad o su estado segun la columna de destino

## Significado de columnas

- `Alta`: tareas pendientes con mayor prioridad
- `Media`: tareas pendientes con prioridad media
- `Baja`: tareas pendientes con prioridad baja
- `Hechas`: tareas completadas

## Privacidad y seguridad

- Cada usuario solo puede ver sus tareas
- La seguridad se aplica desde la base de datos con RLS
- Cerrar sesion elimina el acceso al tablero privado

## Problemas comunes

### No puedo entrar

- Revisa correo y contrasena
- Verifica que el usuario exista en Supabase Auth

### No veo mis tareas

- Comprueba que la sesion sigue activa
- Revisa que la app apunte al proyecto Supabase correcto

### No me deja mover una tarjeta

- Revisa la conexion con Supabase
- Comprueba que las politicas RLS sigan activas

## Soporte tecnico

Para configuracion, despliegue o seguridad, consulta:

- [README.md](/Users/sandra/Documents/CodeIA/Clases/Clase%209%20-%20To-do/README.md)
- [docs/p4/README.md](/Users/sandra/Documents/CodeIA/Clases/Clase%209%20-%20To-do/docs/p4/README.md)

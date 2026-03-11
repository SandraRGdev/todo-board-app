# Scope MVP

## Objetivo

Entregar una To-Do App multiusuario simple donde cada usuario autenticado pueda gestionar solo sus propias tareas, con alta trazabilidad de acceso y un flujo de despliegue reproducible.

## Problema a resolver

Un usuario necesita:

- registrarse o iniciar sesion,
- crear tareas personales,
- editar el contenido y estado de sus tareas,
- filtrar rapidamente sus pendientes y completadas,
- confiar en que nadie mas puede ver o modificar sus datos.

## Alcance incluido

### Producto

- Registro e inicio de sesion por email y password.
- Sesion persistente en cliente.
- Logout.
- Listado de tareas del usuario autenticado.
- Crear tarea.
- Editar titulo, descripcion corta, prioridad y fecha limite.
- Marcar tarea como completada o pendiente.
- Eliminar tarea.
- Filtrar por estado: todas, pendientes, completadas.
- Orden basico por fecha de creacion o vencimiento.
- Estados vacios, carga y error.

### Plataforma

- Base de datos en Supabase.
- Auth de Supabase.
- RLS habilitado en tablas de datos de usuario.
- Variables de entorno separadas por entorno.
- Despliegue del frontend en Vercel.
- Entorno Preview y Production.

## Alcance excluido

- Colaboracion entre usuarios.
- Compartir tareas o listas.
- Roles administrativos.
- Adjuntos.
- Comentarios.
- Notificaciones push o email.
- Subtareas.
- Etiquetas complejas.
- Offline-first.
- App movil nativa.
- Analitica avanzada.

## Supuestos

- El MVP opera con un unico tipo de usuario final.
- El canal principal de autenticacion es email/password.
- Cada tarea pertenece a un solo usuario.
- No hay necesidad de exponer claves de servicio al frontend.
- El equipo acepta iterar luego sobre UX y observabilidad.

## KPIs de MVP

- Un usuario nuevo puede registrarse y crear su primera tarea en menos de 2 minutos.
- El 100% de lecturas y escrituras de tareas quedan limitadas al propietario mediante RLS.
- El deploy a Vercel puede ejecutarse sin cambios manuales de codigo.

## Riesgos principales

- Mala configuracion de RLS que exponga datos entre usuarios.
- Desalineacion entre el modelo de datos y la UI del MVP.
- Variables de entorno inconsistentes entre local, preview y production.
- Dependencia excesiva del cliente para validaciones.

## Mitigaciones

- Definir pruebas explicitas de acceso permitido y denegado para RLS.
- Mantener el modelo de datos minimo y orientado al MVP.
- Documentar contratos de datos y estados de UI antes de implementar.
- Separar claramente claves anonimas y claves de servicio.

## Criterios de aceptacion

- Usuario no autenticado no puede acceder al area privada.
- Usuario autenticado puede crear, ver, editar y eliminar solo sus tareas.
- Cambios de estado se reflejan sin recargar toda la aplicacion.
- La app desplegada en Vercel funciona contra Supabase en produccion.
- Existe checklist de validacion post-deploy y rollback operativo.

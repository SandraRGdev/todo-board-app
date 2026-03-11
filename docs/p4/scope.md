# Alcance MVP

## Objetivo

Definir el alcance minimo viable de la To-Do App para validar que un usuario autenticado puede gestionar sus tareas personales de forma segura, simple y desplegable en produccion.

## Problema a resolver

El producto debe permitir que una persona:

- cree una cuenta o inicie sesion,
- registre tareas personales,
- consulte su lista de tareas,
- actualice el estado o contenido de una tarea,
- elimine tareas que ya no necesita,
- confie en que sus datos estan aislados de otros usuarios.

## User stories MVP

### Auth

- Como usuario nuevo, quiero registrarme con email y password para empezar a usar la app.
- Como usuario existente, quiero iniciar sesion para acceder a mis tareas.
- Como usuario autenticado, quiero cerrar sesion para proteger mi cuenta en dispositivos compartidos.

### Gestion de tareas

- Como usuario autenticado, quiero crear una tarea con un titulo para registrar algo pendiente.
- Como usuario autenticado, quiero ver mi lista de tareas para saber que tengo pendiente.
- Como usuario autenticado, quiero editar una tarea para corregir o completar informacion.
- Como usuario autenticado, quiero marcar una tarea como completada para distinguir lo resuelto.
- Como usuario autenticado, quiero eliminar una tarea para mantener mi lista limpia.

### Navegacion y feedback

- Como usuario autenticado, quiero ver estados de carga para entender que la app esta procesando datos.
- Como usuario autenticado, quiero ver mensajes de error claros para saber como reaccionar si algo falla.
- Como usuario autenticado, quiero ver un estado vacio cuando no tengo tareas para entender el siguiente paso.

## Alcance funcional incluido

- Registro por email y password.
- Login por email y password.
- Persistencia de sesion.
- Logout.
- Listado de tareas propias.
- Crear tarea.
- Editar titulo, descripcion, prioridad y fecha limite.
- Marcar tarea como completada o pendiente.
- Eliminar tarea.
- Filtrar por estado: todas, pendientes y completadas.
- Estados visuales de `loading`, `error` y `empty`.

## Definition of Done

## Done del MVP de producto

- Un usuario nuevo puede registrarse y crear su primera tarea.
- Un usuario autenticado puede ver solo sus tareas.
- El usuario puede completar el flujo CRUD basico sin salir del area privada.
- La aplicacion ofrece feedback visible ante carga, error y ausencia de datos.

## Done tecnico

- Vue 3 integrado con Supabase Auth y base de datos.
- RLS activo en tablas de negocio.
- Ninguna operacion del frontend depende de `service_role_key`.
- Variables de entorno separadas para local, preview y production.
- La app despliega correctamente en Vercel.

## Done de validacion

- Probado con al menos dos usuarios distintos.
- Validado que un usuario no puede leer ni modificar tareas de otro.
- Confirmado que login, logout y persistencia de sesion funcionan.
- Confirmado que create, read, update y delete funcionan desde la UI.

## No-scope

- Compartir tareas entre usuarios.
- Listas colaborativas.
- Roles administrativos.
- Subtareas.
- Etiquetas avanzadas.
- Comentarios.
- Adjuntos.
- Notificaciones email o push.
- App movil nativa.
- Offline mode.
- Analitica avanzada.
- Integraciones con terceros.

## Riesgos principales

- Configuracion incorrecta de RLS que exponga datos entre usuarios.
- Desajuste entre el contrato de datos y la UI implementada.
- Errores de sesion al recargar o cambiar de usuario.
- Variables de entorno mal configuradas en Vercel.
- Dependencia excesiva del cliente para validar ownership.

## Mitigaciones

- Probar accesos permitidos y denegados con dos cuentas reales.
- Mantener el modelo de datos reducido y centrado en ownership por `user_id`.
- Centralizar el manejo de sesion y limpiar estado local en logout.
- Documentar y revisar variables de entorno antes del deploy.
- Hacer que la seguridad dependa de RLS y no del frontend.

## Metricas simples

- Tiempo a primera tarea:
  desde que un usuario abre la app por primera vez hasta que crea exitosamente su primera tarea.
  Objetivo: menos de 2 minutos.

- Tasa de exito de registro:
  porcentaje de usuarios de prueba que completan registro sin bloqueo.
  Objetivo: al menos 90% en pruebas internas.

- Tasa de exito de login:
  porcentaje de intentos validos que terminan en acceso al dashboard.
  Objetivo: 100% en pruebas controladas.

- Exito CRUD:
  porcentaje de operaciones create, update y delete que finalizan sin error en pruebas funcionales.
  Objetivo: al menos 95% en entorno preview.

- Aislamiento de datos:
  porcentaje de pruebas de acceso cruzado correctamente denegadas.
  Objetivo: 100%.

## Criterios de aceptacion finales

- Usuario anonimo no accede al dashboard privado.
- Usuario autenticado solo ve y modifica sus propios datos.
- Existe al menos una ruta clara para crear la primera tarea desde estado vacio.
- Los errores de auth y datos son visibles y comprensibles.
- El MVP puede desplegarse y validarse en Vercel sin pasos manuales ambiguos.

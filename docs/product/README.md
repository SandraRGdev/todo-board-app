# README de producto

To-Do App MVP con Vue 3 en frontend, Supabase para Auth y Postgres, y despliegue en Vercel.

Este README esta orientado a operacion de proyecto: configuracion de entorno, validacion de seguridad con RLS, despliegue y troubleshooting.

## Stack

- Frontend: Vue 3
- Backend gestionado: Supabase
- Base de datos: Postgres
- Seguridad de datos: Row Level Security
- Hosting: Vercel

## Variables de entorno

## Variables minimas requeridas

- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`

## Criterios de configuracion

- La URL y la anon key deben pertenecer al mismo proyecto de Supabase.
- Las variables deben existir en local, preview y production.
- El frontend solo debe usar la `anon key`.
- No exponer `SUPABASE_SERVICE_ROLE_KEY` en codigo cliente ni en variables del frontend.

## Validacion rapida de entorno

- La aplicacion debe iniciar sin errores de configuracion.
- Login y registro deben conectar contra el proyecto correcto.
- El dashboard debe leer datos del mismo entorno esperado.
- Preview y Production no deben mezclar credenciales entre si.

## Como validar que RLS funciona

## Objetivo

Confirmar que cada usuario solo puede operar sobre sus propias filas en `public.todos`.

## Preparacion

- Tener RLS activado en la tabla `todos`.
- Tener politicas para `SELECT`, `INSERT`, `UPDATE` y `DELETE`.
- Contar con dos usuarios reales de prueba: Usuario A y Usuario B.

## Pruebas minimas

### Lectura

- Inicia sesion con Usuario A.
- Crea una o varias tareas.
- Inicia sesion con Usuario B.
- Verifica que Usuario B no ve las tareas de Usuario A.

### Insercion

- Con Usuario A autenticado, crea una tarea.
- Verifica que se guarda correctamente y queda asociada a A.
- Intenta reproducir una insercion con ownership ajeno.
- Verifica que la base de datos la deniega.

### Actualizacion

- Usuario A actualiza una tarea propia y el cambio debe funcionar.
- Usuario B no debe poder editar esa misma tarea.

### Borrado

- Usuario A puede borrar una tarea propia.
- Usuario B no puede borrar tareas de Usuario A.

## Señales de que RLS esta bien configurado

- Los listados devuelven solo filas del usuario autenticado.
- Las operaciones cruzadas entre usuarios fallan.
- El frontend funciona con `anon key` sin privilegios administrativos.

## Señales de riesgo

- Un usuario ve datos que no creo.
- Las politicas solo cubren `SELECT` pero no escritura.
- El frontend usa credenciales con privilegios altos.
- El ownership depende de logica visual y no de base de datos.

Documentacion relacionada:

- [security_rls.md](./security_rls.md)
- [data_model.md](./data_model.md)

## Deploy en Vercel

## Preparacion previa

- El proyecto Vue 3 compila correctamente.
- Supabase esta configurado y accesible.
- Las politicas RLS ya estan activas.
- Las variables de entorno estan listas para cada entorno.

## Flujo recomendado

1. Conectar el repositorio a Vercel.
2. Confirmar el preset de framework correcto para Vue.
3. Configurar variables de entorno de Preview y Production.
4. Ejecutar un primer deploy de Preview.
5. Validar login, lectura de tareas y CRUD basico en Preview.
6. Promover a Production cuando la validacion funcional y de seguridad sea correcta.

## Validaciones post-deploy

- La URL publicada carga sin errores criticos.
- Registro y login funcionan en el dominio desplegado.
- La sesion persiste tras refrescar.
- El dashboard muestra solo tareas del usuario autenticado.
- Create, update y delete funcionan en el entorno publicado.
- Logout limpia el acceso al area privada.

## Checklist de troubleshooting

## Problemas de entorno

- La app no conecta con Supabase:
  revisar `VITE_SUPABASE_URL` y `VITE_SUPABASE_ANON_KEY`.

- Login falla en todos los entornos:
  revisar proveedor de email/password en Supabase y variables cargadas.

- Preview funciona pero Production no:
  comparar variables de entorno entre ambos entornos.

## Problemas de seguridad

- Un usuario ve tareas de otro:
  revisar RLS activado y politicas de `SELECT`.

- Se puede editar o borrar informacion ajena:
  revisar politicas de `UPDATE` y `DELETE`.

- Se pueden crear filas con `user_id` ajeno:
  revisar politica de `INSERT` con `with check`.

## Problemas de sesion

- La app pierde sesion al refrescar:
  revisar hidratacion de sesion en cliente.

- Logout no limpia correctamente la UI:
  revisar limpieza de estado local y redireccion.

- Cambio de usuario muestra datos stale:
  revisar invalidacion o refresco de la lista tras cambio de sesion.

## Problemas de deploy

- Build falla en Vercel:
  revisar configuracion del framework, comando de build y variables requeridas.

- Auth funciona en local pero no en dominio desplegado:
  revisar URLs de redireccion autorizadas en Supabase.

- La app apunta al proyecto equivocado:
  revisar que la URL y la anon key correspondan al mismo proyecto.

## Documentos de soporte

- [scope.md](./scope.md)
- [integration_plan.md](./integration_plan.md)
- [05-integration-plan.md](./05-integration-plan.md)
- [06-deploy-checklist.md](./06-deploy-checklist.md)
- [security_rls.md](./security_rls.md)
- [data_model.md](./data_model.md)

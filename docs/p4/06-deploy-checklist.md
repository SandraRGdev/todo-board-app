# Checklist de Deploy

## Pre-requisitos

- Proyecto Vue 3 compila localmente.
- Proyecto Supabase creado.
- Tablas y politicas RLS aplicadas.
- Variables de entorno identificadas por entorno.
- Cuenta de Vercel operativa.

## Variables de entorno

### Local

- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`

### Preview en Vercel

- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`

### Production en Vercel

- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`

Validaciones:

- La URL apunta al proyecto correcto.
- La anon key corresponde al mismo proyecto.
- No existe `SERVICE_ROLE_KEY` en variables del frontend.

## Checklist de configuracion

- Repositorio conectado a Vercel.
- Framework preset correcto para Vue.
- Comando de build validado.
- Directorio de salida validado.
- Dominio de preview operativo.
- Dominio de production definido si aplica.

## Checklist de seguridad

- RLS activo en tablas de negocio.
- Politicas de `select`, `insert`, `update`, `delete` revisadas.
- Email/password habilitado en Supabase Auth.
- URLs de redireccion autorizadas en Supabase para local, preview y production.
- Claves usadas en frontend limitadas a las publicas.

## Checklist funcional pre-release

- Registro de usuario funciona.
- Login funciona.
- Logout funciona.
- Crear tarea funciona.
- Editar tarea funciona.
- Completar tarea funciona.
- Eliminar tarea funciona.
- Filtros basicos funcionan.
- Usuario A no puede ver tareas de usuario B.

## Checklist post-deploy

- Abrir la URL publicada.
- Confirmar carga inicial sin errores de consola criticos.
- Crear un usuario de prueba.
- Iniciar sesion con un usuario existente.
- Crear y completar una tarea.
- Recargar la pagina y verificar persistencia de sesion.
- Cerrar sesion y confirmar redireccion.
- Revisar logs de Vercel y Supabase.

## Rollback

- Mantener disponible el ultimo deployment estable de Vercel.
- Si falla solo el frontend, promover el deployment anterior.
- Si falla una migracion o politica, revertir cambios de base de datos antes de reactivar trafico.
- Registrar incidente con causa, impacto y fix.

## Criterio de salida

El deploy se considera aceptado cuando:

- los flujos criticos de auth y CRUD pasan en production,
- la separacion de datos por usuario queda verificada,
- no hay secretos expuestos en cliente,
- existe un camino claro de rollback.

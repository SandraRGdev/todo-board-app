# Plan de Integracion

## Objetivo

Conectar Vue 3 con Supabase Auth y Postgres de forma incremental, verificando seguridad y comportamiento en cada fase.

## Fases

### Fase 1. Base del frontend

Entregables:

- proyecto Vue 3 inicializado,
- estructura de rutas,
- layout minimo,
- gestion del estado de sesion.

Validaciones:

- la app arranca localmente,
- existe una ruta publica y una privada,
- la sesion se hidrata al recargar.

### Fase 2. Integracion con Supabase Auth

Entregables:

- cliente Supabase configurado con URL y anon key,
- login,
- registro,
- logout,
- guardas de rutas privadas.

Validaciones:

- login correcto con usuario valido,
- error controlado con credenciales invalidas,
- logout limpia estado local,
- usuario anonimo no entra al dashboard.

### Fase 3. Modelo de datos y migraciones

Entregables:

- tablas `profiles` y `tasks`,
- constraints basicos,
- indices requeridos,
- timestamps operativos.

Validaciones:

- migraciones aplican en entorno objetivo,
- inserts invalidos fallan por constraint,
- una tarea siempre tiene `user_id`.

### Fase 4. RLS y pruebas de acceso

Entregables:

- RLS habilitado,
- politicas por operacion,
- pruebas manuales de acceso permitido y denegado.

Validaciones:

- usuario A no ve datos de B,
- inserts con ownership incorrecto fallan,
- UI maneja errores de autorizacion.

### Fase 5. CRUD de tareas

Entregables:

- listado,
- crear,
- editar,
- completar,
- eliminar,
- filtros por estado.

Validaciones:

- la lista refleja cambios sin inconsistencias visibles,
- el dashboard soporta estados vacios y de carga,
- `updated_at` cambia en cada edicion.

### Fase 6. Hardening y deploy

Entregables:

- variables de entorno documentadas,
- proyecto conectado a Vercel,
- preview deployment operativo,
- checklist post-deploy ejecutado.

Validaciones:

- la build pasa,
- el dominio de Vercel puede autenticarse contra Supabase,
- produccion usa las variables correctas.

## Contratos entre capas

### Frontend -> Auth

- Usa cliente Supabase con credenciales publicas.
- Escucha cambios de sesion.
- No almacena secretos sensibles fuera de la sesion gestionada.

### Frontend -> Data

- Opera solo sobre `tasks` del usuario autenticado.
- No envia `user_id` editable desde formularios visibles.
- Trata respuestas vacias y errores como estados de UI definidos.

### Plataforma -> Frontend

- Expone `SUPABASE_URL`.
- Expone `SUPABASE_ANON_KEY`.
- Nunca expone `SUPABASE_SERVICE_ROLE_KEY`.

## Variables de entorno minimas

- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`

## Riesgos de integracion

- Mismatch entre nombres de columnas y DTOs del frontend.
- Sesion no sincronizada al refrescar pagina.
- Variables de entorno mal cargadas en Vercel.
- Dependencia en permisos de cliente en vez de RLS.

## Orden recomendado de trabajo

1. Inicializar Vue 3 y routing.
2. Conectar cliente Supabase.
3. Habilitar Auth.
4. Crear modelo de datos.
5. Activar y probar RLS.
6. Implementar CRUD.
7. Preparar deploy y validar preview.

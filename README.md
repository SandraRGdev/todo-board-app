# To-Do Board App

Aplicacion MVP de gestion de tareas construida con Vue 3, Supabase y Vercel.

## Stack

- Vue 3 + Vite
- Supabase Auth
- Supabase Postgres
- Row Level Security
- Vercel para despliegue

## Funcionalidades

- Registro e inicio de sesion con email y contrasena
- Persistencia de sesion
- Tablero visual por columnas
- Crear, editar, mover y borrar tareas
- Drag and drop entre columnas
- Proteccion de datos por usuario con RLS

## Requisitos

- Node.js 18 o superior
- npm 10 o superior
- Proyecto de Supabase configurado

## Variables de entorno

Copia `.env.example` a `.env` y completa los valores:

- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_PUBLISHABLE_KEY`
- `VITE_SUPABASE_ANON_KEY`

Notas:

- El frontend usa la clave publica.
- No expongas `SUPABASE_SERVICE_ROLE_KEY` en cliente.
- `VITE_SUPABASE_PUBLISHABLE_KEY` es la opcion recomendada.
- `VITE_SUPABASE_ANON_KEY` queda por compatibilidad.

## Arranque local

1. Instala dependencias con `npm install`
2. Completa `.env`
3. Arranca el entorno local con `npm run dev`
4. Abre `http://localhost:5173`

## Build de produccion

- `npm run build`
- `npm run preview`

## Estructura principal

- [src/App.vue](./src/App.vue): UI principal, auth y CRUD
- [src/lib/supabase.js](./src/lib/supabase.js): cliente de Supabase
- [supabase/migrations/20260311100500_todos_init.sql](./supabase/migrations/20260311100500_todos_init.sql): tabla `todos`, indices y RLS
- [docs/product/README.md](./docs/product/README.md): documentacion funcional y operativa

## Seguridad

- La tabla `public.todos` esta protegida con RLS
- Cada fila queda limitada a `user_id = auth.uid()`
- El cliente no debe usar credenciales administrativas

## Documentacion para usuarios y colaboradores

- [docs/USER_GUIDE.md](./docs/USER_GUIDE.md)
- [docs/product/scope.md](./docs/product/scope.md)
- [docs/product/data_model.md](./docs/product/data_model.md)
- [docs/product/security_rls.md](./docs/product/security_rls.md)
- [docs/product/06-deploy-checklist.md](./docs/product/06-deploy-checklist.md)

## Estado de version

Version actual: `0.1.0`

# Deploy en Dockploy

## Objetivo

Desplegar la app en tu VPS usando Dockploy como contenedor Docker servido con Nginx.

## Estrategia de despliegue

La app es un frontend estatico:

- se construye con `npm run build`
- se sirve con Nginx
- puede leer variables `VITE_...` en runtime desde el contenedor

Por eso, en Dockploy conviene desplegarla desde `Dockerfile`, no como proceso Node persistente.

## Archivos usados

- [Dockerfile](../Dockerfile)
- [nginx.conf](../nginx.conf)
- [.dockerignore](../.dockerignore)

## Variables necesarias en Dockploy

Define estas variables en el servicio:

- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_PUBLISHABLE_KEY`
- `VITE_SUPABASE_ANON_KEY`

Notas:

- `VITE_SUPABASE_PUBLISHABLE_KEY` es la preferida.
- `VITE_SUPABASE_ANON_KEY` se mantiene por compatibilidad.
- No cargues `SUPABASE_SERVICE_ROLE_KEY`.
- Tras cambiar variables, haz `redeploy` con rebuild del contenedor.

## Configuracion recomendada en Dockploy

### Tipo de despliegue

- Repositorio Git
- Build desde `Dockerfile`

### Rama

- `main`

### Puerto expuesto

- contenedor: `80`

### Dominio

- asigna tu dominio o subdominio en Dockploy
- activa HTTPS con el flujo habitual del panel

## Flujo recomendado

1. Crear una nueva app en Dockploy.
2. Conectar el repositorio `todo-board-app`.
3. Seleccionar despliegue por `Dockerfile`.
4. Configurar variables `VITE_...`.
5. Exponer el puerto `80`.
6. Lanzar el primer deploy.
7. Validar login, carga de tablero y CRUD.

## Validaciones post-deploy

- La home carga sin 404 de assets.
- El login funciona.
- El registro funciona si esta habilitado en Supabase.
- El tablero carga datos del usuario autenticado.
- El drag and drop sigue persistiendo cambios.
- Refrescar una ruta no rompe la SPA.

## Riesgos tipicos

- Variables `VITE_...` ausentes al hacer build.
- App apuntando a un proyecto Supabase incorrecto.
- Dominio no autorizado en Supabase Auth.
- Build hecha con secretos o claves equivocadas.

## Checklist rapido

- `Dockerfile` presente
- `nginx.conf` presente
- variables `VITE_...` cargadas
- puerto `80` publicado
- dominio agregado en Supabase Auth como redirect permitido
- deploy verificado desde navegador real

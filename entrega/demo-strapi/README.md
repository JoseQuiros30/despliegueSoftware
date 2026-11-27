# demo-strapi · Actividad 5

Esta aplicación parte del repositorio original `cms-strapi-gcp` (commit
`a9b7e50`). Conserva Strapi 5.61.0, TypeScript, la configuración y el modelo
**Artículo** con título, slug, resumen, contenido en bloques y las categorías
`noticias`, `tutoriales` e `institucional`. Consulta
[`ORIGEN_CODIGO.md`](ORIGEN_CODIGO.md) para ver las adaptaciones.

## Ejecutar y validar localmente

Requiere Node.js 22 y npm. SQLite se usa únicamente en local.

```bash
npm ci
npm run setup
npm run lint
npm test
npm run build
npm run start
```

Abre `http://localhost:1337/admin` y crea el administrador. Para comprobar la
API y la conexión a la base:

```bash
curl -fsS http://localhost:1337/api/health
SERVICE_URL=http://localhost:1337 npm run smoke
```

El script `setup` genera un `.env` local con claves aleatorias. Las rutas
`GET /api/articulos` y `GET /api/articulos/:documentId` publican únicamente
artículos publicados; crear y editar contenido exige acceso al panel.

## Despliegue

El `Dockerfile` usa Node 22 y construye el panel. En Cloud Run, PostgreSQL se
conecta mediante Cloud SQL y los archivos de `public/uploads` se conservan en un
bucket privado de Cloud Storage montado en ese directorio. El montaje requiere
la identidad de ejecución de Terraform y se debe comprobar con una carga real
después del aprovisionamiento.

`cloudbuild.yaml` valida PR sin publicar; `main` construye, publica la imagen
por SHA, despliega por digest y verifica `/api/health`. Si falla el smoke test,
devuelve el tráfico a la revisión anterior. La guía de implementación está en
`../documentacion/GUIA_INTERACTIVA.html`.

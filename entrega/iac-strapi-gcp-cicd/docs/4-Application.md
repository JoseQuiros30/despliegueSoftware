# 4. Aplicación

`demo-strapi` contiene Strapi 5.61.0, Node 22, modelo Artículo y un endpoint
`GET /api/health` sin autenticación. El health ejecuta `SELECT 1` para detectar
fallos de base de datos y muestra el SHA integrado en la imagen. El panel se sirve
en `/admin`. Strapi usa SQLite local y PostgreSQL en Cloud Run según
`DATABASE_CLIENT`.

La aplicación parte de `cms-strapi-gcp` (commit `a9b7e50`): conserva su
TypeScript, dependencias y esquema de Artículo. Las adaptaciones están
registradas en `demo-strapi/ORIGEN_CODIGO.md`.

Las rutas `find` y `findOne` permiten lectura anónima, y el controlador fuerza
`published` para evitar exponer borradores. La edición y publicación siguen
requiriendo administrador. Los archivos cargados se conservan mediante un bucket
privado montado en `public/uploads`; la carga real en Cloud Run se verifica tras
el despliegue.

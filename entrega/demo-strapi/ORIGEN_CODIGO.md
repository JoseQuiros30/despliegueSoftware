# Trazabilidad del código Strapi

Fuente: `../../cms-strapi-gcp`, commit `a9b7e50` (*Prepare Strapi CMS for Google
Cloud deployment*). El proyecto original no se modificó.

Se copiaron su `package.json`, `package-lock.json`, `tsconfig.json`, carpetas
`config/`, `src/`, `types/`, `public/` y `database/`, junto con los archivos de
imagen y Docker. El subdirectorio original `terraform/` quedó como referencia;
la IaC completa se entrega por separado en `../iac-strapi-gcp-cicd/`.

Cambios en esta entrega:

- El modelo `src/api/articulo/content-types/articulo/schema.json` mantiene los
  campos, reglas y categorías originales.
- La ruta y el controlador de `articulo` permiten lectura anónima solo de
  publicaciones, sin abrir permisos de escritura.
- `config/server.ts` reconoce `PUBLIC_URL` y el proxy HTTPS de Cloud Run.
- `config/database.ts` limita el pool de PostgreSQL para una instancia pequeña
  de Cloud SQL y resuelve correctamente rutas absolutas de SQLite en las pruebas.
- Se añadió `GET /api/health`, que comprueba `SELECT 1` y expone la revisión.
- Se añadieron scripts de validación, pruebas, Docker y Cloud Build para la
  Actividad 5.
- Terraform monta Cloud Storage en `public/uploads` para conservar archivos.

# 5. Datos

Cloud SQL PostgreSQL 16, tier `db-f1-micro`, 10 GiB HDD, zona única, sin backup
automático y sin protección de eliminación: configuración académica temporal de
costo bajo. **No es adecuada para datos de producción.** La cuenta `strapi` tiene
su contraseña en Secret Manager, pero Terraform mantiene una copia sensible en el
estado al crear el usuario y la versión del secreto. Proteger el estado GCS y su
bootstrap local es obligatorio.

Los artículos y usuarios sobreviven a nuevas revisiones de Cloud Run porque se
guardan en SQL. SQLite solo se usa en el equipo local. Antes de eliminar recursos,
exportar el contenido necesario desde Strapi o una copia SQL. Los uploads se
conservan en un bucket independiente, privado y montado en Cloud Run. El bucket
impide `terraform destroy` si contiene archivos, hasta vaciarlo manualmente.

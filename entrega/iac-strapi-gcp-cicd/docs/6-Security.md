# 6. Seguridad

| Identidad | Permisos |
|---|---|
| Cloud Build | `run.developer`, `logging.logWriter`, lectura de fuente GCS y escritura del repositorio Artifact Registry |
| Cloud Build sobre SA runtime | `iam.serviceAccountUser` solo en esa cuenta |
| Cloud Run | `cloudsql.client` y acceso por secreto a siete secretos |
| Público | `run.invoker` para la URL del CMS; Strapi protege el panel |

Los secretos se generan con `random_password` y quedan en estado Terraform.
`bootstrap/terraform.tfstate`, `infra/terraform.tfstate`, `.env` y `*.tfvars`
reales nunca deben publicarse. El bucket de estado es privado, uniforme y
versionado. Cloud SQL tiene IP pública para el proxy integrado; no se configuran
redes autorizadas ni se publica la contraseña. El tráfico de usuarios usa HTTPS
nativo de Cloud Run.

Antes de publicar, crear el administrador con contraseña fuerte y verificar que
solo se publiquen artículos, nunca borradores. Una política de organización que impida
`allUsers` bloqueará el acceso público; en ese caso hay que adaptar la política
de acceso antes del despliegue.

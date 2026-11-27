# iac-strapi-gcp-cicd

Infraestructura Terraform de Strapi para GCP. `bootstrap/` crea APIs, bucket privado
y versionado para el estado, Artifact Registry, cuenta de Cloud Build y triggers de
aplicación. `infra/` crea Cloud SQL PostgreSQL, secretos, Cloud Run, bucket de
uploads y observabilidad.

**Estado actual:** bootstrap e infra aplicados en
`project-792d22c1-bc11-403b-96c`. Cloud Run y Cloud SQL están listos; la
prueba de PR/main y la eliminación quedan pendientes.

## Orden de despliegue

1. Crear proyecto GCP, vincular facturación y conectar `JoseQuiros30/despliegueSoftware` con Cloud Build 2nd gen.
2. Completar `bootstrap/terraform.tfvars` y aplicar bootstrap tras revisar costos.
3. Construir y publicar manualmente la imagen inicial `:bootstrap` con `_DEPLOY=seed`.
4. Completar `infra/env/prod.tfvars`, iniciar backend GCS, planificar y aplicar infra.
5. Verificar `/api/health`, Strapi y el dashboard; luego hacer push a `main`.

El backend GCS se configura con `terraform init -reconfigure -backend-config="bucket=..."
-backend-config="prefix=strapi-a5/infra"`; no hay ID de proyecto del profesor en el
código. Revisar siempre el plan y el presupuesto antes de aplicar cambios;
al terminar la demostración, seguir la guía de eliminación en
`../documentacion/GUIA_ELIMINACION_RECURSOS.md`.

Documentación: [arquitectura](docs/1-Architecture.md),
[infraestructura](docs/2-Infrastructure.md), [CI/CD](docs/3-CI-CD.md),
[aplicación](docs/4-Application.md), [datos](docs/5-Data.md),
[seguridad](docs/6-Security.md) y [observabilidad](docs/7-Observability.md).

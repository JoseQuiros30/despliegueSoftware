# Revisión de requisitos

| Requisito | Implementación | Estado antes de GCP |
|---|---|---|
| Terraform modular | `bootstrap/`, `infra/modules/` | Validado localmente |
| Servicio contenerizado | Dockerfile Strapi + Cloud Run | Build local de Strapi; imagen Docker pendiente |
| Base relacional administrada | Cloud SQL PostgreSQL 16, DB y usuario | Definida; despliegue pendiente |
| CI/CD Opción A | Cloud Build PR/main, `_DEPLOY`, digest, smoke y rollback | Definido; trigger real pendiente |
| Estado remoto | Bucket GCS privado y versionado | Definido; creación pendiente |
| Medios persistentes | Bucket privado y montaje GCS FUSE en `public/uploads` | Terraform válido; carga cloud pendiente |
| Secretos e IAM | Secret Manager, cuentas y permisos | Definido; verificación GCP pendiente |
| Observabilidad IaC | Dashboard, uptime, 7 alertas, logs | Validado Terraform; señales reales pendientes |
| CMS y Artículo | Strapi 5 TypeScript desde `cms-strapi-gcp` | Publicación, borrador y permisos HTTP validados localmente |
| Persistencia entre revisiones | PostgreSQL externo al contenedor | Prueba cloud pendiente |
| Evidencias reales | `evidencias/` y checklist | Capturas de GCP pendientes |

**Validaciones ejecutadas:** `npm ci`, `npm run lint`, `npm test`, `npm run build`,
pruebas HTTP locales, `terraform fmt -check -recursive` y `terraform validate`
en bootstrap e infra. El detalle está en `../evidencias/VALIDACIONES_LOCALES.md`. No se
ejecutaron `terraform plan` con credenciales, `apply`, `destroy`, builds GCP ni
pruebas de Cloud SQL ni de GCS FUSE. La construcción Docker local sigue pendiente
porque Docker no está instalado en este equipo.

**Comparación con el profesor:** se mantiene la separación de carpetas
bootstrap/infra, los triggers PR/main, la variable `_DEPLOY`, el deploy por digest
y rollback. Se cambia WordPress/PHP/MySQL por Strapi/Node/PostgreSQL y se retiran
Valkey, NAT, VPC y LB. El HTTPS nativo de Cloud Run sustituye el HTTP del LB
de referencia. La métrica SQL de conexiones se cambia a `postgresql/num_backends`.

**Comparación con el Strapi original:** el esquema Artículo y las versiones de
dependencias se conservaron exactamente desde el commit `a9b7e50`. Se añadieron
health, lectura pública controlada, CI/CD y montaje persistente de medios. El
original permanece sin cambios (`git status --porcelain` vacío).

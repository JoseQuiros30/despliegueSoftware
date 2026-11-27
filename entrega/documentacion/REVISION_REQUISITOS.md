# Revisión de requisitos

| Requisito | Implementación | Estado verificado en GCP |
|---|---|---|
| Terraform modular | `bootstrap/`, `infra/modules/` | Ambos `apply` completados; corrección del filtro de logs aplicada |
| Servicio contenerizado | Dockerfile Strapi + Cloud Run | Imagen construida en Cloud Build; revisión `Ready`; health HTTPS 200 |
| Base relacional administrada | Cloud SQL PostgreSQL 16, DB y usuario | Instancia `strapi-a5-pg-496f8a` `RUNNABLE`; API responde |
| CI/CD Opción A | Cloud Build PR/main, `_DEPLOY`, digest, smoke y rollback | Triggers creados; build inicial exitoso; prueba PR/main pendiente |
| Estado remoto | Bucket GCS privado y versionado | Creado y utilizado por Terraform infra |
| Medios persistentes | Bucket privado y montaje GCS FUSE en `public/uploads` | Imagen y variantes presentes en GCS; URL HTTPS respondió 200 |
| Secretos e IAM | Secret Manager, cuentas y permisos | Creados por Terraform; acceso de ejecución comprobado al arrancar |
| Observabilidad IaC | Dashboard, uptime, 7 alertas, logs | Recursos creados; revisar señales del tráfico real |
| CMS y Artículo | Strapi 5 TypeScript desde `cms-strapi-gcp` | Artículo publicado en GCP y visible en la API pública |
| Persistencia entre revisiones | PostgreSQL externo al contenedor | Prueba entre dos revisiones pendiente |
| Evidencias reales | `evidencias/` y checklist | Build inicial capturado; demás pantallas pendientes |

**Validaciones ejecutadas:** `npm ci`, `npm run lint`, `npm test`, `npm run build`,
pruebas HTTP locales, `terraform fmt -check -recursive` y `terraform validate`
en bootstrap e infra. El detalle está en `../evidencias/VALIDACIONES_LOCALES.md`.
Después se ejecutaron los planes y `apply` de bootstrap e infra, el build inicial
de Cloud Build y pruebas HTTPS (`/api/health`, `/api/articulos`, `/admin`).
La construcción Docker local no se realizó porque Docker no está instalado;
la imagen se construyó en Cloud Build.

**Comparación con el profesor:** se mantiene la separación de carpetas
bootstrap/infra, los triggers PR/main, la variable `_DEPLOY`, el deploy por digest
y rollback. Se cambia WordPress/PHP/MySQL por Strapi/Node/PostgreSQL y se retiran
Valkey, NAT, VPC y LB. El HTTPS nativo de Cloud Run sustituye el HTTP del LB
de referencia. La métrica SQL de conexiones se cambia a `postgresql/num_backends`.

**Comparación con el Strapi original:** el esquema Artículo y las versiones de
dependencias se conservaron exactamente desde el commit `a9b7e50`. Se añadieron
health, lectura pública controlada, CI/CD y montaje persistente de medios. El
original permanece sin cambios (`git status --porcelain` vacío).

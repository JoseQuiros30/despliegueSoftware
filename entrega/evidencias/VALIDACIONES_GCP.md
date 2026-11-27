# Validaciones reales en Google Cloud

Proyecto: `project-792d22c1-bc11-403b-96c`. Región: `us-central1`.
Fecha: 27 de noviembre de 2026 (Colombia).

| Hito | Resultado observado |
|---|---|
| Bootstrap Terraform | `Apply complete! Resources: 21 added` |
| Cloud Build inicial | Build `cb93a1ac-fc2e-43de-847a-64a515ff0ec2`: `SUCCESS`; imagen `strapi:bootstrap` publicada |
| Infra Terraform | Instancia PostgreSQL, Cloud Run, bucket, secretos y IAM creados; segundo `apply` añadió 9 recursos de observabilidad |
| Cloud SQL | `strapi-a5-pg-496f8a`, PostgreSQL 16, `db-f1-micro`, estado `RUNNABLE` |
| Cloud Run | `strapi-a5-service`, revisión `strapi-a5-service-00001-nnx`, condición `Ready=True` |
| Salud HTTPS | `GET /api/health` → 200, `{"status":"ok","revision":"bootstrap"}` |
| API pública | `GET /api/articulos?status=published` → 200, un artículo publicado (`Prueba Articulo`) |
| Administración | `GET /admin` → 200 |
| Medios persistentes | Imagen subida desde Media Library; original y cuatro tamaños en el bucket de uploads; URL `/uploads/1_1_c719ce111e.png` → 200, `image/png` |
| Observabilidad | Dashboard, uptime check, dos métricas de logs y siete políticas de alerta creadas |

La primera aplicación de infra se detuvo al crear la métrica de errores porque
el filtro de Cloud Logging tenía `resource.label.service_name`. Se corrigió a
`resource.labels.service_name`; el siguiente plan contenía solo nueve recursos
pendientes y su aplicación terminó correctamente. El plan posterior muestra
solo una diferencia de formato en `dashboard_json` (etag y posiciones cero que
agrega la API de Monitoring); no implica recrear recursos.

La URL pública es
`https://strapi-a5-service-h72ufsk6ga-uc.a.run.app`. El artículo fue creado
desde el panel por el usuario y consultado desde la API pública. La prueba de
pipeline PR/main se registrará al completarse. La prueba de medios confirma
escritura en GCS FUSE y lectura pública a través del servicio; la persistencia
entre revisiones se verificará después de CI/CD.
Los recursos facturables deben eliminarse siguiendo
`../documentacion/GUIA_ELIMINACION_RECURSOS.md` después de las capturas.

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
| CI en Pull Request | Build `9711adfc-0b08-4f39-a5e3-352268cef253`: `SUCCESS`, `_DEPLOY=false`; logs `PR: no se publica` y `Sin despliegue`; health permaneció en `bootstrap` |
| CD en main | Build `7b7b79f7-a5a4-4833-ad43-8f859bd2b4db`: `SUCCESS`, `_DEPLOY=true`; imagen publicada, tráfico redirigido y log `Smoke OK` |
| Persistencia entre revisiones | Revisión nueva `strapi-a5-service-00002-rc6`; health cambió a `19c5536`; el mismo artículo siguió en la API y la imagen respondió 200 |

Las evidencias principales correspondientes son `10-imagen-bootstrap.png`,
`12a-cloud-run-listado.png`, `13a-cloud-sql-listado.png`,
`16-cloud-articulo.png`, `17b-cloud-uploads.png`, `18-pr-build.png`,
`19-main-build.png`, `19a-main-detalle.png`, `20-revisiones-cli.txt`,
`21-persistencia.png`, `22-dashboard.png`,
`23-uptime.png`, `24-alertas.png` y `26-cloud-run-eliminado.png`. La captura `19-main-build.png` muestra
también el build del PR y el build inicial con estado exitoso.

La consulta IAM posterior a la conexión de GitHub no devolvió miembros con
`roles/secretmanager.admin`: el permiso temporal amplio se retiró.

La primera aplicación de infra se detuvo al crear la métrica de errores porque
el filtro de Cloud Logging tenía `resource.label.service_name`. Se corrigió a
`resource.labels.service_name`; el siguiente plan contenía solo nueve recursos
pendientes y su aplicación terminó correctamente. El plan posterior muestra
solo una diferencia de formato en `dashboard_json` (etag y posiciones cero que
agrega la API de Monitoring); no implica recrear recursos.

La URL pública es
`https://strapi-a5-service-h72ufsk6ga-uc.a.run.app`. El artículo fue creado
desde el panel por el usuario y consultado desde la API pública. La prueba de
medios confirma escritura en GCS FUSE y lectura pública a través del servicio.
Ambos datos permanecieron disponibles después del despliegue desde `main`.
El dashboard mostró datos reales de solicitudes, latencia, CPU, memoria y
conexiones PostgreSQL; los paneles de errores permanecieron vacíos al no haber
incidentes registrados.

## Eliminación y verificación final

Tras las capturas se borraron las cinco variantes de la imagen de prueba y se
aplicó el plan de destrucción de infra (`0 add, 0 change, 54 destroy`). Ese
primer intento borró Cloud Run, Monitoring, bucket y secretos, pero el borrado
del usuario PostgreSQL falló porque Strapi todavía tenía objetos propios. La
base ya se había eliminado; al recalcular el plan quedaron 13 recursos y el
segundo `apply` terminó con `13 destroyed`. Cloud SQL terminó de eliminarse.

El estado de infra quedó vacío. Se borraron todas las versiones de objetos
`strapi-a5/infra/` del bucket de estado y se aplicó el plan de destrucción de
bootstrap (`0 add, 0 change, 21 destroy`), que terminó con `21 destroyed`.
Después se eliminó la conexión manual `github` de Cloud Build y el bucket
temporal `${PROJECT_ID}_cloudbuild`, que contenía un solo archivo fuente de
esta actividad.

Las consultas finales de `gcloud sql instances list`, `gcloud run services
list`, `gcloud artifacts repositories list`, `gcloud builds triggers list`,
`gcloud builds connections list`, `gcloud secrets list` y `gcloud storage
buckets list` no devolvieron recursos activos de la actividad. Los comandos
`terraform state list` en `infra/` y `bootstrap/` tampoco devolvieron
recursos. Se conservó la protección de borrado recuperable de Cloud Storage;
puede quedar almacenamiento residual durante su periodo de retención. La
facturación puede reflejar cargos ya incurridos con retraso.

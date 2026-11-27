# Checklist de evidencias reales

Guardar imágenes en `../evidencias/`. Esta tabla propone pruebas de hitos
distintos: una misma captura puede demostrar varios y no hay que repetir
pantallas equivalentes. Capturar URL, fecha y nombre del proyecto cuando
corresponda; ocultar credenciales, `.env`, estados y valores secretos.

| Archivo | Qué mostrar | Paso |
|---|---|---|
| `01-local-admin.png` | Panel Strapi local | 1 |
| `01b-local-arranque.png` | Terminal con Strapi iniciado | 1 |
| `02-local-articulo.png` | Artículo publicado | 1 |
| `02b-local-publicacion.png` | Confirmación de publicación | 1 |
| `03-local-api.png` | JSON de `/api/articulos` | 1 |
| `03b-local-health.png` | Health local `status: ok` | 1 |
| `06-presupuesto.png` | Presupuesto GCP propio | 3 |
| `07-conexion-github.png` | Conexión 2nd gen | 3 |
| `08-bootstrap-plan.png` | Resumen del plan sin secretos | 4 |
| `09-bootstrap-recursos.png` | Bucket, AR y triggers | 4 |
| `10-imagen-bootstrap.png` | Build seed e imagen | 5 |
| `11-infra-plan.png` | Resumen Terraform infra | 6 |
| `12-cloud-run.png` | URL y revisión lista | 6 |
| `13-cloud-sql.png` | PostgreSQL en ejecución | 6 |
| `14-secret-manager.png` | Nombres de secretos | 6 |
| `14b-bucket-uploads.png` | Bucket privado de archivos creado | 6 |
| `15-cloud-admin.png` | Panel en HTTPS Cloud Run | 7 |
| `16-cloud-articulo.png` | Artículo publicado | 7 |
| `17-cloud-api.png` | JSON API público | 7 |
| `17b-cloud-uploads.png` | Archivo cargado en Strapi y objeto en bucket privado | 7 |
| `17c-cloud-health.png` | Health HTTPS con `status: ok` | 7 |
| `18-pr-build.png` | PR Build History exitoso | 8 |
| `19-main-build.png` | Main Build History exitoso | 8 |
| `20-revisiones.png` | Dos revisiones Cloud Run | 8 |
| `21-persistencia.png` | Artículo y archivo tras desplegar | 8 |
| `22-dashboard.png` | Gráficas con datos | 9 |
| `23-uptime.png` | Uptime check | 9 |
| `24-alertas.png` | Políticas IaC | 9 |
| `25-logs.png` | Logs reales Cloud Run/Build | 9 |
| `26-recursos-eliminados.png` | Sin recursos facturables activos | 10 |
| `27-envio-correo.png` | Correo académico enviado con enlaces y adjuntos | 11 |

Las capturas de errores o alertas incidentales no se deben fabricar. Si una
gráfica no tiene datos aún, esperar o anotar honestamente la limitación.
Las validaciones de `lint`, `test`, `build`, versiones y Terraform constan en
`../evidencias/VALIDACIONES_LOCALES.md`; el enlace al repositorio publicado
demuestra GitHub. No se piden capturas adicionales de esas mismas salidas.

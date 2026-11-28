# Evidencias

Aquí se guardan capturas reales de hitos distintos. Para una presentación
breve, mostrar una captura de cada fila de esta tabla; los archivos con
sufijos `a`, `b`, `c` o `d` son detalles adicionales del mismo hito.

| Hito | Captura principal | Qué se verifica |
|---|---|---|
| Aplicación local | `01b-local-arranque.png`, `02-local-articulo.png` | Strapi arranca y publica contenido |
| Imagen inicial | `10-imagen-bootstrap.png` | Cloud Build valida y publica la imagen |
| Infraestructura | `12a-cloud-run-listado.png`, `13a-cloud-sql-listado.png` | Cloud Run y PostgreSQL operativos |
| CMS en la nube | `16-cloud-articulo.png`, `17b-cloud-uploads.png` | Contenido y archivo cargados |
| Integración continua | `18-pr-build.png` | Build del Pull Request exitoso |
| Despliegue continuo | `19-main-build.png`, `19a-main-detalle.png`, `20-revisiones-cli.txt` | Build de `main` y dos revisiones listas |
| Persistencia | `21-persistencia.png` | El artículo sigue disponible tras el despliegue |
| Observabilidad | `22-dashboard.png`, `23-uptime.png`, `24-alertas.png` | Métricas reales, disponibilidad y políticas |
| Limpieza | `26-cloud-run-eliminado.png`, `VALIDACIONES_GCP.md` | Cloud Run ya no existe y las consultas finales no muestran recursos activos |

Los resultados técnicos y los identificadores de los builds están en
`VALIDACIONES_GCP.md`. El historial de revisiones se guardó como salida real de
`gcloud`; no hay captura visual de esa pantalla. El listado completo de posibles
capturas se encuentra en `../documentacion/CHECKLIST_EVIDENCIAS.md`.
La comprobación final de facturación se documenta en
`AUDITORIA_COSTOS_2026-11-27.md`.

No incluir contraseñas, tokens, variables secretas ni el contenido de los
estados Terraform.

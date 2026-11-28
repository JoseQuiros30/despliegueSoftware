# Auditoría final de recursos y facturación

**Proyecto:** `project-792d22c1-bc11-403b-96c`

**Fecha de comprobación:** 27 de noviembre de 2026, hora de Colombia.

**Alcance:** recursos del proyecto de la Actividad 5. No incluye otros proyectos
que pudieran estar asociados a la misma cuenta de facturación.

## Resultado

La consulta final `gcloud billing projects describe` devolvió
`billingEnabled: false` y `billingAccountName: ""`. Se desvinculó la
facturación **solo de este proyecto** con autorización expresa del usuario.

| Comprobación en GCP | Resultado |
|---|---|
| Compute Engine: VM, discos, IP, reglas de reenvío, instantáneas e imágenes propias | Sin recursos |
| Cloud SQL | Sin instancias |
| Cloud Run | Sin servicios |
| Artifact Registry (todas las ubicaciones) | Sin repositorios |
| Cloud Storage | Sin buckets activos |
| Secret Manager | Sin secretos activos |
| Cloud Build (`us-central1`) | Sin triggers ni conexiones |
| Monitoring | Sin verificaciones uptime de la actividad |
| Pub/Sub | Sin temas ni suscripciones |
| BigQuery | Sin datasets |
| Terraform | `state list` vacío en `infra/` y `bootstrap/` tras la destrucción |

La API de GKE no estaba habilitada; la CLI no pudo listar clústeres con ella
desactivada. No se habilitó ninguna API nueva para esta auditoría. El inventario
anterior de eliminación se documenta en `VALIDACIONES_GCP.md`.

## Recuperación temporal y cargos anteriores

`gcloud storage ls --soft-deleted --buckets` mostró tres buckets borrados de
forma recuperable: el estado Terraform, los uploads y las fuentes temporales
de Cloud Build. No son buckets activos. Google Cloud Storage conserva por
defecto los recursos borrados durante siete días y los objetos recuperables
pueden acumular almacenamiento hasta expirar la retención. La facturación del
proyecto quedó deshabilitada después de esta comprobación.

Esta auditoría verifica recursos y estado de facturación; **no es una factura
ni confirma que el saldo de cargos anteriores sea cero**. Google advierte que
los cargos incurridos antes de desvincular el proyecto pueden aparecer en
Facturación con retraso de hasta dos días. Revisar en la consola **Facturación
→ Informes**, filtrando por este proyecto y por el 27 al 29 de noviembre de
2026. Si aparece un cargo inesperado, comprobar el servicio y el periodo de
uso antes de atribuirlo a recursos aún activos.

## Otro proyecto en la misma cuenta

La cuenta que estaba vinculada a esta actividad también tiene el proyecto
`desplieguesoftware` con facturación habilitada. **No se modificó**, porque la
autorización de desvinculación se limitó al proyecto Strapi. En ese otro
proyecto no aparecieron buckets ni datasets BigQuery; las API de Compute
Engine, Cloud SQL, Cloud Run y Artifact Registry estaban deshabilitadas, por
lo que la CLI no pudo consultar sus recursos y no se activaron para hacerlo.
La ausencia de cargos en toda la cuenta no puede garantizarse con esta
auditoría. Revisar también ese proyecto en **Facturación → Informes**; si ya
no se usa, decidir por separado si se debe desvincular.

Fuentes oficiales: [deshabilitar facturación de un proyecto](https://docs.cloud.google.com/billing/docs/how-to/modify-project),
[recuperación temporal de Cloud Storage](https://docs.cloud.google.com/storage/docs/soft-delete) y
[análisis de costos](https://docs.cloud.google.com/billing/docs/how-to/reports).

## Comandos de verificación reproducibles

```bash
gcloud billing projects describe project-792d22c1-bc11-403b-96c \
  --format='json(billingAccountName,billingEnabled)'
gcloud sql instances list --project=project-792d22c1-bc11-403b-96c
gcloud run services list --project=project-792d22c1-bc11-403b-96c
gcloud compute instances list --project=project-792d22c1-bc11-403b-96c
gcloud compute disks list --project=project-792d22c1-bc11-403b-96c
gcloud storage buckets list --project=project-792d22c1-bc11-403b-96c
gcloud storage ls --soft-deleted --buckets \
  --project=project-792d22c1-bc11-403b-96c
```

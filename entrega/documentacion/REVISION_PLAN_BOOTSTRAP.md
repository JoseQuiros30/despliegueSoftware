# Revisión del plan de bootstrap

**Proyecto:** `project-792d22c1-bc11-403b-96c` · **Región:** `us-central1`

El 27 de noviembre de 2026 se ejecutó `terraform plan` del módulo
`bootstrap/` con acceso de solo lectura y `-refresh=false`. El plan se guardó
localmente como `bootstrap.tfplan` (ignorado por Git). **No se ejecutó
`terraform apply`.**

| Tipo | Cantidad | Función |
| --- | ---: | --- |
| APIs de Google Cloud | 11 | Prerrequisitos de los servicios |
| Bucket de Cloud Storage | 1 | Estado Terraform versionado |
| Artifact Registry | 1 | Imágenes de Strapi |
| Cuenta de servicio de Cloud Build | 1 | Identidad del pipeline |
| Conexión del repositorio a Cloud Build | 1 | Repositorio GitHub ya publicado |
| Triggers de Cloud Build | 2 | PR y cambios en `main` |
| Vínculos IAM | 4 | Permisos para la cuenta de Build |
| **Total** | **21** | Todos son recursos nuevos del plan |

Este plan **no incluye VM, Cloud Run ni Cloud SQL**. El bucket y Artifact
Registry pueden generar cargos según almacenamiento; los builds se cobrarán
según uso y cuotas. Cloud SQL llegará en un plan separado de `infra/` y es el
costo fijo principal descrito en [REVISION_COSTOS.md](REVISION_COSTOS.md).

**Estado de preparación:** proyecto activo y facturación habilitada. Se
habilitaron las APIs de Cloud Build y Secret Manager. El primer intento de
crear la conexión GitHub falló porque la cuenta administrada de Cloud Build no
tiene `secretmanager.secrets.create` ni `secretmanager.secrets.setIamPolicy`.
Con autorización explícita del usuario, se concedió temporalmente
`roles/secretmanager.admin` según la
[guía oficial](https://docs.cloud.google.com/build/docs/automating-builds/github/connect-repo-github?generation=2nd-gen).
La conexión `github` terminó en estado `COMPLETE`; se retiró el rol amplio y se
verificó que ya no aparece en la política IAM del proyecto.

La CLI de `gcloud` está autenticada. Las credenciales ADC que utiliza Terraform
todavía no están configuradas; el usuario debe completar
`gcloud auth application-default login` antes de aplicar cualquier plan.

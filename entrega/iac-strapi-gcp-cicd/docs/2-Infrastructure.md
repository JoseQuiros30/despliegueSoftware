# 2. Infraestructura

| Módulo | Recurso | Motivo |
|---|---|---|
| bootstrap | APIs, GCS, Artifact Registry, Cloud Build | Prerrequisitos y dos triggers |
| security | Cuenta de ejecución, IAM, siete secretos | Identidad y credenciales |
| database | Cloud SQL PostgreSQL 16, DB y usuario | Persistencia relacional |
| cloudrun | Servicio público HTTPS | Aplicación contenerizada |
| monitoring | Dashboard, uptime, métricas de logs y alertas | Observabilidad IaC |
| storage | Bucket privado, IAM y montaje GCS FUSE | Uploads persistentes |

`bootstrap` conserva estado local, sensible y excluido de Git. `infra` usa backend
GCS privado y versionado creado por bootstrap. El primer `apply` de infra requiere
que exista `:bootstrap` en Artifact Registry. Un build manual con `_DEPLOY=seed`
lo publica antes de planificar Cloud Run. Terraform ignora cambios de imagen y
tráfico del servicio para respetar los despliegues de Cloud Build y rollbacks.

```bash
cd entrega/iac-strapi-gcp-cicd/bootstrap
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
cd ../infra
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

El plan real y el backend remoto se preparan con los comandos de la guía principal.
No se incluye un pipeline IaC porque la actividad eligió la Opción A.

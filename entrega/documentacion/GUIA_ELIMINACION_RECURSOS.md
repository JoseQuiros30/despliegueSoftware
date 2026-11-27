# Eliminación de recursos

Ejecutar solo tras exportar datos que deban conservarse. Borrar Cloud SQL
elimina artículos y administradores. El bucket de uploads conserva archivos y
debe vaciarse antes de destruir infra; el bucket de estado contiene secretos.

```bash
export PROJECT_ID=TU_PROYECTO_GCP
export PREFIX=strapi-a5
gcloud storage ls --recursive "gs://$PROJECT_ID-$PREFIX-uploads/"
gcloud storage rm --recursive "gs://$PROJECT_ID-$PREFIX-uploads/*"
cd /Applications/MAMP/htdocs/despliegueSoftware/entrega/iac-strapi-gcp-cicd/infra
terraform init -reconfigure -backend-config="bucket=$PROJECT_ID-$PREFIX-tfstate" \
  -backend-config="prefix=$PREFIX/infra"
terraform plan -destroy -var-file=env/prod.tfvars -out=destroy.tfplan
terraform show destroy.tfplan
terraform apply destroy.tfplan
```

Confirmar en la consola que Cloud Run y Cloud SQL ya no aparecen. El estado
remoto versionado sigue en GCS; tras verificar el `destroy`, vaciar todas sus
versiones para permitir destruir el bucket de bootstrap:

```bash
gcloud storage ls --all-versions --recursive "gs://$PROJECT_ID-$PREFIX-tfstate/$PREFIX/"
gcloud storage rm --all-versions --recursive "gs://$PROJECT_ID-$PREFIX-tfstate/$PREFIX/"
cd ../bootstrap
terraform plan -destroy -out=bootstrap-destroy.tfplan
terraform show bootstrap-destroy.tfplan
terraform apply bootstrap-destroy.tfplan
```

Verificar Artifact Registry, secretos, bucket, triggers y SQL en la consola.
Las APIs pueden seguir habilitadas (`disable_on_destroy=false`), pero no se
deben mantener recursos de pago. Conservar o borrar de forma segura el estado
local de bootstrap. Si el bucket queda con versiones, volver a listar y borrar
solo después de confirmar que infra está destruida.

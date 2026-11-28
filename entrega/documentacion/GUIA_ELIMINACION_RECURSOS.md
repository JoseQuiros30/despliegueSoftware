# Eliminación de recursos

Ejecutar solo tras exportar datos que deban conservarse. Borrar Cloud SQL
elimina artículos y administradores. El bucket de uploads conserva archivos y
debe vaciarse antes de destruir infra; el bucket de estado contiene secretos.

```bash
export PATH="/Applications/MAMP/htdocs/despliegueSoftware/.herramientas:/opt/homebrew/share/google-cloud-sdk/bin:$PATH"
export PROJECT_ID=project-792d22c1-bc11-403b-96c
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

Si Terraform informa que no puede borrar el usuario `strapi` porque posee
objetos de la base, y el registro confirma que la base ya se borró, recalcular
el plan de destrucción y aplicarlo otra vez:

```bash
terraform plan -destroy -var-file=env/prod.tfvars -out=destroy-retry.tfplan
terraform apply destroy-retry.tfplan
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

La conexión host `github` se creó fuera de Terraform, y `gcloud builds submit`
creó un bucket temporal de fuentes. Después de destruir `bootstrap` y de
guardar la evidencia de los builds, revisar y eliminar estos dos recursos:

```bash
export REGION=us-central1
gcloud builds connections describe github --region "$REGION" --project "$PROJECT_ID"
gcloud builds connections delete github --region "$REGION" --project "$PROJECT_ID" --quiet
gcloud storage ls --recursive "gs://${PROJECT_ID}_cloudbuild/"
```

Si el bucket `${PROJECT_ID}_cloudbuild` contiene solo archivos de esta
actividad, eliminarlo con `gcloud storage rm --recursive
"gs://${PROJECT_ID}_cloudbuild"`. No eliminar objetos de otros trabajos.
Cloud Storage aplica por defecto una retención recuperable de siete días a
objetos y buckets borrados; esta protección permanece activa y puede causar un
residuo de almacenamiento pequeño durante ese plazo. Verificar en Facturación
que desaparecen los servicios principales, en especial Cloud SQL.

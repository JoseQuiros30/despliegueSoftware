# Guía paso a paso · Actividad 5

**Punto de partida:** ubicarse en `/Applications/MAMP/htdocs/despliegueSoftware`.
`PROJECT_ID`, `GITHUB_OWNER` y `ALERT_EMAIL` deben ser valores propios. La
[guía interactiva](GUIA_INTERACTIVA.html) genera los comandos ya sustituidos.
Si es tu primer despliegue, empieza por la [guía desde cero](GUIA_PRINCIPIANTES.md),
que incluye instalación, clics en la consola y resultados esperados.
Los pasos 1 y 2 son locales. Desde el paso 3 se pueden producir cargos; revisar
[costos](INFORME_ACADEMICO.md#costos-y-límites) y el plan antes de ejecutarlos.

## 1. Validar localmente

En este Mac, activar Node 22 y Terraform 1.16.6 con el `export PATH` del paso 1
de la [guía desde cero](GUIA_PRINCIPIANTES.md). `gcloud` y Git ya funcionan.
Docker es opcional para la prueba local de imagen, pero Cloud Build sí construye
el contenedor.

```bash
cd /Applications/MAMP/htdocs/despliegueSoftware/entrega/demo-strapi
npm ci
npm run lint
npm test
npm run setup
npm run build
```

Validar Terraform sin conectar el backend remoto ni usar credenciales GCP:

```bash
cd /Applications/MAMP/htdocs/despliegueSoftware/entrega/iac-strapi-gcp-cicd/bootstrap
terraform init -backend=false
terraform fmt -check
terraform validate
cd ../infra
terraform init -backend=false
terraform fmt -check -recursive
terraform validate
```

El comando `setup` crea `.env` local sin imprimir secretos. Luego:

```bash
cd /Applications/MAMP/htdocs/despliegueSoftware/entrega/demo-strapi
npm run start
# En otra terminal:
curl -fsS http://localhost:1337/api/health
```

Abrir `http://localhost:1337/admin`, crear administrador y un Artículo con
`titulo`, `resumen` y `contenido`; seleccionar `noticias`, `tutoriales` o
`institucional`. Publicarlo y verificar la lectura anónima definida en las rutas:

```bash
curl -fsS 'http://localhost:1337/api/articulos?status=published'
```

**Evidencia ya guardada:** `01-local-admin.png`, `02-local-articulo.png`,
`03-local-api.png` y las capturas complementarias de `evidencias/`.
Las salidas de validación están documentadas en
`../evidencias/VALIDACIONES_LOCALES.md`. Ocultar contraseña y `.env`.

## 2. Publicar el repositorio GitHub

Se usa el repositorio único `JoseQuiros30/despliegueSoftware`. Desde la raíz
del proyecto, comprobar que Git solo incluye `entrega/`, el README y los
archivos de configuración del repositorio. Los originales están ignorados:

```bash
cd /Applications/MAMP/htdocs/despliegueSoftware
git status --short
git ls-files | head
git push -u origin main
```

Confirmar que no se subieron `.env`, estados, `terraform.tfvars`,
`node_modules`, `referencias/` ni `cms-strapi-gcp/`. El enlace público a
`https://github.com/JoseQuiros30/despliegueSoftware` es la evidencia de GitHub.

## 3. Revisar costos y preparar GCP

En Google Cloud Console: crear un proyecto propio, asociar facturación, crear un
presupuesto pequeño con alertas y comprobar que no existen restricciones IAM que
impidan `allUsers` en Cloud Run. El precio base de Cloud SQL para 48 horas en
`us-central1` es aprox. **USD 0,62**; otros consumos pueden aumentar la factura.
No hay un límite automático de gasto por presupuesto. Registrar hora de inicio y
destrucción planificada. **Captura:** `06-presupuesto.png`.

```bash
export PROJECT_ID=TU_PROYECTO_GCP
export REGION=us-central1
export PREFIX=strapi-a5
export GITHUB_OWNER=JoseQuiros30
export ALERT_EMAIL=TU_CORREO@EJEMPLO.COM
gcloud auth login
gcloud auth application-default login
gcloud config set project "$PROJECT_ID"
gcloud services enable serviceusage.googleapis.com cloudresourcemanager.googleapis.com cloudbuild.googleapis.com iam.googleapis.com secretmanager.googleapis.com --project "$PROJECT_ID"
```

En *Cloud Build → Repositories → 2nd gen → Create host connection*: región
`us-central1`, nombre `github`, proveedor GitHub, autorizar e instalar GitHub App
en el repositorio `despliegueSoftware`. **Captura:** `07-conexion-github.png`.

## 4. Aplicar bootstrap

```bash
cd /Applications/MAMP/htdocs/despliegueSoftware/entrega/iac-strapi-gcp-cicd/bootstrap
cp terraform.tfvars.example terraform.tfvars
```

Editar `terraform.tfvars`: `project_id`, `github_owner`, región y prefijo. El
archivo real está ignorado por Git. Después de revisar el plan:

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan -out=bootstrap.tfplan
terraform show bootstrap.tfplan
terraform apply bootstrap.tfplan
terraform output
```

Guardar `bootstrap/terraform.tfstate` en un lugar privado. **Capturas:**
`08-bootstrap-plan.png`, `09-bootstrap-recursos.png` (bucket, Artifact Registry,
dos triggers). No capturar secretos ni estado.

## 5. Publicar la primera imagen sin desplegar

```bash
export AR_REPO="$REGION-docker.pkg.dev/$PROJECT_ID/$PREFIX"
export BUILD_SA="$PREFIX-build@$PROJECT_ID.iam.gserviceaccount.com"
export CALLER="$(gcloud config get-value account)"
gcloud iam service-accounts add-iam-policy-binding "$BUILD_SA" \
  --member="user:$CALLER" --role=roles/iam.serviceAccountUser --project "$PROJECT_ID"
cd /Applications/MAMP/htdocs/despliegueSoftware
gcloud builds submit . --region "$REGION" --project "$PROJECT_ID" \
  --config entrega/demo-strapi/cloudbuild.yaml \
  --service-account "projects/$PROJECT_ID/serviceAccounts/$BUILD_SA" \
  --substitutions "_REGION=$REGION,_AR_REPO=$AR_REPO,_SERVICE=$PREFIX-service,_DEPLOY=seed"
gcloud artifacts docker images list "$AR_REPO" --include-tags
```

El build `seed` publica `strapi:bootstrap` y salta deploy/smoke. Si el usuario
que lanza el build recibe `iam.serviceAccounts.actAs denied`, asignarle
`roles/iam.serviceAccountUser` **sobre la cuenta Build**, no sobre todo el
proyecto. **Captura:** `10-imagen-bootstrap.png`.

## 6. Planificar y aplicar infraestructura

```bash
cd /Applications/MAMP/htdocs/despliegueSoftware/entrega/iac-strapi-gcp-cicd/infra
cp env/prod.tfvars.example env/prod.tfvars
```

Editar `env/prod.tfvars` con ID, `initial_image`, correo de Build y correo de
alertas propios. Después:

```bash
terraform init -reconfigure -backend-config="bucket=$PROJECT_ID-$PREFIX-tfstate" \
  -backend-config="prefix=$PREFIX/infra"
terraform fmt -check -recursive
terraform validate
terraform plan -var-file=env/prod.tfvars -out=infra.tfplan
terraform show infra.tfplan
terraform apply infra.tfplan
terraform output
```

El primer arranque puede tardar por Cloud SQL y la compilación ya hecha en la
imagen. Si falla, revisar los logs antes de continuar. **Capturas:**
`11-infra-plan.png`, `12-cloud-run.png`, `13-cloud-sql.png`,
`14-secret-manager.png` (solo nombres). Verificar también el bucket privado
`$PROJECT_ID-$PREFIX-uploads` y su montaje en Cloud Run.

## 7. Demostrar CMS y persistencia

```bash
export SERVICE_URL="$(gcloud run services describe "$PREFIX-service" --region "$REGION" --format='value(status.url)')"
curl -fsS "$SERVICE_URL/api/health"
```

Abrir `$SERVICE_URL/admin`, crear administrador, crear y publicar Artículo con
los campos requeridos. Subir un archivo pequeño en Media Library, comprobar que
abre desde el CMS y que aparece en el bucket privado:

```bash
curl -fsS "$SERVICE_URL/api/articulos?status=published"
gcloud storage ls "gs://$PROJECT_ID-$PREFIX-uploads/"
```

**Capturas:** `15-cloud-admin.png`, `16-cloud-articulo.png`,
`17-cloud-api.png` y `17b-cloud-uploads.png` (archivo en el CMS y objeto en GCS).
El montaje GCS FUSE requiere una comprobación real de carga y lectura.

## 8. Probar CI/CD y rollback

Crear una rama, cambiar un texto visible del modelo o de la interfaz, hacer PR
contra `main` y comprobar trigger `app-pr` sin deploy. Después de fusionar, el
trigger `app-main` debe publicar y crear una nueva revisión:

```bash
gcloud builds list --region "$REGION" --limit=10
gcloud run revisions list --service "$PREFIX-service" --region "$REGION"
curl -fsS "$SERVICE_URL/api/health"
curl -fsS "$SERVICE_URL/api/articulos?status=published"
```

El segundo `curl` comprueba persistencia del artículo. Abrir de nuevo el archivo
subido para comprobar persistencia de medios. La prueba de rollback
automático es opcional para no introducir un fallo en plena exposición: si se
realiza, usar una rama y una ventana controlada; ver el comando manual en
`iac-strapi-gcp-cicd/docs/3-CI-CD.md`. **Capturas:** `18-pr-build.png`,
`19-main-build.png`, `20-revisiones.png`, `21-persistencia.png`.

## 9. Mostrar observabilidad

Generar tráfico moderado (30 peticiones, una por segundo):

```bash
for i in $(seq 1 30); do curl -fsS "$SERVICE_URL/api/health" >/dev/null; sleep 1; done
gcloud logging read "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"$PREFIX-service\"" --limit=20
```

Abrir *Monitoring → Dashboards*, buscar `strapi-a5 · Strapi`; abrir el uptime
check y las siete políticas de alerta. Esperar unos minutos a que se publiquen
las métricas. **Capturas:** `22-dashboard.png`, `23-uptime.png`,
`24-alertas.png`, `25-logs.png`.

## 10. Cerrar y eliminar recursos

Seguir [GUIA_ELIMINACION_RECURSOS.md](GUIA_ELIMINACION_RECURSOS.md) tras exportar
los datos necesarios. Destruir infra antes que bootstrap y verificar la consola y
el presupuesto. **Captura:** `26-recursos-eliminados.png`.

## 11. Preparar el envío académico

Confirmar que las capturas reales del [checklist](CHECKLIST_EVIDENCIAS.md) están
en `entrega/evidencias/` y que ninguna muestra contraseñas, tokens, `.env` o
estados Terraform. Adjuntar el informe, la documentación y las evidencias, junto
con el enlace del repositorio GitHub propio. Enviar un correo bien
presentado a `enriquegonzalez5940@correo.itm.edu.co` antes del **27 de noviembre
de 2026**, indicando actividad, grupo, integrantes, arquitectura y resultados.
No adjuntar los archivos `*.tfstate`, `*.tfvars` reales ni el `.env`.

**Captura:** `27-envio-correo.png` con destinatario, asunto y adjuntos visibles,
sin exponer datos sensibles.

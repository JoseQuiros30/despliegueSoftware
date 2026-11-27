# Actividad 5: guía desde cero para ejecutar y demostrar la solución

Esta guía está escrita para macOS y para la carpeta
`/Applications/MAMP/htdocs/despliegueSoftware`. Usa **Terminal** para los bloques
de comandos y el navegador para los pasos indicados como **Consola**. No pegues
las palabras `TU_PROYECTO_GCP` ni `TU_CORREO` literalmente:
reemplázalas con tus datos. Si cierras Terminal, vuelve a definir las variables
del paso 4.

La solución ya fue validada localmente. **Aún no existe ningún recurso GCP de
esta entrega.** Los pasos 1 a 3 no aprovisionan nube. Del paso 4 en adelante,
revisa primero el presupuesto: Cloud SQL factura mientras exista. La base
estimada en `us-central1` para 48 horas es USD 0,62 por instancia `db-f1-micro`
y 10 GiB HDD; no incluye builds, imágenes, buckets, secretos, red ni impuestos.
[Precios oficiales](https://cloud.google.com/sql/pricing?hl=en). Un presupuesto
de alertas no bloquea los cargos
([Google Cloud Billing](https://docs.cloud.google.com/billing/docs/how-to/budgets)).

## 0. Cómo tomar y guardar las capturas

Abre **Terminal**. Para guardar cada captura directamente en la carpeta de la
entrega, ejecuta `screencapture -i` y selecciona con el mouse la zona útil. Usa
el nombre que corresponda en el
[checklist completo](CHECKLIST_EVIDENCIAS.md):

```bash
export BASE=/Applications/MAMP/htdocs/despliegueSoftware/entrega
mkdir -p "$BASE/evidencias"
screencapture -i "$BASE/evidencias/06-presupuesto.png"
```

Repite el último comando cambiando el nombre. Muestra URL, nombre del recurso o
fecha cuando ayuden a identificar la prueba. Recorta contraseñas, tokens, `.env`,
`terraform.tfstate`, valores de secretos y datos de facturación personales.

## 1. Activar y verificar herramientas

En este Mac ya funcionan Node 22 y `gcloud`. Homebrew no pudo instalar Terraform
porque exige actualizar las Command Line Tools de Xcode. Para no detener la
actividad, se copió el binario Terraform 1.16.6 validado a
`/Applications/MAMP/htdocs/despliegueSoftware/.herramientas/terraform`, **ignorado
por Git**. En **Terminal**, ejecuta:

```bash
export PATH="/Applications/MAMP/htdocs/despliegueSoftware/.herramientas:$(brew --prefix node@22)/bin:$PATH"
node --version
npm --version
terraform version
gcloud version
git --version
```

Se espera Node `v22...`, Terraform `v1.16.6` y una versión de Google Cloud CLI.
El aviso de Terraform sobre una versión más reciente no impide ejecutar este
proyecto. **Repite la línea `export PATH=...` cada vez que abras una Terminal
nueva.** No hace falta una captura adicional de versiones: las validaciones
quedaron registradas en `../evidencias/VALIDACIONES_LOCALES.md`.

## 2. Demostrar Strapi en tu Mac

En **Terminal**:

```bash
export PATH="$(brew --prefix node@22)/bin:$PATH"
cd /Applications/MAMP/htdocs/despliegueSoftware/entrega/demo-strapi
npm ci
npm run lint
npm test
npm run setup
npm run build
npm run start
```

Deja esa terminal abierta. El resultado esperado es `Strapi started
successfully` y una URL local. En el navegador abre
`http://localhost:1337/admin` y crea tu primer administrador. En **Content
Manager → Artículo → Create new entry**, escribe título, resumen, contenido y
categoría (`noticias`, `tutoriales` o `institucional`), guarda y pulsa
**Publish**. Haz `01-local-admin.png` y `02-local-articulo.png`.

Abre **otra Terminal** y ejecuta:

```bash
curl -fsS http://localhost:1337/api/health
curl -fsS 'http://localhost:1337/api/articulos?status=published'
```

Se espera `"status":"ok"` y el título del artículo en JSON. La captura
`03-local-api.png` ya está guardada y las validaciones constan por escrito;
no repitas las capturas locales.
Puedes detener Strapi con `Ctrl+C` en la primera
terminal. `npm run setup` crea `.env` local; nunca lo publiques.

## 3. Publicar el repositorio propio

Ya existe `https://github.com/JoseQuiros30/despliegueSoftware.git`. La raíz
local `/Applications/MAMP/htdocs/despliegueSoftware` contiene el repositorio
Git y `entrega/` contiene las cuatro carpetas de la solución. En **Terminal**:

```bash
cd /Applications/MAMP/htdocs/despliegueSoftware
git status --short
git ls-files | head
git remote -v
git push -u origin main
```

Si el commit local ya está sincronizado, Git dirá `Everything up-to-date`.
Comprueba que la lista de archivos no incluya `.env`, `node_modules`,
`.terraform`, `*.tfstate`, `*.tfvars` reales, `referencias/`,
`cms-strapi-gcp/` ni `.herramientas/`. El enlace
`https://github.com/JoseQuiros30/despliegueSoftware` demuestra la publicación;
no hace falta una captura adicional.

## 4. Revisar costos, crear proyecto y autenticarte

Si todavía no tienes proyecto, abre **Google Cloud Console → IAM y
administración → Administrar recursos → Crear proyecto**. Elige un nombre
descriptivo y anota el **ID de proyecto** que muestra la consola; es el valor
que sustituye `TU_PROYECTO_GCP`. Antes de habilitar servicios o ejecutar
Terraform, lee la [revisión de costos](REVISION_COSTOS.md).

En **Consola Google Cloud**: crea o selecciona un proyecto **propio**, vincula
una cuenta de facturación y ve a **Billing → Budgets & alerts**. Crea un
presupuesto pequeño y alertas; anota la hora en que destruirás la infraestructura.
Revisa precios para tu región y el alcance del plan antes de continuar. Captura
`06-presupuesto.png`, ocultando datos personales. Conectar servicios y crear
recursos puede generar cargos; por eso el presupuesto y la revisión de precios
van antes de esos pasos.

En **Terminal**, sustituye los tres valores de ejemplo:

```bash
export PROJECT_ID=TU_PROYECTO_GCP
export REGION=us-central1
export PREFIX=strapi-a5
export GITHUB_OWNER=JoseQuiros30
export ALERT_EMAIL=TU_CORREO@EJEMPLO.COM
gcloud auth login
gcloud auth application-default login
gcloud config set project "$PROJECT_ID"
gcloud config get-value project
```

El valor mostrado debe ser **tu** `PROJECT_ID`. Habilita los prerrequisitos:

```bash
gcloud services enable serviceusage.googleapis.com cloudresourcemanager.googleapis.com cloudbuild.googleapis.com iam.googleapis.com secretmanager.googleapis.com --project "$PROJECT_ID"
```

## 5. Conectar GitHub con Cloud Build

En **Consola → Cloud Build → Repositories → 2nd gen → Create host connection**:
elige `us-central1`, nombre `github` y proveedor **GitHub**. Autoriza la app de
Google en GitHub y dale acceso a `despliegueSoftware`. La conexión debe quedar
en la misma región del Terraform y de los triggers. Captura
`07-conexion-github.png`. Usa la
[guía oficial de conexión](https://docs.cloud.google.com/build/docs/automating-builds/github/connect-repo-github?generation=2nd-gen)
si la interfaz cambia.

## 6. Crear bootstrap: bucket de estado, registro y triggers

En **Terminal**:

```bash
cd /Applications/MAMP/htdocs/despliegueSoftware/entrega/iac-strapi-gcp-cicd/bootstrap
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

Reemplaza `project_id` por el proyecto GCP propio y comprueba que
`github_owner = "JoseQuiros30"` y `app_repo_name = "despliegueSoftware"`.
`region` debe seguir
igual que la conexión (`us-central1`). Para guardar en `nano`: `Ctrl+O`, Enter,
`Ctrl+X`. Después:

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan -out=bootstrap.tfplan
terraform show bootstrap.tfplan
```

Lee el resumen de recursos. Guarda `08-bootstrap-plan.png`. Si estás conforme
con el plan y el costo, ejecuta:

```bash
terraform apply bootstrap.tfplan
terraform output
```

En la consola comprueba bucket de estado, repositorio Artifact Registry, cuenta
Build y dos triggers. Captura `09-bootstrap-recursos.png`. Conserva
`bootstrap/terraform.tfstate` en privado; puede contener datos sensibles.

## 7. Construir la primera imagen

En **Terminal**:

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

Espera el estado **SUCCESS** del build y verifica la etiqueta
`strapi:bootstrap`. Este build publica la imagen sin crear todavía Cloud Run.
Captura Build History y la imagen como `10-imagen-bootstrap.png`.

## 8. Crear la infraestructura de la aplicación

En **Terminal**:

```bash
cd /Applications/MAMP/htdocs/despliegueSoftware/entrega/iac-strapi-gcp-cicd/infra
cp env/prod.tfvars.example env/prod.tfvars
nano env/prod.tfvars
```

Sustituye `project_id`, `initial_image`, `build_service_account` y
`alert_emails`. La imagen debe ser
`us-central1-docker.pkg.dev/TU_PROYECTO_GCP/strapi-a5/strapi:bootstrap` usando
tu ID real. Guarda el archivo y ejecuta:

```bash
terraform init -reconfigure -backend-config="bucket=$PROJECT_ID-$PREFIX-tfstate" \
  -backend-config="prefix=$PREFIX/infra"
terraform fmt -check -recursive
terraform validate
terraform plan -var-file=env/prod.tfvars -out=infra.tfplan
terraform show infra.tfplan
```

El plan incluye Cloud SQL facturable. Confirma región, `db-f1-micro`, 10 GiB
HDD, una instancia Cloud Run máxima y bucket de uploads. Captura
`11-infra-plan.png`. Si el plan y el costo son correctos:

```bash
terraform apply infra.tfplan
terraform output
```

En **Consola** revisa Cloud Run (URL y revisión lista), Cloud SQL (PostgreSQL),
Secret Manager (solo nombres) y Cloud Storage (bucket uploads). Guarda
`12-cloud-run.png`, `13-cloud-sql.png`, `14-secret-manager.png` y, si puedes,
`14b-bucket-uploads.png`.

## 9. Demostrar la aplicación en la nube

En **Terminal**:

```bash
export SERVICE_URL="$(gcloud run services describe "$PREFIX-service" --region "$REGION" --format='value(status.url)')"
printf '%s\n' "$SERVICE_URL"
curl -fsS "$SERVICE_URL/api/health"
```

Abre en el navegador `SERVICE_URL/admin` sustituyendo `SERVICE_URL` por la URL
que imprimió Terminal. Crea el administrador cloud (es independiente del local).
Publica un artículo de prueba con título, resumen, contenido y categoría.
En **Media Library**, sube una imagen pequeña y comprueba que abre. Después:

```bash
curl -fsS "$SERVICE_URL/api/articulos?status=published"
gcloud storage ls "gs://$PROJECT_ID-$PREFIX-uploads/"
```

La API debe mostrar el artículo y el bucket debe mostrar el archivo. Captura
`15-cloud-admin.png`, `16-cloud-articulo.png`, `17-cloud-api.png`,
`17b-cloud-uploads.png` y `17c-cloud-health.png`. Si la carga falla, registra
el error real y consulta logs; el montaje GCS FUSE solo puede verificarse al
ejecutarlo en Cloud Run.

## 10. Demostrar CI/CD sin alterar la aplicación

En el repositorio **propio** `despliegueSoftware` de tu Mac:

```bash
cd /Applications/MAMP/htdocs/despliegueSoftware
git switch -c evidencia-cicd
printf '\nPrueba de CI/CD de la Actividad 5.\n' >> entrega/demo-strapi/README.md
git add entrega/demo-strapi/README.md
git commit -m 'Demostrar pipeline de aplicacion'
git push -u origin evidencia-cicd
```

En **GitHub**, abre un Pull Request de `evidencia-cicd` hacia `main`. En
**Consola → Cloud Build → History** espera el trigger PR con estado SUCCESS;
captura `18-pr-build.png`. En GitHub fusiona el PR. Espera el trigger `main` con
estado SUCCESS y captura `19-main-build.png`. En **Consola → Cloud Run →
Revisions**, comprueba dos revisiones y captura `20-revisiones.png`.

```bash
gcloud builds list --region "$REGION" --limit=10
gcloud run revisions list --service "$PREFIX-service" --region "$REGION"
curl -fsS "$SERVICE_URL/api/health"
curl -fsS "$SERVICE_URL/api/articulos?status=published"
```

La revisión del health debe cambiar y el artículo anterior debe seguir
visible. Abre otra vez la imagen. Captura `21-persistencia.png`.

## 11. Demostrar observabilidad

En **Terminal**, genera tráfico moderado:

```bash
for i in $(seq 1 30); do curl -fsS "$SERVICE_URL/api/health" >/dev/null; sleep 1; done
gcloud logging read "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"$PREFIX-service\"" --limit=20
```

En **Consola → Monitoring → Dashboards**, abre `strapi-a5 · Strapi`; espera
varios minutos si las métricas aún no aparecen. En **Monitoring → Uptime
checks** muestra el chequeo HTTPS de `/api/health`. En **Monitoring → Alerting**
muestra las políticas configuradas. En **Logging → Logs Explorer** muestra las
peticiones reales. Capturas `22-dashboard.png`, `23-uptime.png`,
`24-alertas.png` y `25-logs.png`. Una alerta configurada no tiene que estar
disparada para evidenciar que existe; no fabriques incidentes.

## 12. Destruir para detener cargos

Haz este paso **después** de todas las capturas. Exporta primero cualquier dato
que quieras conservar. Sigue exactamente
[GUIA_ELIMINACION_RECURSOS.md](GUIA_ELIMINACION_RECURSOS.md): vacía uploads,
planifica y destruye `infra`, luego vacía las versiones del bucket de estado y
destruye `bootstrap`. Confirma en Consola que Cloud SQL, Cloud Run, imágenes y
buckets ya no existen. Captura `26-recursos-eliminados.png`.

## 13. Enviar la entrega

Revisa las capturas en `entrega/evidencias/` y el
[informe académico](INFORME_ACADEMICO.md). Envía a
`enriquegonzalez5940@correo.itm.edu.co` un correo con asunto
`Actividad 5 - IaC, CI/CD y Observabilidad - Grupo CMS`, los nombres del grupo,
el enlace GitHub, el informe y las evidencias. Guarda
`27-envio-correo.png` de la carpeta **Enviados**. La fecha de entrega indicada
es **27 de noviembre de 2026**. No adjuntes `.env`, `*.tfstate`, `*.tfvars`
reales, `.terraform` ni credenciales.

## Si algo falla

Detente en ese paso y conserva el mensaje de error. Copia el comando ejecutado
sin secretos, el texto del error y una captura; no avances al siguiente `apply`
ni al envío hasta resolverlo. Para el primer diagnóstico:

```bash
gcloud builds list --region "$REGION" --limit=5
gcloud run services describe "$PREFIX-service" --region "$REGION"
gcloud logging read "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"$PREFIX-service\"" --limit=30
```

# Revisión de costos antes del despliegue

**Estado:** la demostración en `project-792d22c1-bc11-403b-96c`, región
`us-central1`, terminó y los recursos activos se eliminaron el 27 de noviembre
de 2026. Esta estimación se basa en tarifas publicadas; no es una cotización
ni una factura. Cloud SQL, el costo fijo principal, ya no figura en el proyecto.

El proyecto para la práctica es `project-792d22c1-bc11-403b-96c` y el usuario
confirmó que tiene vinculada la cuenta «Mi cuenta de facturación». La pantalla
de **Crear una instancia** de Compute Engine mostraba una VM `e2-medium` con
estimación de USD 25,46/mes: **esa VM no pertenece a este diseño y debe
cancelarse**. La infraestructura prevista se enumera abajo.

## Recursos usados durante la demostración

| Componente | Configuración en Terraform | Costo que se debe vigilar |
| --- | --- | --- |
| Cloud SQL PostgreSQL 16 | 1 instancia `db-f1-micro`, 10 GiB HDD, zonal, sin backups automáticos | Instancia y disco mientras existan |
| Cloud Run | 1 servicio, 1 vCPU y 2 GiB, mínimo 0 y máximo 1 instancia | CPU, memoria, solicitudes y red según uso |
| Cloud Build | 2 triggers y builds de prueba, imagen inicial y PR/main | Minutos de compilación |
| Artifact Registry | 1 repositorio Docker | Tamaño de las imágenes almacenadas |
| Cloud Storage | 1 bucket de estado versionado y 1 de uploads | Datos, versiones y operaciones |
| Secret Manager | 7 versiones de secretos | Versiones activas y accesos |
| Monitoring y Logging | 1 uptime check, dashboard, 7 políticas, 2 métricas de logs | Uso y retención fuera de las cuotas gratuitas |

La instancia SQL es el costo fijo principal. La tarifa publicada para
`db-f1-micro` es **USD 0,0105/h** y la del HDD es **USD 0,000246575/GiB-h**.
Con 10 GiB, la base estimada es **USD 0,01296575 por hora**, equivalente a
**USD 0,31 en 24 horas** o **USD 0,62 en 48 horas**. Esto excluye todos los
demás componentes, impuestos, tráfico, cuotas ya consumidas y cambios de
tarifa. Fuente: [precios oficiales de Cloud SQL](https://cloud.google.com/sql/pricing?hl=en).

Cloud Run tiene una [tarifa basada en uso](https://cloud.google.com/run/pricing)
con un tramo gratuito sujeto a sus condiciones. Artifact Registry, Secret
Manager, Monitoring y Cloud Build tienen [tarifas y cuotas propias](https://cloud.google.com/pricing);
el total depende del tamaño real de la imagen, los builds y el tráfico. No se
puede garantizar un total exacto antes de ejecutar la prueba.

Cloud Storage conserva por defecto los objetos y buckets borrados durante
siete días para recuperación. Se mantuvo esa protección para conservar la
capacidad de recuperar el estado Terraform. Al eliminar la entrega puede quedar un costo residual
pequeño por los pocos archivos retenidos; el costo importante a detener es la
instancia Cloud SQL. La [guía de eliminación](GUIA_ELIMINACION_RECURSOS.md)
incluye el bucket temporal de Cloud Build y su conexión GitHub.

## Controles realizados antes de crear recursos

1. Crear o elegir un proyecto propio y anotar el **ID**, no solo el nombre.
   Ver [crear proyectos](https://docs.cloud.google.com/resource-manager/docs/creating-managing-projects).
2. Revisar si hay cuenta de facturación o crédito de prueba; nunca asumir que
   una cuota gratuita cubre toda la actividad.
3. Crear un presupuesto de alerta para ese proyecto y fijar umbrales. Un
   presupuesto de alertas **no detiene automáticamente los cargos**: ver
   [documentación de presupuestos](https://docs.cloud.google.com/billing/docs/how-to/budgets).
4. Definir una ventana corta para la demostración y una hora para destruir
   `infra` y `bootstrap` con la [guía de eliminación](GUIA_ELIMINACION_RECURSOS.md).
5. Completar `terraform.tfvars` y `prod.tfvars` con el ID real, revisar ambos
   `terraform plan` y el costo antes de cualquier `apply`.

El usuario confirmó proyecto, facturación, presupuesto y autenticación; se
revisaron ambos planes Terraform antes de aplicar. La eliminación se completó
después de las pruebas y capturas; los comandos y resultados constan en
`../evidencias/VALIDACIONES_GCP.md`. Puede haber uso residual de almacenamiento
recuperable durante el periodo de retención de Cloud Storage.

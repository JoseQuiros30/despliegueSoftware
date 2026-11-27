# Actividad 5 — IaC, CI/CD y observabilidad para un CMS Strapi

**Programa:** Ingeniería de Sistemas · Despliegue de Software · ITM
**Grupo:** Mariana Villegas Ochoa, Luis David Lopera Parra y Jose Ricardo Quiros Garcia
**Fecha de entrega:** 27 de noviembre de 2026

## Resumen

Se preparó un CMS Strapi 5 con contenido Artículo y una arquitectura GCP definida
en Terraform. La aplicación funciona localmente con SQLite; la arquitectura de
nube usa Cloud Run, Cloud SQL PostgreSQL, Artifact Registry, Secret Manager,
Cloud Build, Monitoring y Logging. La Opción A se implementa con triggers de PR
y `main`, despliegue por digest y rollback de tráfico tras un smoke test fallido.
La infraestructura se validó localmente; no se crearon recursos GCP ni se
obtuvieron aún evidencias de nube.

## Contexto y metodología

Se revisaron la imagen oficial de requisitos, los dos informes académicos
anteriores, `demo-wp` y `iac-wp-gcp-cicd` del docente. Del ejemplo se conservaron
la división bootstrap/infra, el patrón `_DEPLOY`, despliegue
por digest y alerta basada en logs. Se retiraron PHP, WordPress, MySQL, Valkey,
VPC, NAT y balanceador porque no corresponden al CMS textual ni al costo objetivo.
La aplicación, Terraform, documentación y evidencias se publican en un único
repositorio propio: `JoseQuiros30/despliegueSoftware`.

El repositorio `cms-strapi-gcp` de la Actividad 4 se incorporó como base de
`demo-strapi`, conservando su TypeScript, lockfile, configuración y modelo
Artículo. Se añadieron health, pruebas, CI/CD y cambios mínimos para Cloud Run.
El commit original es `a9b7e50`; su carpeta y los repositorios del docente no
se modificaron. SQLite sigue en local y PostgreSQL se usa en nube.

## Arquitectura y decisiones

La solicitud HTTPS llega directamente a Cloud Run. Strapi consulta Cloud SQL
por el socket del conector integrado y lee claves desde Secret Manager. Un
bucket privado y versionado guarda el estado Terraform. Otro bucket privado
conserva los archivos subidos desde el CMS. Cloud Build genera
imágenes etiquetadas con SHA y las publica en Artifact Registry. Monitoring
consulta `/api/health`, muestra métricas y registra políticas de alerta.
El esquema está en `iac-strapi-gcp-cicd/docs/1-Architecture.md`.

El modelo original Artículo admite contenido en bloques y el plugin de carga de
Strapi admite medios. Cloud Run monta Cloud Storage en `public/uploads` para
evitar perder archivos entre revisiones; se eligió una instancia SQL compartida
pequeña, una sola instancia máxima de Cloud Run y cero mínimo. La configuración
sirve para una demostración corta, no para producción.

## Implementación

`bootstrap/` habilita APIs, crea bucket de estado, Artifact Registry, identidad
Build y triggers GitHub. `infra/` separa seguridad, base de datos, Cloud Run y
monitorización. La imagen inicial se publica con `_DEPLOY=seed` antes del primer
`terraform apply` de infra, resolviendo la dependencia circular imagen/servicio.
Terraform ignora los cambios de imagen y tráfico hechos por Cloud Build.

La aplicación define `GET /api/health`, que ejecuta `SELECT 1`. El smoke test
exige tanto estado correcto como SHA nuevo. El servicio publica la API de
Artículo tras conceder solo permisos de lectura al rol Public en Strapi.

## Costos y límites

Para **48 horas** en `us-central1`, usando Cloud SQL `db-f1-micro` y **10 GiB
HDD**, la base calculada es `48 × 0,0105 + 48 × 10 × 0,000246575 = USD 0,622356`
(aprox. USD 0,62). [Google Cloud SQL pricing](https://cloud.google.com/sql/pricing?hl=en)
publica esos precios. La instancia compartida no tiene SLA.

Este subtotal no incluye builds, almacenamiento de imagen, estado ni uploads, secretos,
logs, tráfico, Cloud Run fuera de cuota, impuestos ni cambios de precio. Cloud
Run tiene una cuota gratuita mensual para solicitudes y recursos de ejecución,
pero compartida por cuenta de facturación y sujeta a condiciones
([precios Cloud Run](https://cloud.google.com/run/pricing)). Los uptime checks
también tienen cuota gratuita; revisar la cuenta concreta
([precios de Observability](https://cloud.google.com/products/observability/pricing)).
El presupuesto alerta, **no detiene cargos**. Para controlar el costo se propone
una ventana de menos de 48 horas y eliminación completa al terminar.

## Seguridad y limitaciones

Las contraseñas y claves se generan en Terraform y se consumen desde Secret
Manager. Permanecen en el estado Terraform aunque las salidas sean sensibles;
proteger el estado local de bootstrap y el bucket GCS es esencial. Cloud Run es
público para acceso al CMS, pero el panel exige administrador y la API de
Artículo debe limitarse a lectura pública. No se configuraron backups automáticos
para reducir costo: antes de destruir se debe exportar cualquier contenido útil.

La documentación de Strapi declara PostgreSQL compatible, pero advierte que
Cloud SQL, como base «cloud native», no tiene soporte oficial de Strapi
([database configuration](https://docs.strapi.io/cms/configurations/database)).
Por eso el arranque y CRUD en GCP están en la guía como comprobaciones pendientes;
no se afirma que se hayan probado en nube.

## Resultados verificables y pendientes

Las pruebas locales de lint, modelo, compilación del panel y `terraform validate`
se documentan en `REVISION_REQUISITOS.md`. Las evidencias reales de GCP, CI/CD,
persistencia y alertas permanecen pendientes hasta que el grupo apruebe el costo
y ejecute la guía. No se presentan capturas ficticias.

## Conclusiones

La solución convierte el patrón de clase en una arquitectura Strapi más corta y
económica para la Opción A. La separación bootstrap/infra permite auditar el plan
antes de crear Cloud SQL; el pipeline distingue PR de despliegue y prepara
rollback. La validación local cubre sintaxis y arranque SQLite; el rendimiento y
la compatibilidad de Cloud SQL requieren prueba real tras la revisión de costos.

## Referencias

- Google Cloud. (2026). *Cloud SQL pricing*. https://cloud.google.com/sql/pricing?hl=en
- Google Cloud. (2026). *Cloud Run pricing*. https://cloud.google.com/run/pricing
- Google Cloud. (2026). *Connect from Cloud Run*. https://docs.cloud.google.com/sql/docs/postgres/connect-run
- Google Cloud. (2026). *Google Cloud metrics*. https://docs.cloud.google.com/monitoring/api/metrics_gcp
- Google Cloud. (2026). *User-managed service account for Cloud Build*. https://cloud.google.com/build/docs/securing-builds/configure-user-specified-service-accounts
- Strapi. (2026). *Database configuration*. https://docs.strapi.io/cms/configurations/database
- Strapi. (2026). *Docker*. https://docs.strapi.io/cms/installation/docker
- González De La Rosa, E. J. (2026). *demo-wp* e *iac-wp-gcp-cicd*, repositorios de clase incluidos en `referencias/`.

# Entrega · Actividad 5 — IaC, CI/CD y observabilidad

Este directorio forma parte del repositorio único
[`JoseQuiros30/despliegueSoftware`](https://github.com/JoseQuiros30/despliegueSoftware).
Cloud Build usa `entrega/demo-strapi/cloudbuild.yaml` desde la raíz del repositorio.

| Directorio | Contenido |
|---|---|
| `demo-strapi/` | CMS Strapi 5 basado en `cms-strapi-gcp`, Dockerfile, Cloud Build y pruebas |
| `iac-strapi-gcp-cicd/` | Bootstrap e infraestructura Terraform modular |
| `documentacion/` | Guía interactiva, informe, matriz y eliminación |
| `evidencias/` | Validaciones locales y capturas reales de nube |

**Estado actual:** la demostración en
`project-792d22c1-bc11-403b-96c` concluyó. Se verificaron la aplicación,
el PR, el despliegue de `main`, la persistencia y la observabilidad. Los
recursos se eliminaron y la facturación de este proyecto quedó deshabilitada.
La URL pública ya no está activa. El
[informe con evidencias](documentacion/INFORME_CON_EVIDENCIAS.pdf) está listo
para adjuntar al [correo de entrega](documentacion/CORREO_ENTREGA.md).

Abrir `documentacion/GUIA_INTERACTIVA.html` en un navegador para reproducir el
proceso. La versión imprimible está en
`documentacion/GUIA_PASO_A_PASO.md`.
Para una primera experiencia con Strapi, Terraform y GCP, seguir
`documentacion/GUIA_PRINCIPIANTES.md`.
El inventario final y el estado de facturación están en
`evidencias/AUDITORIA_COSTOS_2026-11-27.md`.

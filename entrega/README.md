# Entrega · Actividad 5 — IaC, CI/CD y observabilidad

Este directorio forma parte del repositorio único
[`JoseQuiros30/despliegueSoftware`](https://github.com/JoseQuiros30/despliegueSoftware).
Cloud Build usa `entrega/demo-strapi/cloudbuild.yaml` desde la raíz del repositorio.

| Directorio | Contenido |
|---|---|
| `demo-strapi/` | CMS Strapi 5 basado en `cms-strapi-gcp`, Dockerfile, Cloud Build y pruebas |
| `iac-strapi-gcp-cicd/` | Bootstrap e infraestructura Terraform modular |
| `documentacion/` | Guía interactiva, informe, matriz y eliminación |
| `evidencias/` | Validaciones locales y capturas de nube pendientes |

**No se han creado recursos en Google Cloud.** El despliegue real comienza solo
después de revisar el costo y ejecutar los comandos de la guía. Abrir
`documentacion/GUIA_INTERACTIVA.html` en un navegador para seguir los pasos con
comandos adaptados a su proyecto y marcar el avance. La versión imprimible está en
`documentacion/GUIA_PASO_A_PASO.md`.
Para una primera experiencia con Strapi, Terraform y GCP, seguir
`documentacion/GUIA_PRINCIPIANTES.md`.

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

**Estado actual:** bootstrap e infraestructura GCP desplegados en
`project-792d22c1-bc11-403b-96c`. Cloud Run responde en
`https://strapi-a5-service-h72ufsk6ga-uc.a.run.app/api/health`. Faltan la
prueba de contenido, el PR de CI/CD y las evidencias finales. Abrir
`documentacion/GUIA_INTERACTIVA.html` en un navegador para seguir los pasos con
comandos adaptados a su proyecto y marcar el avance. La versión imprimible está en
`documentacion/GUIA_PASO_A_PASO.md`.
Para una primera experiencia con Strapi, Terraform y GCP, seguir
`documentacion/GUIA_PRINCIPIANTES.md`.
Revisar `documentacion/REVISION_COSTOS.md` y, tras las pruebas, ejecutar
`documentacion/GUIA_ELIMINACION_RECURSOS.md` para retirar Cloud SQL y Cloud Run.

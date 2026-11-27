# 7. Observabilidad

El módulo Terraform crea un dashboard con disponibilidad, solicitudes, p95, 5xx,
CPU, memoria e instancias de Cloud Run; disponibilidad, CPU, conexiones y disco de
PostgreSQL; fallos de Cloud Build y registros de error. El uptime check consulta
`/api/health` por HTTPS cada minuto desde tres regiones.

| Alerta | Condición |
|---|---|
| CMS no disponible | Menos de la mitad de checks correctos durante 2 min |
| Latencia elevada | p95 > 2000 ms durante 10 min |
| Errores del servidor | Más de 2 respuestas 5xx en 5 min |
| Recursos altos | Memoria Cloud Run > 85 % o CPU SQL > 80 % |
| Base no disponible | `database/up < 1` durante 3 min |
| Fallo de despliegue | Log de error de Cloud Build |

La métrica de conexiones correcta para PostgreSQL es
`cloudsql.googleapis.com/database/postgresql/num_backends`; la genérica
`database/network/connections` del profesor no aplica a PostgreSQL.

## Diagnóstico

```bash
gcloud run services describe strapi-a5-service --region us-central1
gcloud logging read 'resource.type="cloud_run_revision" AND resource.labels.service_name="strapi-a5-service" AND severity>=ERROR' --limit=30
gcloud builds list --region us-central1 --filter='status=FAILURE' --limit=10
gcloud sql instances list
```

Si ocurre tras un despliegue, revisar el SHA del health y restaurar tráfico a la
revisión anterior. Si la base falla, revisar el estado SQL y `cloudsql.client`.
Si sube la latencia, correlacionar CPU, memoria, conexiones y arranques en frío.
Los gráficos pueden tardar varios minutos en mostrar datos tras la primera carga.

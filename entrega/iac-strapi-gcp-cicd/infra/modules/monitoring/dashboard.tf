locals {
  charts = {
    uptime          = { title = "Disponibilidad HTTPS", metric = "monitoring.googleapis.com/uptime_check/check_passed", filter = local.uptime_filter, aligner = "ALIGN_FRACTION_TRUE", reducer = "REDUCE_MEAN", unit = "fracción" }
    requests        = { title = "Solicitudes Cloud Run", metric = "run.googleapis.com/request_count", filter = local.run_filter, aligner = "ALIGN_RATE", reducer = "REDUCE_SUM", unit = "req/s" }
    latency         = { title = "Latencia p95", metric = "run.googleapis.com/request_latencies", filter = local.run_filter, aligner = "ALIGN_DELTA", reducer = "REDUCE_PERCENTILE_95", unit = "ms" }
    http_5xx        = { title = "Errores HTTP 5xx", metric = "run.googleapis.com/request_count", filter = "${local.run_filter} AND metric.label.response_code_class=\"5xx\"", aligner = "ALIGN_SUM", reducer = "REDUCE_SUM", unit = "errores" }
    run_cpu         = { title = "CPU Cloud Run p95", metric = "run.googleapis.com/container/cpu/utilizations", filter = local.run_filter, aligner = "ALIGN_DELTA", reducer = "REDUCE_PERCENTILE_95", unit = "fracción" }
    run_memory      = { title = "Memoria Cloud Run p95", metric = "run.googleapis.com/container/memory/utilizations", filter = local.run_filter, aligner = "ALIGN_DELTA", reducer = "REDUCE_PERCENTILE_95", unit = "fracción" }
    instances       = { title = "Instancias Cloud Run", metric = "run.googleapis.com/container/instance_count", filter = local.run_filter, aligner = "ALIGN_MAX", reducer = "REDUCE_SUM", unit = "instancias" }
    sql_up          = { title = "Cloud SQL disponible", metric = "cloudsql.googleapis.com/database/up", filter = local.sql_filter, aligner = "ALIGN_MIN", reducer = "REDUCE_MIN", unit = "0/1" }
    sql_cpu         = { title = "CPU PostgreSQL", metric = "cloudsql.googleapis.com/database/cpu/utilization", filter = local.sql_filter, aligner = "ALIGN_MEAN", reducer = "REDUCE_MAX", unit = "fracción" }
    sql_connections = { title = "Conexiones PostgreSQL", metric = "cloudsql.googleapis.com/database/postgresql/num_backends", filter = local.sql_filter, aligner = "ALIGN_MAX", reducer = "REDUCE_SUM", unit = "conexiones" }
    sql_storage     = { title = "Almacenamiento PostgreSQL", metric = "cloudsql.googleapis.com/database/disk/bytes_used", filter = local.sql_filter, aligner = "ALIGN_MAX", reducer = "REDUCE_MAX", unit = "bytes" }
    build_failures  = { title = "Fallos Cloud Build (logs)", metric = "logging.googleapis.com/user/${google_logging_metric.build_failures.name}", filter = "resource.type=\"build\"", aligner = "ALIGN_SUM", reducer = "REDUCE_SUM", unit = "errores" }
    app_errors      = { title = "Logs de error Strapi", metric = "logging.googleapis.com/user/${google_logging_metric.app_errors.name}", filter = local.run_filter, aligner = "ALIGN_SUM", reducer = "REDUCE_SUM", unit = "errores" }
  }
  chart_keys = sort(keys(local.charts))
  chart_tiles = [for i, key in local.chart_keys : {
    xPos   = (i % 3) * 16
    yPos   = floor(i / 3) * 12
    width  = 16
    height = 12
    widget = {
      title = local.charts[key].title
      xyChart = {
        dataSets = [{
          plotType   = "LINE"
          targetAxis = "Y1"
          timeSeriesQuery = { timeSeriesFilter = {
            filter = "metric.type=\"${local.charts[key].metric}\" AND ${local.charts[key].filter}"
            aggregation = {
              alignmentPeriod    = "60s"
              perSeriesAligner   = local.charts[key].aligner
              crossSeriesReducer = local.charts[key].reducer
            }
          } }
        }]
        yAxis = { label = local.charts[key].unit, scale = "LINEAR" }
      }
    }
  }]
  log_tile = {
    xPos = 0, yPos = ceil(length(local.chart_keys) / 3) * 12, width = 48, height = 12
    widget = {
      title = "Registros de error de Strapi"
      logsPanel = {
        filter        = "${local.run_filter} AND severity>=ERROR"
        resourceNames = ["projects/${var.project_id}"]
      }
    }
  }
}

resource "google_monitoring_dashboard" "app" {
  dashboard_json = jsonencode({
    displayName  = "${var.prefix} · Strapi"
    mosaicLayout = { columns = 48, tiles = concat(local.chart_tiles, [local.log_tile]) }
  })
}

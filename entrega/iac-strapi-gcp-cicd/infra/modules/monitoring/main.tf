locals {
  run_filter    = "resource.type=\"cloud_run_revision\" AND resource.label.service_name=\"${var.service_name}\""
  sql_filter    = "resource.type=\"cloudsql_database\" AND resource.label.database_id=\"${var.sql_id}\""
  uptime_filter = "resource.type=\"uptime_url\" AND metric.label.check_id=\"${google_monitoring_uptime_check_config.app.uptime_check_id}\""
  channels      = [for c in google_monitoring_notification_channel.email : c.id]
  dashboard_url = "https://console.cloud.google.com/monitoring/dashboards/builder/${element(split("/", google_monitoring_dashboard.app.id), 3)}?project=${var.project_id}"
}

resource "google_monitoring_notification_channel" "email" {
  for_each     = toset(var.alert_emails)
  display_name = "${var.prefix} ${each.value}"
  type         = "email"
  labels       = { email_address = each.value }
}

resource "google_monitoring_uptime_check_config" "app" {
  display_name = "${var.prefix} HTTPS health"
  timeout      = "10s"
  period       = "60s"
  http_check {
    path         = "/api/health"
    port         = 443
    use_ssl      = true
    validate_ssl = true
    accepted_response_status_codes { status_class = "STATUS_CLASS_2XX" }
  }
  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = trimsuffix(trimprefix(var.service_url, "https://"), "/")
    }
  }
  selected_regions = ["USA_VIRGINIA", "USA_OREGON", "SOUTH_AMERICA"]
}

resource "google_logging_metric" "build_failures" {
  name   = "${var.prefix}-build-errors"
  filter = "resource.type=\"build\" AND (severity>=ERROR OR textPayload=~\"ERROR|FAILED|FAILURE\")"
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}

resource "google_logging_metric" "app_errors" {
  name   = "${var.prefix}-app-errors"
  filter = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${var.service_name}\" AND severity>=ERROR"
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}

locals {
  alert_rules = {
    unavailable = {
      title     = "CMS no disponible", filter = "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" AND ${local.uptime_filter}"
      threshold = 0.5, comparison = "COMPARISON_LT", duration = "120s", alignment = "60s"
      aligner   = "ALIGN_FRACTION_TRUE", reducer = "REDUCE_MEAN", severity = "CRITICAL"
    }
    latency = {
      title     = "Latencia p95 mayor a 2000 ms", filter = "metric.type=\"run.googleapis.com/request_latencies\" AND ${local.run_filter}"
      threshold = 2000, comparison = "COMPARISON_GT", duration = "600s", alignment = "60s"
      aligner   = "ALIGN_DELTA", reducer = "REDUCE_PERCENTILE_95", severity = "WARNING"
    }
    server_errors = {
      title     = "Más de 2 respuestas HTTP 5xx en 5 min", filter = "metric.type=\"run.googleapis.com/request_count\" AND metric.label.response_code_class=\"5xx\" AND ${local.run_filter}"
      threshold = 2, comparison = "COMPARISON_GT", duration = "0s", alignment = "300s"
      aligner   = "ALIGN_SUM", reducer = "REDUCE_SUM", severity = "CRITICAL"
    }
    memory = {
      title     = "Memoria de Cloud Run superior a 85%", filter = "metric.type=\"run.googleapis.com/container/memory/utilizations\" AND ${local.run_filter}"
      threshold = 0.85, comparison = "COMPARISON_GT", duration = "300s", alignment = "60s"
      aligner   = "ALIGN_DELTA", reducer = "REDUCE_PERCENTILE_95", severity = "WARNING"
    }
    sql_down = {
      title     = "Cloud SQL no disponible", filter = "metric.type=\"cloudsql.googleapis.com/database/up\" AND ${local.sql_filter}"
      threshold = 1, comparison = "COMPARISON_LT", duration = "180s", alignment = "60s"
      aligner   = "ALIGN_MIN", reducer = "REDUCE_MIN", severity = "CRITICAL"
    }
    sql_cpu = {
      title     = "CPU de PostgreSQL superior a 80%", filter = "metric.type=\"cloudsql.googleapis.com/database/cpu/utilization\" AND ${local.sql_filter}"
      threshold = 0.8, comparison = "COMPARISON_GT", duration = "600s", alignment = "60s"
      aligner   = "ALIGN_MEAN", reducer = "REDUCE_MAX", severity = "WARNING"
    }
    build_failure = {
      title     = "Error de Cloud Build", filter = "metric.type=\"logging.googleapis.com/user/${google_logging_metric.build_failures.name}\" AND resource.type=\"build\""
      threshold = 0, comparison = "COMPARISON_GT", duration = "0s", alignment = "60s"
      aligner   = "ALIGN_SUM", reducer = "REDUCE_SUM", severity = "WARNING"
    }
  }
}

resource "google_monitoring_alert_policy" "rules" {
  for_each              = local.alert_rules
  display_name          = "[Strapi] ${each.value.title}"
  combiner              = "OR"
  severity              = each.value.severity
  notification_channels = local.channels
  user_labels           = { app = var.prefix, rule = each.key }
  conditions {
    display_name = each.value.title
    condition_threshold {
      filter          = each.value.filter
      comparison      = each.value.comparison
      threshold_value = each.value.threshold
      duration        = each.value.duration
      aggregations {
        alignment_period     = each.value.alignment
        per_series_aligner   = each.value.aligner
        cross_series_reducer = each.value.reducer
      }
      trigger { count = 1 }
    }
  }
  alert_strategy { auto_close = "1800s" }
  documentation {
    mime_type = "text/markdown"
    content   = "Revisar el dashboard: ${local.dashboard_url}. Estado: `gcloud run services describe ${var.service_name} --region ${var.region}`. Logs: `gcloud logging read 'resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${var.service_name}\" AND severity>=ERROR' --limit=30`. Si el fallo comenzó tras un despliegue, restaurar el tráfico con `gcloud run services update-traffic ${var.service_name} --region ${var.region} --to-revisions=REVISION_ANTERIOR=100`."
  }
}

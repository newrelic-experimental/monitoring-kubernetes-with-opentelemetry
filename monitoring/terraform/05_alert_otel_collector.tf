##############
### Alerts ###
##############

# Policy - otel collector
resource "newrelic_alert_policy" "otel_collector" {
  name                = "K8s | ${var.cluster_name} | OTel Collector"
  incident_preference = "PER_CONDITION"
}

# Condition - otel collector cpu utilization
resource "newrelic_nrql_alert_condition" "otel_collector_cpu_utilization" {
  account_id                   = var.NEW_RELIC_ACCOUNT_ID
  policy_id                    = newrelic_alert_policy.otel_collector.id
  type                         = "static"
  name                         = "CPU Utilization"
  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT rate(filter(sum(container_cpu_usage_seconds_total), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND container = 'otc-container'), 1 second) / filter(max(kube_pod_container_resource_limits), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND k8s.container.name = 'kube-state-metrics' AND resource = 'cpu' AND container = 'otc-container') * 100 FACET pod, container"
  }

  critical {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 300
    threshold_occurrences = "all"
  }

  warning {
    operator              = "above"
    threshold             = 75
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
  fill_option        = "none"
  aggregation_window = 60
  aggregation_method = "event_flow"
  aggregation_delay  = 0
}

# Condition - otel collector mem utilization
resource "newrelic_nrql_alert_condition" "otel_collector_mem_utilization" {
  account_id                   = var.NEW_RELIC_ACCOUNT_ID
  policy_id                    = newrelic_alert_policy.otel_collector.id
  type                         = "static"
  name                         = "MEM Utilization"
  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT filter(average(container_memory_usage_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND container = 'otc-container') / filter(max(kube_pod_container_resource_limits), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND k8s.container.name = 'kube-state-metrics' AND resource = 'memory' AND container = 'otc-container') * 100 FACET pod, container"
  }

  critical {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 300
    threshold_occurrences = "all"
  }

  warning {
    operator              = "above"
    threshold             = 75
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
  fill_option        = "none"
  aggregation_window = 60
  aggregation_method = "event_flow"
  aggregation_delay  = 0
}

# Condition - otel collector queue utilization
resource "newrelic_nrql_alert_condition" "otel_collector_queue_utilization" {
  account_id                   = var.NEW_RELIC_ACCOUNT_ID
  policy_id                    = newrelic_alert_policy.otel_collector.id
  type                         = "static"
  name                         = "Queue Utilization"
  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT latest(otelcol_exporter_queue_size)/latest(otelcol_exporter_queue_capacity)*100 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name"
  }

  critical {
    operator              = "above"
    threshold             = 90
    threshold_duration    = 300
    threshold_occurrences = "all"
  }

  warning {
    operator              = "above"
    threshold             = 75
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
  fill_option        = "none"
  aggregation_window = 60
  aggregation_method = "event_flow"
  aggregation_delay  = 0
}

# Condition - otel collector dropped metrics
resource "newrelic_nrql_alert_condition" "otel_collector_dropped_metrics" {
  account_id                   = var.NEW_RELIC_ACCOUNT_ID
  policy_id                    = newrelic_alert_policy.otel_collector.id
  type                         = "static"
  name                         = "Dropped Metrics"
  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT average(otelcol_processor_dropped_metric_points) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }
  fill_option        = "none"
  aggregation_window = 60
  aggregation_method = "event_timer"
  aggregation_timer  = 5
}

# Condition - otel collector dropped spans
resource "newrelic_nrql_alert_condition" "otel_collector_dropped_spans" {
  account_id                   = var.NEW_RELIC_ACCOUNT_ID
  policy_id                    = newrelic_alert_policy.otel_collector.id
  type                         = "static"
  name                         = "Dropped Spans"
  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT average(otelcol_processor_dropped_spans) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }
  fill_option        = "none"
  aggregation_window = 60
  aggregation_method = "event_timer"
  aggregation_timer  = 5
}

# Condition - otel collector dropped logs
resource "newrelic_nrql_alert_condition" "otel_collector_dropped_logs" {
  account_id                   = var.NEW_RELIC_ACCOUNT_ID
  policy_id                    = newrelic_alert_policy.otel_collector.id
  type                         = "static"
  name                         = "Dropped Logs"
  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT average(otelcol_processor_dropped_log_records) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }
  fill_option        = "none"
  aggregation_window = 60
  aggregation_method = "event_timer"
  aggregation_timer  = 5
}

# Condition - otel collector enqueue failed metrics
resource "newrelic_nrql_alert_condition" "otel_collector_enqueue_failed_metrics" {
  account_id                   = var.NEW_RELIC_ACCOUNT_ID
  policy_id                    = newrelic_alert_policy.otel_collector.id
  type                         = "static"
  name                         = "Enqueue Failed Metrics"
  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT average(otelcol_exporter_enqueue_failed_metric_points) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }
  fill_option        = "none"
  aggregation_window = 60
  aggregation_method = "event_timer"
  aggregation_timer  = 5
}

# Condition - otel collector enqueue failed spans
resource "newrelic_nrql_alert_condition" "otel_collector_enqueue_failed_spans" {
  account_id                   = var.NEW_RELIC_ACCOUNT_ID
  policy_id                    = newrelic_alert_policy.otel_collector.id
  type                         = "static"
  name                         = "Enqueue Failed Spans"
  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT average(otelcol_exporter_enqueue_failed_spans) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }
  fill_option        = "none"
  aggregation_window = 60
  aggregation_method = "event_timer"
  aggregation_timer  = 5
}

# Condition - otel collector enqueue failed logs
resource "newrelic_nrql_alert_condition" "otel_collector_enqueue_failed_logs" {
  account_id                   = var.NEW_RELIC_ACCOUNT_ID
  policy_id                    = newrelic_alert_policy.otel_collector.id
  type                         = "static"
  name                         = "Enqueue Failed Logs"
  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT average(otelcol_exporter_enqueue_failed_log_records) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }
  fill_option        = "none"
  aggregation_window = 60
  aggregation_method = "event_timer"
  aggregation_timer  = 5
}

# Condition - otel collector receive failed metrics
resource "newrelic_nrql_alert_condition" "otel_collector_receive_failed_metrics" {
  account_id                   = var.NEW_RELIC_ACCOUNT_ID
  policy_id                    = newrelic_alert_policy.otel_collector.id
  type                         = "static"
  name                         = "Receive Failed Metrics"
  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT average(otelcol_receiver_refused_metric_points) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }
  fill_option        = "none"
  aggregation_window = 60
  aggregation_method = "event_timer"
  aggregation_timer  = 5
}

# Condition - otel collector receive failed spans
resource "newrelic_nrql_alert_condition" "otel_collector_receive_failed_spans" {
  account_id                   = var.NEW_RELIC_ACCOUNT_ID
  policy_id                    = newrelic_alert_policy.otel_collector.id
  type                         = "static"
  name                         = "Receive Failed Spans"
  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT average(otelcol_receiver_refused_spans) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }
  fill_option        = "none"
  aggregation_window = 60
  aggregation_method = "event_timer"
  aggregation_timer  = 5
}

# Condition - otel collector receive failed logs
resource "newrelic_nrql_alert_condition" "otel_collector_receive_failed_logs" {
  account_id                   = var.NEW_RELIC_ACCOUNT_ID
  policy_id                    = newrelic_alert_policy.otel_collector.id
  type                         = "static"
  name                         = "Receive Failed Logs"
  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT average(otelcol_receiver_refused_log_records) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }
  fill_option        = "none"
  aggregation_window = 60
  aggregation_method = "event_timer"
  aggregation_timer  = 5
}

# Condition - otel collector export failed metrics
resource "newrelic_nrql_alert_condition" "otel_collector_export_failed_metrics" {
  account_id                   = var.NEW_RELIC_ACCOUNT_ID
  policy_id                    = newrelic_alert_policy.otel_collector.id
  type                         = "static"
  name                         = "Export Failed Metrics"
  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT average(otelcol_exporter_refused_metric_points) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }
  fill_option        = "none"
  aggregation_window = 60
  aggregation_method = "event_timer"
  aggregation_timer  = 5
}

# Condition - otel collector export failed spans
resource "newrelic_nrql_alert_condition" "otel_collector_export_failed_spans" {
  account_id                   = var.NEW_RELIC_ACCOUNT_ID
  policy_id                    = newrelic_alert_policy.otel_collector.id
  type                         = "static"
  name                         = "Export Failed Spans"
  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT average(otelcol_exporter_refused_spans) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }
  fill_option        = "none"
  aggregation_window = 60
  aggregation_method = "event_timer"
  aggregation_timer  = 5
}

# Condition - otel collector export failed logs
resource "newrelic_nrql_alert_condition" "otel_collector_export_failed_logs" {
  account_id                   = var.NEW_RELIC_ACCOUNT_ID
  policy_id                    = newrelic_alert_policy.otel_collector.id
  type                         = "static"
  name                         = "Export Failed Logs"
  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT average(otelcol_exporter_refused_log_records) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "at_least_once"
  }
  fill_option        = "none"
  aggregation_window = 60
  aggregation_method = "event_timer"
  aggregation_timer  = 5
}
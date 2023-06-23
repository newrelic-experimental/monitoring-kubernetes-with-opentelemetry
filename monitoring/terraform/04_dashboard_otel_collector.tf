##################
### Dashboards ###
##################

# Infrastructure
resource "newrelic_one_dashboard" "otel_collector" {
  name = "K8s | ${var.cluster_name} | OTel Collectors"

  page {
    name = "OTel Collectors"

    # Page Description
    widget_markdown {
      title  = "Page Description"
      row    = 1
      column = 1
      height = 3
      width  = 4

      text = "## OTel Collectors\nTo be able to visualize every widget properly, Prometheus should be able to scrape the following resources:\n- Nodes Endpoints\n- Node Exporter\n- cAdvisor\n- Kube State Metrics\n- OTel Collectors"
    }

    # Node Capacities
    widget_table {
      title  = "Node Capacities"
      row    = 1
      column = 5
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT uniqueCount(cpu) AS 'CPU (cores)', max(node_memory_MemTotal_bytes)/1000/1000/1000 AS 'MEM (GB)' WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter' AND k8s.node.name IN (FROM Metric SELECT uniques(k8s.node.name) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND otelcollector.type IN ({{collectortypes}})) FACET k8s.node.name"
      }
    }

    # Node up statuses
    widget_line {
      title  = "Node up statuses"
      row    = 1
      column = 9
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT latest(up) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes' AND k8s.node.name IN (FROM Metric SELECT uniques(k8s.node.name) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND otelcollector.type IN ({{collectortypes}})) FACET k8s.node.name TIMESERIES"
      }
    }

    # Pod (Running)
    widget_billboard {
      title  = "Pod (Running)"
      row    = 4
      column = 1
      height = 2
      width  = 3

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `running` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND k8s.container.name = 'kube-state-metrics' AND pod IN (FROM Metric SELECT uniques(k8s.pod.name) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND otelcollector.type IN ({{collectortypes}}) LIMIT MAX) AND phase = 'Running' FACET pod LIMIT MAX) SELECT sum(`running`)"
      }
    }

    # Pod (Pending)
    widget_billboard {
      title  = "Pod (Pending)"
      row    = 4
      column = 4
      height = 2
      width  = 3

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `pending` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND k8s.container.name = 'kube-state-metrics' AND pod IN (FROM Metric SELECT uniques(k8s.pod.name) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND otelcollector.type IN ({{collectortypes}}) LIMIT MAX) AND phase = 'Pending' FACET pod LIMIT MAX) SELECT sum(`pending`)"
      }
    }

    # Pod (Failed)
    widget_billboard {
      title  = "Pod (Failed)"
      row    = 4
      column = 7
      height = 2
      width  = 3

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `failed` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND k8s.container.name = 'kube-state-metrics' AND pod IN (FROM Metric SELECT uniques(k8s.pod.name) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND otelcollector.type IN ({{collectortypes}}) LIMIT MAX) AND phase = 'Failed' FACET pod LIMIT MAX) SELECT sum(`failed`)"
      }
    }

    # Pod (Unknown)
    widget_billboard {
      title  = "Pod (Unknown)"
      row    = 4
      column = 10
      height = 2
      width  = 3

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `unknown` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND k8s.container.name = 'kube-state-metrics' AND pod IN (FROM Metric SELECT uniques(k8s.pod.name) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND otelcollector.type IN ({{collectortypes}}) LIMIT MAX) AND phase = 'Unknown' FACET pod LIMIT MAX) SELECT sum(`unknown`)"
      }
    }

    # Container CPU Usage per Pod (mcores)
    widget_area {
      title  = "Container CPU Usage per Pod (mcores)"
      row    = 7
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT rate(sum(container_cpu_usage_seconds), 1 second)*1000 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND container IS NOT NULL AND pod IN (FROM Metric SELECT uniques(k8s.pod.name) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND otelcollector.type IN ({{collectortypes}}) LIMIT MAX) FACET pod, container TIMESERIES AUTO"
      }
    }

    # Container CPU Utilization per Pod (%)
    widget_line {
      title  = "Container CPU Utilization per Pod (%)"
      row    = 7
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT rate(filter(sum(container_cpu_usage_seconds), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND container IN (FROM Metric SELECT uniques(container) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND kube_pod_container_resource_limits IS NOT NULL AND k8s.container.name = 'kube-state-metrics' AND resource = 'cpu') AND pod IN (FROM Metric SELECT uniques(k8s.pod.name) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND otelcollector.type IN ({{collectortypes}}) LIMIT MAX)), 1 second) / filter(max(kube_pod_container_resource_limits), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND k8s.container.name = 'kube-state-metrics' AND resource = 'cpu') * 100 WHERE container IS NOT NULL AND pod IN (FROM Metric SELECT uniques(k8s.pod.name) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND otelcollector.type IN ({{collectortypes}}) LIMIT MAX) FACET pod, container TIMESERIES AUTO"
      }
    }

    # Container MEM Usage per Pod (bytes)
    widget_area {
      title  = "Container MEM Usage per Pod (bytes)"
      row    = 10
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT average(container_memory_usage_bytes) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND container IS NOT NULL AND pod IN (FROM Metric SELECT uniques(k8s.pod.name) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND otelcollector.type IN ({{collectortypes}}) LIMIT MAX) FACET pod, container TIMESERIES AUTO"
      }
    }

    # Container MEM Utilization per Pod (%)
    widget_line {
      title  = "Container MEM Utilization per Pod (%)"
      row    = 10
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT filter(average(container_memory_usage_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND container IN (FROM Metric SELECT uniques(container) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND kube_pod_container_resource_limits IS NOT NULL AND k8s.container.name = 'kube-state-metrics' AND resource = 'memory') AND pod IN (FROM Metric SELECT uniques(k8s.pod.name) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND otelcollector.type IN ({{collectortypes}}) LIMIT MAX)) / filter(max(kube_pod_container_resource_limits), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND k8s.container.name = 'kube-state-metrics' AND resource = 'memory') * 100 WHERE container IS NOT NULL AND pod IN (FROM Metric SELECT uniques(k8s.pod.name) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND otelcollector.type IN ({{collectortypes}}) LIMIT MAX) FACET pod, container TIMESERIES AUTO"
      }
    }

    # Latest queue size/capacity (%)
    widget_bar {
      title  = "Latest queue size/capacity (%)"
      row    = 13
      column = 1
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT latest(otelcol_exporter_queue_size)/latest(otelcol_exporter_queue_capacity)*100 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name TIMESERIES"
      }
    }

    # Max queue size/capacity (%)
    widget_line {
      title  = "Max queue size/capacity (%)"
      row    = 13
      column = 7
      height = 3
      width  = 8

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT max(otelcol_exporter_queue_size)/max(otelcol_exporter_queue_capacity)*100 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name TIMESERIES"
      }
    }

    # Dropped metric points
    widget_line {
      title  = "Dropped metric points"
      row    = 16
      column = 1
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT average(otelcol_processor_dropped_metric_points) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name TIMESERIES"
      }
    }

    # Dropped spans
    widget_line {
      title  = "Dropped spans"
      row    = 16
      column = 5
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT average(otelcol_processor_dropped_spans) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name TIMESERIES"
      }
    }

    # Dropped log records
    widget_line {
      title  = "Dropped log records"
      row    = 16
      column = 9
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT average(otelcol_processor_dropped_log_records) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name TIMESERIES"
      }
    }

    # Enqueue failed metric points
    widget_line {
      title  = "Enqueue failed metric points"
      row    = 19
      column = 1
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT average(otelcol_exporter_enqueue_failed_metric_points) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name TIMESERIES"
      }
    }

    # Enqueue failed spans
    widget_line {
      title  = "Enqueue failed spans"
      row    = 19
      column = 5
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT average(otelcol_exporter_enqueue_failed_spans) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name TIMESERIES"
      }
    }

    # Enqueue failed log records
    widget_line {
      title  = "Enqueue failed log records"
      row    = 19
      column = 9
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT average(otelcol_exporter_enqueue_failed_log_records) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name TIMESERIES"
      }
    }

    # Receive failed metric points
    widget_line {
      title  = "Receive failed metric points"
      row    = 22
      column = 1
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT average(otelcol_receiver_refused_metric_points) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name TIMESERIES"
      }
    }

    # Receive failed spans
    widget_line {
      title  = "Receive failed spans"
      row    = 22
      column = 5
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT average(otelcol_receiver_refused_spans) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name TIMESERIES"
      }
    }

    # Receive failed log records
    widget_line {
      title  = "Receive failed log records"
      row    = 22
      column = 9
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT average(otelcol_receiver_refused_log_records) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name TIMESERIES"
      }
    }

    # Export failed metric points
    widget_line {
      title  = "Export failed metric points"
      row    = 25
      column = 1
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT average(otelcol_exporter_refused_metric_points) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name TIMESERIES"
      }
    }

    # Export failed spans
    widget_line {
      title  = "Export failed spans"
      row    = 25
      column = 5
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT average(otelcol_exporter_refused_spans) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name TIMESERIES"
      }
    }

    # Export failed log records
    widget_line {
      title  = "Export failed log records"
      row    = 25
      column = 9
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT average(otelcol_exporter_refused_log_records) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'otelcollector' FACET k8s.pod.name TIMESERIES"
      }
    }
  }

  # Collector Types
  variable {
    name  = "collectortypes"
    title = "Collector Types"
    type  = "nrql"

    default_values       = ["*"]
    replacement_strategy = "default"
    is_multi_selection   = true

    nrql_query {
      account_ids = [var.NEW_RELIC_ACCOUNT_ID]
      query       = "FROM Metric SELECT uniques(otelcollector.type) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}'"
    }
  }
}

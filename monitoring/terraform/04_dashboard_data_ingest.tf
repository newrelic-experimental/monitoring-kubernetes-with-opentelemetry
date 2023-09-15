##################
### Dashboards ###
##################

# Dashboard - Data Ingest
resource "newrelic_one_dashboard" "data_ingest" {
  name = "K8s | ${var.cluster_name} | Data Ingest"

  page {
    name = "Data Ingest"

    # Page Description
    widget_markdown {
      title  = ""
      row    = 1
      column = 1
      height = 3
      width  = 2

      text = "## Data Ingest\nThis page is dedicated to analyse the data ingest in terms of which telemetry data is coming from which collector and how much it is."
    }

    # Total ingest per telemetry type (GB)
    widget_pie {
      title  = "Total ingest per telemetry type (GB)"
      row    = 1
      column = 3
      height = 3
      width  = 5

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT bytecountestimate()/1e9 AS `Metric` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}'"
      }

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Span SELECT bytecountestimate()/1e9 AS `Span` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}'"
      }

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Log SELECT bytecountestimate()/1e9 AS `Logs` WHERE k8s.cluster.name = '${var.cluster_name}'"
      }
    }

    # Total ingest per telemetry type (GB)
    widget_area {
      title  = "Total ingest per telemetry type (GB)"
      row    = 1
      column = 8
      height = 3
      width  = 5

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT bytecountestimate()/1e9 AS `Metric` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' TIMESERIES"
      }

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Span SELECT bytecountestimate()/1e9 AS `Span` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' TIMESERIES"
      }

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Log SELECT bytecountestimate()/1e9 AS `Logs` WHERE k8s.cluster.name = '${var.cluster_name}' TIMESERIES"
      }
    }

    # Prometheus scraping
    widget_markdown {
      title  = ""
      row    = 4
      column = 1
      height = 3
      width  = 2

      text = "## Prometheus scraping\nThe data ingest caused by Prometheus scraping as a whole:\n\n- otelcollector\n- kubernetes-nodes\n- kubernetes-nodes-cadvisor\n- kubernetes-apiservers\n- kubernetes-coredns\n- kubernetes-node-exporter\n- kubernetes-kube-state-metrics\n- kubernetes-service-endpoints"
    }

    # Prometheus scraping (GB)
    widget_pie {
      title  = "Prometheus scraping (GB)"
      row    = 4
      column = 3
      height = 3
      width  = 5

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM Metric SELECT bytecountestimate()/1e9 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}'
          AND service.name IN (
            'otelcollector', 'kubernetes-nodes', 'kubernetes-nodes-cadvisor', 'kubernetes-apiservers',
            'kubernetes-coredns', 'kubernetes-node-exporter', 'kubernetes-kube-state-metrics', 'kubernetes-service-endpoints'
          ) FACET service.name
        EOF
      }
    }

    # Prometheus scraping (GB)
    widget_area {
      title  = "Prometheus scraping (GB)"
      row    = 4
      column = 8
      height = 3
      width  = 5

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM Metric SELECT bytecountestimate()/1e9 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}'
          AND service.name IN (
            'otelcollector', 'kubernetes-nodes', 'kubernetes-nodes-cadvisor', 'kubernetes-apiservers', 'kubernetes-coredns',
            'kubernetes-node-exporter', 'kubernetes-kube-state-metrics', 'kubernetes-service-endpoints'
          ) FACET service.name TIMESERIES
        EOF
      }
    }

    # Collector metrics
    widget_markdown {
      title  = ""
      row    = 7
      column = 1
      height = 3
      width  = 2

      text = "### Collector metrics\nThe data ingest caused by Prometheus scraping of the collector itself to push its own metrics."
    }

    # Collector metrics per type (GB)
    widget_pie {
      title  = "Collector metrics per type (GB)"
      row    = 7
      column = 3
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM Metric SELECT bytecountestimate()/1e9 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}'
          AND service.name = 'otelcollector' FACET otelcollector.type
        EOF
      }
    }

    # Collector metrics per instance (GB)
    widget_area {
      title  = "Collector metrics instance (GB)"
      row    = 10
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM Metric SELECT bytecountestimate()/1e9 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}'
          AND otelcollector.type IS NOT NULL AND k8s.pod.name IS NOT NULL FACET otelcollector.type, k8s.pod.name TIMESERIES
        EOF
      }
    }

    # K8s service metrics
    widget_markdown {
      title  = ""
      row    = 13
      column = 1
      height = 3
      width  = 2

      text = "### K8s service metrics\nThe data ingest caused by Prometheus scraping of the k8s service endpoints."
    }

    # K8s service metrics per namespace (GB)
    widget_bar {
      title  = "K8s service metrics per namespace (GB)"
      row    = 13
      column = 3
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM Metric SELECT bytecountestimate()/1e9 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}'
          AND service.name = 'kubernetes-service-endpoints' FACET k8s.namespace.name
        EOF
      }
    }

    # K8s service metrics per set type (GB)
    widget_pie {
      title  = "K8s service metrics per set type (GB)"
      row    = 13
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM Metric SELECT bytecountestimate()/1e9 AS `Replicaset` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}'
          AND service.name = 'kubernetes-service-endpoints' AND k8s.replicaset.name IS NOT NULL
          EOF
      }

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM Metric SELECT bytecountestimate()/1e9 AS `Satefulset` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}'
          AND service.name = 'kubernetes-service-endpoints' AND k8s.statefulset.name IS NOT NULL
        EOF
      }

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM Metric SELECT bytecountestimate()/1e9 AS `Daemonset` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}'
          AND service.name = 'kubernetes-service-endpoints' AND k8s.daemonset.name IS NOT NULL
        EOF
      }
    }

    # K8s service metrics per each replicaset (GB)
    widget_area {
      title  = "K8s service metrics per each replicaset (GB)"
      row    = 16
      column = 1
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM Metric SELECT bytecountestimate()/1e9 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}'
          AND service.name = 'kubernetes-service-endpoints' FACET k8s.replicaset.name TIMESERIES
        EOF
      }
    }

    # K8s service metrics per each statefulset (GB)
    widget_area {
      title  = "K8s service metrics per each statefulset (GB)"
      row    = 16
      column = 5
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM Metric SELECT bytecountestimate()/1e9 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}'
          AND service.name = 'kubernetes-service-endpoints' FACET k8s.statefulset.name TIMESERIES
        EOF
      }
    }

    # K8s service metrics per each daemonset (GB)
    widget_area {
      title  = "K8s service metrics per each daemonset (GB)"
      row    = 16
      column = 9
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM Metric SELECT bytecountestimate()/1e9 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}'
          AND service.name = 'kubernetes-service-endpoints' FACET k8s.daemonset.name TIMESERIES
        EOF
      }
    }

    # K8s node cadvisor metrics
    widget_markdown {
      title  = ""
      row    = 19
      column = 1
      height = 3
      width  = 2

      text = "### K8s node cadvisor metrics\nThe data ingest caused by Prometheus scraping of the k8s node cadvisor endpoints."
    }

    # K8s node cadvisor metrics per node (GB)
    widget_bar {
      title  = "K8s node cadvisor metrics per node (GB)"
      row    = 19
      column = 3
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM Metric SELECT bytecountestimate()/1e9 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}'
          AND service.name = 'kubernetes-nodes-cadvisor' FACET k8s.node.name
        EOF
      }
    }

    # K8s node cadvisor metrics per node (GB)
    widget_area {
      title  = "K8s node cadvisor metrics per node (GB)"
      row    = 19
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM Metric SELECT bytecountestimate()/1e9 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}'
          AND service.name = 'kubernetes-nodes-cadvisor' FACET k8s.node.name TIMESERIES
        EOF
      }
    }

    # K8s API server metrics
    widget_markdown {
      title  = ""
      row    = 22
      column = 1
      height = 3
      width  = 2

      text = "### K8s API server metrics\nThe data ingest caused by Prometheus scraping of the k8s API server."
    }

    # K8s API server metrics (GB)
    widget_billboard {
      title  = "K8s API server metrics (GB)"
      row    = 22
      column = 3
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM Metric SELECT bytecountestimate()/1e9 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-apiservers'
        EOF
      }
    }

    # K8s API server metrics (GB)
    widget_area {
      title  = "K8s API server metrics (GB)"
      row    = 22
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM Metric SELECT bytecountestimate()/1e9 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-apiservers' TIMESERIES
        EOF
      }
    }

    # K8s node metrics
    widget_markdown {
      title  = ""
      row    = 25
      column = 1
      height = 3
      width  = 2

      text = "### K8s node metrics\nThe data ingest caused by Prometheus scraping of the k8s nodes."
    }

    # K8s node metrics per node (GB)
    widget_bar {
      title  = "K8s node metrics per node (GB)"
      row    = 25
      column = 3
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM Metric SELECT bytecountestimate()/1e9 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes' FACET k8s.node.name
        EOF
      }
    }

    # K8s node metrics per node (GB)
    widget_area {
      title  = "K8s node metrics per node (GB)"
      row    = 25
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM Metric SELECT bytecountestimate()/1e9 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes' FACET k8s.node.name TIMESERIES
        EOF
      }
    }
  }
}

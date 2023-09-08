##################
### Dashboards ###
##################

# Dashboard - Kube API Server
resource "newrelic_one_dashboard" "kube_apiserver" {
  name = "K8s | ${var.cluster_name} | Kube API Server"

  page {
    name = "Kube API Server"

    # Page Description
    widget_markdown {
      title  = "Page Description"
      row    = 1
      column = 1
      height = 3
      width  = 4

      text = "## Kube API Server\nTo be able to visualize every widget properly, Prometheus should be able to scrape the following resources:\n- Nodes Endpoints\n- Node Exporter\n- cAdvisor\n- Kube State Metrics\n- Kube API Server\n\n**Remark**: If the API server is not running as a pod but as a service on the controlplane nodes, the widgets for the corresponding node and containers will not be populated."
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
        query      = "FROM Metric SELECT uniqueCount(cpu) AS 'CPU (cores)', max(node_memory_MemTotal_bytes)/1000/1000/1000 AS 'MEM (GB)' WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter' AND k8s.node.name IN ({{nodes}}) FACET k8s.node.name"
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
        query      = "FROM Metric SELECT latest(up) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes' AND k8s.node.name IN ({{nodes}}) FACET k8s.node.name TIMESERIES"
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
        query      = "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `phase` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND k8s.container.name = 'kube-state-metrics' AND phase = 'Running' AND pod IN (FROM Metric SELECT uniques(pod) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes' AND pod LIKE 'kube-apiserver-%' AND k8s.node.name IN ({{nodes}}) LIMIT MAX) FACET pod LIMIT MAX) SELECT sum(`phase`)"
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
        query      = "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `phase` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND k8s.container.name = 'kube-state-metrics' AND phase = 'Pending' AND pod IN (FROM Metric SELECT uniques(pod) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes' AND pod LIKE 'kube-apiserver-%' AND k8s.node.name IN ({{nodes}}) LIMIT MAX) FACET pod LIMIT MAX) SELECT sum(`phase`)"
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
        query      = "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `phase` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND k8s.container.name = 'kube-state-metrics' AND phase = 'Failed' AND pod IN (FROM Metric SELECT uniques(pod) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes' AND pod LIKE 'kube-apiserver-%' AND k8s.node.name IN ({{nodes}}) LIMIT MAX) FACET pod LIMIT MAX) SELECT sum(`phase`)"
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
        query      = "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `phase` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND k8s.container.name = 'kube-state-metrics' AND phase = 'Unknown' AND pod IN (FROM Metric SELECT uniques(pod) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes' AND pod LIKE 'kube-apiserver-%' AND k8s.node.name IN ({{nodes}}) LIMIT MAX) FACET pod LIMIT MAX) SELECT sum(`phase`)"
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
        query      = "FROM Metric SELECT rate(sum(container_cpu_usage_seconds_total), 1 second)*1000 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND k8s.node.name IN ({{nodes}}) AND container IS NOT NULL AND pod LIKE 'kube-apiserver-%' FACET pod, container TIMESERIES AUTO"
      }
    }

    # Container MEM Usage per Pod (bytes)
    widget_area {
      title  = "Container MEM Usage per Pod (bytes)"
      row    = 7
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT average(container_memory_usage_bytes) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND k8s.node.name IN ({{nodes}}) AND container IS NOT NULL AND pod IS NOT NULL AND pod LIKE 'kube-apiserver-%' FACET pod, container TIMESERIES AUTO"
      }
    }

    # Overall latency histogram (seconds)
    widget_histogram {
      title  = "Overall latency histogram (seconds)"
      row    = 10
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT histogram(apiserver_request_duration_seconds) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-apiservers'"
      }
    }

    # Average latency (seconds)
    widget_line {
      title  = "Average latency (seconds)"
      row    = 10
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT average(apiserver_request_duration_seconds) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-apiservers' TIMESERIES AUTO"
      }
    }

    # Throughput per HTTP status code (rpm)
    widget_line {
      title  = "Throughput per HTTP status code (rpm)"
      row    = 13
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT rate(sum(apiserver_request_total), 1 minute) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-apiservers' FACET code TIMESERIES AUTO"
      }
    }

    # Throughput per HTTP request type (rpm)
    widget_line {
      title  = "Throughput per HTTP request type (rpm)"
      row    = 13
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT rate(sum(apiserver_request_total), 1 minute) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-apiservers' FACET verb TIMESERIES AUTO"
      }
    }

    # Rate of additions handled by the workqueue (rpm)
    widget_line {
      title  = "Rate of additions handled by the workqueue (rpm)"
      row    = 16
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT rate(sum(workqueue_adds_total), 1 minute) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-apiservers' TIMESERIES AUTO"
      }
    }

    # Max length of workqueue
    widget_line {
      title  = "Max length of workqueue"
      row    = 16
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT max(workqueue_depth) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-apiservers' TIMESERIES AUTO"
      }
    }

    # Rate of requests being processed by request kind (rpm)
    widget_line {
      title  = "Rate of requests being processed by request kind (rpm)"
      row    = 19
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT rate(sum(apiserver_current_inflight_requests), 1 minute) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-apiservers' FACET request_kind TIMESERIES AUTO"
      }
    }

    # Rate of dropped requests (rpm)
    widget_line {
      title  = "Rate of dropped requests (rpm)"
      row    = 19
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT rate(sum(apiserver_dropped_request), 1 minute) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-apiservers' TIMESERIES AUTO"
      }
    }
  }

  # Nodes
  variable {
    name  = "nodes"
    title = "Nodes"
    type  = "nrql"

    default_values       = ["*"]
    replacement_strategy = "default"
    is_multi_selection   = true

    nrql_query {
      account_ids = [var.NEW_RELIC_ACCOUNT_ID]
      query       = "FROM Metric SELECT uniques(k8s.node.name) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes' AND pod LIKE 'kube-apiserver-%'"
    }
  }
}

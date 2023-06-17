##################
### Dashboards ###
##################

# Dashboard - Core DNS
resource "newrelic_one_dashboard" "core_dns" {
  name = "K8s | ${var.cluster_name} | Core DNS"

  page {
    name = "Core DNS"

    # Page Description
    widget_markdown {
      title  = "Page Description"
      row    = 1
      column = 1
      height = 3
      width  = 4

      text = "## Core DNS\nTo be able to visualize every widget properly, Prometheus should be able to scrape the following resources:\n- Nodes Endpoints\n- Node Exporter\n- cAdvisor\n- Kube State Metrics\n- Core DNS"
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
        query      = "FROM Metric SELECT uniqueCount(cpu) AS 'CPU (cores)', max(node_memory_MemTotal_bytes)/1000/1000/1000 AS 'MEM (GB)' WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter' AND k8s.node.name IN (FROM Metric SELECT uniques(node) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND pod LIKE 'coredns-%') FACET k8s.node.name"
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
        query      = "FROM Metric SELECT latest(up) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes' AND k8s.node.name IN (FROM Metric SELECT uniques(node) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND pod LIKE 'coredns-%')FACET k8s.node.name TIMESERIES"
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
        query      = "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `running` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND k8s.container.name = 'kube-state-metrics' AND pod LIKE 'coredns-%' AND phase = 'Running' FACET pod LIMIT MAX) SELECT sum(`running`)"
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
        query      = "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `pending` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND k8s.container.name = 'kube-state-metrics' AND pod LIKE 'coredns-%' AND phase = 'Pending' FACET pod LIMIT MAX) SELECT sum(`pending`)"
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
        query      = "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `failed` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND k8s.container.name = 'kube-state-metrics' AND pod LIKE 'coredns-%' AND phase = 'Failed' FACET pod LIMIT MAX) SELECT sum(`failed`)"
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
        query      = "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `unknown` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND k8s.container.name = 'kube-state-metrics' AND pod LIKE 'coredns-%' AND phase = 'Unknown' FACET pod LIMIT MAX) SELECT sum(`unknown`)"
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
        query      = "FROM Metric SELECT rate(sum(container_cpu_usage_seconds), 1 second)*1000 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND container IS NOT NULL AND pod LIKE 'coredns-%' FACET pod, container TIMESERIES AUTO"
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
        query      = "FROM Metric SELECT average(container_memory_usage_bytes) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND container IS NOT NULL AND pod IS NOT NULL AND pod LIKE 'coredns-%' FACET pod, container TIMESERIES AUTO"
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
        query      = "FROM Metric SELECT histogram(coredns_dns_request_duration_seconds) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-coredns'"
      }
    }

    # Average latency per instance (seconds)
    widget_line {
      title  = "Average latency per instance (seconds)"
      row    = 10
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT average(coredns_dns_request_duration_seconds) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-coredns' FACET k8s.pod.name TIMESERIES AUTO"
      }
    }

    # Request throughput per IP type (rpm)
    widget_line {
      title  = "Request throughput per IP type (rpm)"
      row    = 13
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT rate(sum(coredns_dns_requests), 1 minute) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-coredns' FACET type TIMESERIES AUTO"
      }
    }

    # Response throughput per rcode (rpm)
    widget_line {
      title  = "Response throughput per rcode (rpm)"
      row    = 13
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT rate(sum(coredns_dns_responses), 1 minute) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-coredns' FACET rcode TIMESERIES AUTO"
      }
    }

    # Rate of panics per instance (rpm)
    widget_line {
      title  = "Rate of panics per instance (rpm)"
      row    = 16
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT rate(sum(coredns_panics), 1 minute) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-coredns' FACET k8s.pod.name TIMESERIES AUTO"
      }
    }

    # Rate of cache hits by type (rpm)
    widget_line {
      title  = "Rate of cache hits by type (rpm)"
      row    = 16
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT rate(sum(coredns_cache_hits), 1 minute) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-coredns' FACET type TIMESERIES AUTO"
      }
    }
  }
}

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
        query      = <<EOF
        FROM Metric SELECT uniqueCount(cpu) AS 'CPU (cores)', max(node_memory_MemTotal_bytes)/1000/1000/1000 AS 'MEM (GB)'
          WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
            AND k8s.node.name IN ({{nodes}}) FACET k8s.node.name
        EOF
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
        query      = <<EOF
        FROM Metric SELECT latest(up) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}'
          AND service.name = 'kubernetes-nodes' AND k8s.node.name IN ({{nodes}}) FACET k8s.node.name TIMESERIES
        EOF
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
        query      = <<EOF
        FROM (
          FROM Metric SELECT latest(kube_pod_status_phase) AS `phase` WHERE instrumentation.provider = 'opentelemetry'
            AND k8s.cluster.name = '${var.cluster_name}' AND k8s.container.name = 'kube-state-metrics' AND phase = 'Running'
            AND pod IN (
              FROM Metric SELECT uniques(pod) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}'
                AND service.name = 'kubernetes-nodes' AND pod LIKE 'coredns-%' AND k8s.node.name IN ({{nodes}}) LIMIT MAX
            ) FACET pod LIMIT MAX
          ) SELECT sum(`phase`)
        EOF
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
        query      = <<EOF
        FROM (
          FROM Metric SELECT latest(kube_pod_status_phase) AS `phase` WHERE instrumentation.provider = 'opentelemetry'
            AND k8s.cluster.name = '${var.cluster_name}' AND k8s.container.name = 'kube-state-metrics' AND phase = 'Pending'
            AND pod IN (
              FROM Metric SELECT uniques(pod) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}'
                AND service.name = 'kubernetes-nodes' AND pod LIKE 'coredns-%' AND k8s.node.name IN ({{nodes}}) LIMIT MAX
            ) FACET pod LIMIT MAX
          ) SELECT sum(`phase`)
        EOF
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
        query      = <<EOF
        FROM (
          FROM Metric SELECT latest(kube_pod_status_phase) AS `phase` WHERE instrumentation.provider = 'opentelemetry'
            AND k8s.cluster.name = '${var.cluster_name}' AND k8s.container.name = 'kube-state-metrics' AND phase = 'Failed'
            AND pod IN (
              FROM Metric SELECT uniques(pod) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}'
                AND service.name = 'kubernetes-nodes' AND pod LIKE 'coredns-%' AND k8s.node.name IN ({{nodes}}) LIMIT MAX
            ) FACET pod LIMIT MAX
          ) SELECT sum(`phase`)
        EOF
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
        query      = <<EOF
        FROM (
          FROM Metric SELECT latest(kube_pod_status_phase) AS `phase` WHERE instrumentation.provider = 'opentelemetry'
            AND k8s.cluster.name = '${var.cluster_name}' AND k8s.container.name = 'kube-state-metrics' AND phase = 'Unknown'
            AND pod IN (
              FROM Metric SELECT uniques(pod) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}'
                AND service.name = 'kubernetes-nodes' AND pod LIKE 'coredns-%' AND k8s.node.name IN ({{nodes}}) LIMIT MAX
            ) FACET pod LIMIT MAX
          ) SELECT sum(`phase`)
        EOF
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
        query      = <<EOF
        FROM Metric SELECT rate(sum(container_cpu_usage_seconds_total), 1 second)*1000 WHERE instrumentation.provider = 'opentelemetry'
          AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND k8s.node.name IN ({{nodes}})
          AND container IS NOT NULL AND pod LIKE 'coredns-%' FACET pod, container TIMESERIES AUTO
        EOF
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
        query      = <<EOF
        FROM Metric SELECT average(container_memory_usage_bytes) WHERE instrumentation.provider = 'opentelemetry'
          AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND k8s.node.name IN ({{nodes}})
          AND container IS NOT NULL AND pod IS NOT NULL AND pod LIKE 'coredns-%' FACET pod, container TIMESERIES AUTO
        EOF
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
        query      = <<EOF
        FROM Metric SELECT histogram(coredns_dns_request_duration_seconds) WHERE instrumentation.provider = 'opentelemetry'
          AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-coredns'
        EOF
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
        query      = <<EOF
        FROM Metric SELECT average(coredns_dns_request_duration_seconds) WHERE instrumentation.provider = 'opentelemetry'
          AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-coredns' FACET k8s.pod.name TIMESERIES AUTO
        EOF
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
        query      = <<EOF
        FROM Metric SELECT rate(sum(coredns_dns_requests_total), 1 minute) WHERE instrumentation.provider = 'opentelemetry'
          AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-coredns' FACET type TIMESERIES AUTO
        EOF
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
        query      = <<EOF
        FROM Metric SELECT rate(sum(coredns_dns_responses_total), 1 minute) WHERE instrumentation.provider = 'opentelemetry'
          AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-coredns' FACET rcode TIMESERIES AUTO
        EOF
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
        query      = <<EOF
        FROM Metric SELECT rate(sum(coredns_panics_total), 1 minute) WHERE instrumentation.provider = 'opentelemetry'
          AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-coredns' FACET k8s.pod.name TIMESERIES AUTO
        EOF
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
        query      = <<EOF
        FROM Metric SELECT rate(sum(coredns_cache_hits_total), 1 minute) WHERE instrumentation.provider = 'opentelemetry'
          AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-coredns' FACET type TIMESERIES AUTO
        EOF
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
      query       = "FROM Metric SELECT uniques(k8s.node.name) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes' AND pod LIKE 'coredns-%' LIMIT MAX"
    }
  }
}

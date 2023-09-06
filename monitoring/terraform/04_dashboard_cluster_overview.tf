##################
### Dashboards ###
##################

# Dashboard - Cluster Overview
resource "newrelic_one_dashboard" "cluster_overview" {
  name = "K8s | ${var.cluster_name} | Cluster Overview"

  #####################
  ### NODE OVERVIEW ###
  #####################
  page {
    name = "Node Overview"

    # Page Description
    widget_markdown {
      title  = "Page Description"
      row    = 1
      column = 1
      height = 2
      width  = 4

      text = "## Node Overview\nTo be able to visualize every widget properly, Prometheus should be able to scrape the following resources:\n- Nodes Endpoints\n- Node Exporter\n- Kube State Metrics"
    }

    # Node to Pod Map
    widget_table {
      title  = "Node to Pod Map"
      row    = 1
      column = 5
      height = 5
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT uniques(concat(k8s.node.name, ' -> ', pod)) AS `Node -> Pod` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes' AND pod IS NOT NULL AND k8s.node.name IN ({{nodes}})"
      }
    }

    # Num Namespaces by Nodes
    widget_line {
      title  = "Num Namespaces by Nodes"
      row    = 1
      column = 9
      height = 2
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT uniqueCount(namespace) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes' AND pod IS NOT NULL AND k8s.node.name IN ({{nodes}}) FACET k8s.node.name TIMESERIES AUTO"
      }
    }

    # Num Pods by Nodes
    widget_line {
      title  = "Num Pods by Nodes"
      row    = 3
      column = 9
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT uniqueCount(pod) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes' AND pod IS NOT NULL AND k8s.node.name IN ({{nodes}}) FACET k8s.node.name TIMESERIES AUTO"
      }
    }

    # Node Capacities
    widget_table {
      title  = "Node Capacities"
      row    = 3
      column = 1
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT uniqueCount(cpu) AS 'CPU (cores)', max(node_memory_MemTotal_bytes)/1000/1000/1000 AS 'MEM (GB)' WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter' AND k8s.node.name IN ({{nodes}}) FACET k8s.node.name"
      }
    }

    # Node CPU Usage (mcores)
    widget_area {
      title  = "Node CPU Usage (mcores)"
      row    = 6
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT rate(filter(sum(node_cpu_seconds_total), WHERE mode != 'idle'), 1 SECONDS)*1000 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter' AND k8s.node.name IN ({{nodes}}) FACET k8s.node.name LIMIT MAX TIMESERIES"
      }
    }

    # Node CPU Utilization (%)
    widget_line {
      title  = "Node CPU Utilization (%)"
      row    = 6
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT rate(filter(sum(node_cpu_seconds_total), WHERE mode != 'idle'), 1 SECONDS)/uniqueCount(cpu)*100 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter' AND k8s.node.name IN ({{nodes}}) FACET k8s.node.name LIMIT MAX TIMESERIES"
      }
    }

    # Node MEM Usage (bytes)
    widget_area {
      title  = "Node MEM Usage (bytes)"
      row    = 9
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT average(node_memory_MemTotal_bytes) - (average(node_memory_MemFree_bytes) + average(node_memory_Cached_bytes) + average(node_memory_Buffers_bytes)) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter' AND k8s.node.name IN ({{nodes}}) FACET k8s.node.name LIMIT 100 TIMESERIES AUTO"
      }
    }

    # Node MEM Utilization (%)
    widget_line {
      title  = "Node MEM Utilization (%)"
      row    = 9
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT (100 * (1 - ((average(node_memory_MemFree_bytes) + average(node_memory_Cached_bytes) + average(node_memory_Buffers_bytes)) / average(node_memory_MemTotal_bytes)))) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter' AND k8s.node.name IN ({{nodes}}) FACET k8s.node.name TIMESERIES AUTO"
      }
    }

    # Node STO Usage (bytes)
    widget_area {
      title  = "Node STO Usage (bytes)"
      row    = 12
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "SELECT average(node_filesystem_size_bytes)-average(node_filesystem_avail_bytes) FROM Metric WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter' AND k8s.node.name IN ({{nodes}}) FACET k8s.node.name TIMESERIES AUTO"
      }
    }

    # Node STO Utilization (%)
    widget_line {
      title  = "Node STO Utilization (%)"
      row    = 12
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "SELECT (1 - (average(node_filesystem_avail_bytes) / average(node_filesystem_size_bytes))) * 100 FROM Metric WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter' AND k8s.node.name IN ({{nodes}}) FACET k8s.node.name TIMESERIES AUTO"
      }
    }
  }

  ##########################
  ### NAMESPACE OVERVIEW ###
  ##########################
  page {
    name = "Namespace Overview"

    # Page Description
    widget_markdown {
      title  = "Page Description"
      row    = 1
      column = 1
      height = 2
      width  = 4

      text = "## Namespace Overview\nTo be able to visualize every widget properly, Prometheus should be able to scrape the following resources:\n- Node cAdvisor\n- Kube State Metrics"
    }

    # Namespaces
    widget_table {
      title  = "Namespaces"
      row    = 1
      column = 5
      height = 2
      width  = 2

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT uniques(namespace) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes'"
      }
    }

    # Deployments in Namespaces
    widget_bar {
      title  = "Deployments in Namespaces"
      row    = 1
      column = 7
      height = 2
      width  = 2

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT uniqueCount(deployment) OR 0 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND namespace IN ({{namespaces}}) FACET namespace"
      }
    }

    # DaemonSets in Namespaces
    widget_bar {
      title  = "DaemonSets in Namespaces"
      row    = 1
      column = 9
      height = 2
      width  = 2

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT uniqueCount(daemonset) OR 0 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND namespace IN ({{namespaces}}) FACET namespace"
      }
    }

    # StatefulSets in Namespaces
    widget_bar {
      title  = "StatefulSets in Namespaces"
      row    = 1
      column = 11
      height = 2
      width  = 2

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT uniqueCount(statefulset) OR 0 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND namespace IN ({{namespaces}}) FACET namespace"
      }
    }

    # Pods in Namespaces (Running)
    widget_bar {
      title  = "Pods in Namespaces (Running)"
      row    = 3
      column = 1
      height = 3
      width  = 3

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `running` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND phase = 'Running' AND namespace IN ({{namespaces}}) FACET namespace, pod LIMIT MAX) SELECT sum(`running`) FACET namespace"
      }
    }

    # Pods in Namespaces (Pending)
    widget_bar {
      title  = "Pods in Namespaces (Pending)"
      row    = 3
      column = 4
      height = 3
      width  = 3

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `pending` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND phase = 'Pending' AND namespace IN ({{namespaces}}) FACET namespace, pod LIMIT MAX) SELECT sum(`pending`) FACET namespace"
      }
    }

    # Pods in Namespaces (Failed)
    widget_bar {
      title  = "Pods in Namespaces (Failed)"
      row    = 3
      column = 7
      height = 3
      width  = 3

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `failed` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND phase = 'Failed' AND namespace IN ({{namespaces}}) FACET namespace, pod LIMIT MAX) SELECT sum(`failed`) FACET namespace"
      }
    }

    # Pods in Namespaces (Unknown)
    widget_bar {
      title  = "Pods in Namespaces (Unknown)"
      row    = 3
      column = 10
      height = 3
      width  = 3

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `unknown` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND phase = 'Unknown' AND namespace IN ({{namespaces}}) FACET namespace, pod LIMIT MAX) SELECT sum(`unknown`) FACET namespace"
      }
    }

    # Container CPU Usage per Namespace (mcores)
    widget_area {
      title  = "Container CPU Usage per Namespace (mcores)"
      row    = 5
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT rate(sum(container_cpu_usage_seconds_total), 1 second)*1000 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND container IS NOT NULL AND pod IS NOT NULL AND namespace IN ({{namespaces}}) FACET namespace TIMESERIES AUTO"
      }
    }

    # Container CPU Utilization per Namespace (%)
    widget_line {
      title  = "Container CPU Utilization per Namespace (%)"
      row    = 5
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT rate(filter(sum(container_cpu_usage_seconds_total), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND container IN (FROM Metric SELECT uniques(container) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND kube_pod_container_resource_limits IS NOT NULL AND resource = 'cpu' LIMIT MAX)), 1 second) / filter(sum(kube_pod_container_resource_limits), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND resource = 'cpu') * 100 WHERE container IS NOT NULL AND pod IS NOT NULL AND namespace IN ({{namespaces}}) FACET namespace TIMESERIES AUTO"
      }
    }

    # Container MEM Usage per Namespace (bytes)
    widget_area {
      title  = "Container MEM Usage per Namespace (bytes)"
      row    = 8
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM (FROM Metric SELECT average(container_memory_usage_bytes) AS `usage` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND container IS NOT NULL AND pod IS NOT NULL AND namespace IN ({{namespaces}}) FACET namespace, pod, container TIMESERIES AUTO LIMIT MAX) SELECT sum(`usage`) FACET namespace TIMESERIES AUTO"
      }
    }

    # Container MEM Utilization per Namespace (%)
    widget_line {
      title  = "Container MEM Utilization per Namespace (%)"
      row    = 8
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM (FROM Metric SELECT filter(average(container_memory_usage_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND container IN (FROM Metric SELECT uniques(container) WHERE kube_pod_container_resource_limits IS NOT NULL AND resource = 'memory' LIMIT MAX)) AS `usage`, filter(max(kube_pod_container_resource_limits), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND resource = 'memory') AS `limit` WHERE container IS NOT NULL AND pod IS NOT NULL AND namespace IN ({{namespaces}}) FACET namespace, pod, container TIMESERIES AUTO LIMIT MAX) SELECT sum(`usage`)/sum(`limit`)*100 FACET namespace TIMESERIES AUTO"
      }
    }
  }

  ####################
  ### POD OVERVIEW ###
  ####################
  page {
    name = "Pod Overview"

    # Page Description
    widget_markdown {
      title  = "Page Description"
      row    = 1
      column = 1
      height = 2
      width  = 4

      text = "## Pod Overview\nTo be able to visualize every widget properly, Prometheus should be able to scrape the following resources:\n- Node cAdvisor\n- Kube State Metrics"
    }

    # Containers
    widget_table {
      title  = "Containers"
      row    = 1
      column = 5
      height = 4
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT uniques(container) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND namespace IN ({{namespaces}})"
      }
    }

    # Pod (Running)
    widget_billboard {
      title  = "Pod (Running)"
      row    = 1
      column = 9
      height = 2
      width  = 2

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `running` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND phase = 'Running' AND namespace IN ({{namespaces}}) FACET pod LIMIT MAX) SELECT sum(`running`)"
      }
    }

    # Pod (Pending)
    widget_billboard {
      title  = "Pod (Pending)"
      row    = 1
      column = 11
      height = 2
      width  = 2

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `pending` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND phase = 'Pending' AND namespace IN ({{namespaces}}) FACET pod LIMIT MAX) SELECT sum(`pending`)"
      }
    }

    # Container (Ready)
    widget_billboard {
      title  = "Container (Ready)"
      row    = 3
      column = 1
      height = 2
      width  = 2

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM (FROM Metric SELECT latest(kube_pod_container_status_ready) AS `ready` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND namespace IN ({{namespaces}}) FACET container LIMIT MAX) SELECT sum(`ready`)"
      }
    }

    # Container (Waiting)
    widget_billboard {
      title  = "Container (Waiting)"
      row    = 3
      column = 3
      height = 2
      width  = 2

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM (FROM Metric SELECT latest(kube_pod_container_status_waiting) AS `waiting` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND namespace IN ({{namespaces}}) FACET container LIMIT MAX) SELECT sum(`waiting`)"
      }
    }

    # Pod (Failed)
    widget_billboard {
      title  = "Pod (Failed)"
      row    = 3
      column = 9
      height = 2
      width  = 2

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `failed` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND phase = 'Failed' AND namespace IN ({{namespaces}}) FACET pod LIMIT MAX) SELECT sum(`failed`)"
      }
    }

    # Pod (Unknown)
    widget_billboard {
      title  = "Pod (Unknown)"
      row    = 3
      column = 11
      height = 2
      width  = 2

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `unknown` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND phase = 'Unknown' AND namespace IN ({{namespaces}}) FACET pod LIMIT MAX) SELECT sum(`unknown`)"
      }
    }

    # Container CPU Usage per Pod (mcores)
    widget_area {
      title  = "Container CPU Usage per Pod (mcores)"
      row    = 5
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT rate(sum(container_cpu_usage_seconds_total), 1 second)*1000 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND container IS NOT NULL AND pod IS NOT NULL AND namespace IN ({{namespaces}}) FACET pod, container TIMESERIES AUTO"
      }
    }

    # Container CPU Utilization per Pod (%)
    widget_line {
      title  = "Container CPU Utilization per Pod (%)"
      row    = 5
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT rate(filter(sum(container_cpu_usage_seconds_total), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND container IN (FROM Metric SELECT uniques(container) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND kube_pod_container_resource_limits IS NOT NULL AND resource = 'cpu' AND service.name = 'kubernetes-kube-state-metrics' LIMIT MAX)), 1 second) / filter(max(kube_pod_container_resource_limits), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND resource = 'cpu') * 100 WHERE container IS NOT NULL AND pod IS NOT NULL AND namespace IN ({{namespaces}}) FACET pod, container TIMESERIES AUTO"
      }
    }

    # Container MEM Usage per Pod (bytes)
    widget_area {
      title  = "Container MEM Usage per Pod (bytes)"
      row    = 8
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT average(container_memory_usage_bytes) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND container IS NOT NULL AND pod IS NOT NULL AND namespace IN ({{namespaces}}) FACET pod, container TIMESERIES AUTO"
      }
    }

    # Container MEM Utilization per Pod (%)
    widget_line {
      title  = "Container MEM Utilization per Pod (%)"
      row    = 8
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT filter(average(container_memory_usage_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND container IN (FROM Metric SELECT uniques(container) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND kube_pod_container_resource_limits IS NOT NULL AND service.name = 'kubernetes-kube-state-metrics' AND resource = 'memory' LIMIT MAX)) / filter(max(kube_pod_container_resource_limits), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND resource = 'memory') * 100 WHERE container IS NOT NULL AND pod IS NOT NULL AND namespace IN ({{namespaces}}) FACET pod, container TIMESERIES AUTO"
      }
    }

    # Container File System Read Rate per Pod (1/s)
    widget_area {
      title  = "Container File System Read Rate per Pod (1/s)"
      row    = 11
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT rate(average(container_fs_reads), 1 SECOND) AS `rate` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND container IS NOT NULL AND pod IS NOT NULL AND namespace IN ({{namespaces}}) FACET pod, container TIMESERIES AUTO"
      }
    }

    # Container File System Write Rate per Pod (1/s)
    widget_line {
      title  = "Container File System Write Rate per Pod (1/s)"
      row    = 11
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT rate(average(container_fs_writes), 1 SECOND) AS `rate` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND container IS NOT NULL AND pod IS NOT NULL AND namespace IN ({{namespaces}}) FACET pod, container TIMESERIES AUTO"
      }
    }

    # Container Network Receive Rate per Pod (MB/s)
    widget_area {
      title  = "Container Network Receive Rate per Pod (MB/s)"
      row    = 14
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT rate(average(container_network_receive_bytes)/1024/1024, 1 SECOND) AS `rate` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND container IS NOT NULL AND pod IS NOT NULL AND namespace IN ({{namespaces}}) FACET pod, container TIMESERIES AUTO"
      }
    }

    # Container Network Transmit Rate per Pod (MB/s)
    widget_line {
      title  = "Container Network Transmit Rate per Pod (MB/s)"
      row    = 14
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM Metric SELECT rate(average(container_network_transmit_bytes)/1024/1024, 1 SECOND) AS `rate` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND container IS NOT NULL AND pod IS NOT NULL AND namespace IN ({{namespaces}}) FACET pod, container TIMESERIES AUTO"
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
      query       = "FROM Metric SELECT uniques(node) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}'"
    }
  }

  # Namespaces
  variable {
    name  = "namespaces"
    title = "Namespaces"
    type  = "nrql"

    default_values       = ["*"]
    replacement_strategy = "default"
    is_multi_selection   = true

    nrql_query {
      account_ids = [var.NEW_RELIC_ACCOUNT_ID]
      query       = "FROM Metric SELECT uniques(namespace) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}'"
    }
  }
}

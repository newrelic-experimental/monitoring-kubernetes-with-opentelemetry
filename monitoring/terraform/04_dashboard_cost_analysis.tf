##################
### Dashboards ###
##################

# Dashboard - Cost analysis
resource "newrelic_one_dashboard" "cost_analysis" {
  name = "K8s | ${var.cluster_name} | Operational Cost Analysis"

  #####################
  ### Node OVERVIEW ###
  #####################
  page {
    name = "Node Overview"

    # Page Description
    widget_markdown {
      title  = ""
      row    = 1
      column = 1
      height = 4
      width  = 8

      text = "## Do not throw away your money!!!\nThis page calculates you the amount of money which you lose due to not fully profiting from your virtual machines. The calculation is made both for CPU and MEM independently where the cost is considered for both CPU and MEM as if they represent the half of the unit price. According to your loss of CPU or MEM, change your VM type.\n- If you benefit neither from CPU or MEM, simply scale down your VM or shutdown some of the VMs within a node group.\n- If you benefit from CPU but not from MEM, choose a CPU optimized VM.\n- If you benefit from MEM but not from CPU, choose a MEM optimized VM.\n\n### CPU\nThe CPU running in idle mode is considered as loss of money.\n```\nmoneyLoss [$/hour] = idleCpu [vcores] * (price [$/hour] * cpuProportion [1/2] / totalCpu [vcores])\n```\n\n\n### MEM\nThe non-allocated free space on your nodes are being considered as loss of money.\n```\nmoneyLoss [$/hour] = freeMemory [GB] * (price [$/hour] * memoryProportion [1/2] / totalMemory [GB])\n```"
    }

    # Node Capacities
    widget_table {
      title  = "Node Capacities"
      row    = 1
      column = 9
      height = 2
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM Metric SELECT uniqueCount(cpu) AS 'CPU (cores)', max(node_memory_MemTotal_bytes)/1000/1000/1000 AS 'MEM (GB)'
          WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
          AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} FACET k8s.node.name
        EOF
      }
    }

    # Total money being paid to CPU of the VMs ($)
    widget_billboard {
      title  = "Total money being paid to CPU of the VMs ($)"
      row    = 3
      column = 9
      height = 2
      width  = 2

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT 0.5*{{price_per_hour}} AS `cost`
            WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
            AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} FACET k8s.node.name TIMESERIES 1 hour
          ) SELECT sum(`cost`) SINCE 1 week ago
        EOF
      }
    }

    # Total money being paid to MEM of the VMs ($)
    widget_billboard {
      title  = "Total money being paid to MEM of the VMs ($)"
      row    = 3
      column = 11
      height = 2
      width  = 2

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT 0.5*{{price_per_hour}} AS `cost`
            WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
            AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} FACET k8s.node.name TIMESERIES 1 hour
          ) SELECT sum(`cost`) SINCE 1 week ago
        EOF
      }
    }

    # Lost money due to lack of CPU allocation ($)
    widget_billboard {
      title  = "Lost money due to lack of CPU allocation ($)"
      row    = 5
      column = 1
      height = 3
      width  = 2

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT 0.5*{{price_per_hour}}*
            rate(
              filter(
                sum(node_cpu_seconds_total), WHERE mode = 'idle'
              ), 1 SECONDS
            )
            /
            uniqueCount(cpu) AS `costPerHour` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
              AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} FACET k8s.node.name TIMESERIES 1 hour
          ) SELECT sum(`costPerHour`) SINCE 1 week ago
        EOF
      }
    }

    # Lost money due to lack of CPU allocation ($)
    widget_bar {
      title  = "Lost money due to lack of CPU allocation ($)"
      row    = 5
      column = 3
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT 0.5*{{price_per_hour}}*
            rate(
              filter(
                sum(node_cpu_seconds_total), WHERE mode = 'idle'
              ), 1 SECONDS
            )
            /
            uniqueCount(cpu) AS `costPerHour` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
              AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} FACET k8s.node.name TIMESERIES 1 hour
          ) SELECT sum(`costPerHour`) FACET k8s.node.name SINCE 1 week ago
        EOF
      }
    }

    # Lost money due to lack of CPU allocation ($)
    widget_line {
      title  = "Lost money due to lack of CPU allocation ($)"
      row    = 5
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM Metric SELECT 0.5*{{price_per_hour}}*
          rate(
            filter(
              sum(node_cpu_seconds_total), WHERE mode = 'idle'
            ), 1 SECONDS
          )
          /
          uniqueCount(cpu) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
            AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} FACET k8s.node.name TIMESERIES 1 hour SINCE 1 week ago
        EOF
      }
    }

    # Lost money due to lack of MEM allocation ($)
    widget_billboard {
      title  = "Lost money due to lack of MEM allocation ($)"
      row    = 8
      column = 1
      height = 3
      width  = 2

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT
            (
              average(node_memory_MemFree_bytes) + average(node_memory_Cached_bytes) + average(node_memory_Buffers_bytes)
            )
            *
            (
              0.5*{{price_per_hour}}/average(node_memory_MemTotal_bytes)
            ) AS `costPerHour` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
              AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} FACET k8s.node.name TIMESERIES 1 hour
          ) SELECT sum(`costPerHour`) SINCE 1 week ago
        EOF
      }
    }

    # Lost money due to lack of MEM allocation ($)
    widget_bar {
      title  = "Lost money due to lack of MEM allocation ($)"
      row    = 8
      column = 3
      height = 3
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT (
            average(node_memory_MemFree_bytes) + average(node_memory_Cached_bytes) + average(node_memory_Buffers_bytes)
          )
          *
          (
            0.5*{{price_per_hour}}/average(node_memory_MemTotal_bytes)
          ) AS `costPerHour` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
            AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} FACET k8s.node.name TIMESERIES 1 hour
          ) SELECT sum(`costPerHour`) FACET k8s.node.name SINCE 1 week ago
        EOF
      }
    }

    # Lost money due to lack of MEM allocation ($)
    widget_line {
      title  = "Lost money due to lack of MEM allocation ($)"
      row    = 8
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM Metric SELECT
          (
            average(node_memory_MemFree_bytes) + average(node_memory_Cached_bytes) + average(node_memory_Buffers_bytes)
          )
          *
          (
            0.5*{{price_per_hour}}/average(node_memory_MemTotal_bytes)
          ) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
            AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} FACET k8s.node.name TIMESERIES 1 hour SINCE 1 week ago
        EOF
      }
    }
  }

  ##########################
  ### NAMESPACE OVERVIEW ###
  ##########################
  page {
    name = "Namespace Overview"

    # Actual cost
    widget_markdown {
      title  = ""
      row    = 1
      column = 1
      height = 4
      width  = 4

      text = "## Actual cost of workloads\nThis page calculates you the amount of money which represents the actual cost of the individual workloads running in your cluster. The calculation is made both for CPU and MEM independently per 6 hours manner where the cost is considered for both CPU and MEM as if they represent the half of the unit price.\n\n### CPU\nThe actual CPU cost is calculated as follows.\n```\nactualCost [$/6hour] = 6 * price [$/6hour] * \ncpuProportion [1/2] * (usedCpu [vcores] / totalCpu [vcores])\n```\n\n\n### MEM\nThe actual MEM cost is calculated as follows.\n```\nactualCost [$/6hour] = 6 * price [$/6hour] * \nmemProportion [1/2] * (usedMemory [GB] / totalMemory [GB])\n```"
    }

    # Actual cost of CPU consumption ($)
    widget_pie {
      title  = "Actual cost of CPU consumption ($)"
      row    = 1
      column = 5
      height = 4
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT 6.0*{{price_per_hour}}*0.5*
            (
              rate(
                filter(
                  sum(container_cpu_usage_seconds_total), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor'
                    AND container IS NOT NULL AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
                ), 1 second
              )
              /
              (
                FROM Metric SELECT 
                  filter(
                    uniqueCount(cpu), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
                      AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}}
                  )
              )
            ) AS `result` FACET pod, container, namespace TIMESERIES 6 hours LIMIT MAX) SELECT sum(`result`) AS `Costs` FACET namespace SINCE 1 week ago
        EOF
      }
    }

    # Actual cost of MEM consumption ($)
    widget_pie {
      title  = "Actual cost of MEM consumption ($)"
      row    = 1
      column = 9
      height = 4
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT 6.0*{{price_per_hour}}*0.5*
            (
              filter(
                average(container_memory_usage_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor'
                  AND container IS NOT NULL AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
              )
            ) AS `result` FACET pod, container, namespace TIMESERIES 6 hours LIMIT MAX
          ) SELECT sum(`result`)
          /
          (
            FROM Metric SELECT
              filter(
                average(node_memory_MemTotal_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
                  AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}}
              )
          ) AS `Costs` FACET namespace SINCE 1 week ago
        EOF
      }
    }

    # Actual cost of CPU consumption ($)
    widget_bar {
      title  = "Actual cost of CPU consumption ($)"
      row    = 5
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT 6.0*{{price_per_hour}}*0.5*
            (
              rate(
                filter(
                  sum(container_cpu_usage_seconds_total), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor'
                    AND container IS NOT NULL AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
                ), 1 second
              )
              /
              (
                FROM Metric SELECT 
                  filter(
                    uniqueCount(cpu), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
                      AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}}
                  )
              )
            ) AS `result` FACET pod, container, namespace TIMESERIES 6 hours LIMIT MAX) SELECT sum(`result`) AS `Costs` FACET namespace SINCE 1 week ago
        EOF
      }
    }

    # Actual cost of CPU consumption ($)
    widget_line {
      title  = "Actual cost of CPU consumption ($)"
      row    = 5
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM Metric SELECT 6.0*{{price_per_hour}}*0.5*
          (
            rate(
              filter(
                sum(container_cpu_usage_seconds_total), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor'
                  AND container IS NOT NULL AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
              ), 1 second
            )
          )
          /
          (
            FROM Metric SELECT
              filter(
                uniqueCount(cpu), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
                  AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}}
              )
          ) AS `Costs` FACET namespace TIMESERIES 6 hours LIMIT MAX SINCE 1 week ago
        EOF
      }
    }

    # Actual cost of MEM consumption ($)
    widget_bar {
      title  = "Actual cost of MEM consumption ($)"
      row    = 8
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT 6.0*{{price_per_hour}}*0.5*
            (
              filter(
                average(container_memory_usage_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor'
                  AND container IS NOT NULL AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
              )
            ) AS `result` FACET pod, container, namespace TIMESERIES 6 hours LIMIT MAX
          ) SELECT sum(`result`)
          /
          (
            FROM Metric SELECT
              filter(
                average(node_memory_MemTotal_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
                  AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}}
              )
          ) AS `Costs` FACET namespace SINCE 1 week ago
        EOF
      }
    }

    # Actual cost of MEM consumption ($)
    widget_line {
      title  = "Actual cost of MEM consumption ($)"
      row    = 8
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT 6.0*{{price_per_hour}}*0.5*
            (
              filter(
                average(container_memory_usage_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor'
                  AND container IS NOT NULL AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
              )
            ) AS `result` FACET pod, container, namespace TIMESERIES 6 hours LIMIT MAX) SELECT sum(`result`)
            /
            (
              FROM Metric SELECT 
                filter(
                  average(node_memory_MemTotal_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
                    AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}}
                )
            ) AS `Costs` FACET namespace TIMESERIES 6 hours SINCE 1 week ago
        EOF
      }
    }

    # Lost money
    widget_markdown {
      title  = ""
      row    = 11
      column = 1
      height = 4
      width  = 4

      text = "## Lost money of workloads\nThis page calculates you the amount of money which you lose by not fully profiting from the resources that you have requested for your workloads. The calculation is made both for CPU and MEM independently in 6 hours manner where the cost is considered for both CPU and MEM as if they represent the half of the unit price.\n\n### CPU\nThe actual CPU cost is calculated as follows.\n```\nactualCost [$/6hour] = 6 * price [$/6hour] * \ncpuProportion [1/2] * ((requestedCpu [vcores] - usedCpu [vcores])\n / totalCpu [vcores])\n```\n\n\n### MEM\nThe actual MEM cost is calculated as follows.\n```\nactualCost [$/6hour] = 6 * price [$/6hour] * \nmemProportion [1/2] * ((requestedMemory [GB] - usedMemory [GB])\n / totalMemory [GB])\n```"
    }

    # Lost money due to CPU ($)
    widget_pie {
      title  = "Lost money due to CPU ($)"
      row    = 11
      column = 5
      height = 4
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT 6.0*{{price_per_hour}}*0.5*
            (
              filter(
                average(kube_pod_container_resource_requests), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics'
                  AND resource = 'cpu' AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
              )
              -
              rate(
                filter(
                  sum(container_cpu_usage_seconds_total), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND
                    container IN
                      (
                        FROM Metric SELECT uniques(container) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics'
                          AND kube_pod_container_resource_limits IS NOT NULL AND resource = 'cpu' LIMIT MAX
                      )
                    AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
                ), 1 second
              )
            )
            /
            (
              FROM Metric SELECT 
                filter(
                  uniqueCount(cpu), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
                    AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}}
                )
            ) AS `result` FACET pod, container, namespace TIMESERIES 6 hours LIMIT MAX) SELECT sum(if(`result` > 0.0, `result`, 0.0)) AS `Losts` FACET namespace SINCE 1 week ago
        EOF
      }
    }

    # Lost money due to MEM ($)
    widget_pie {
      title  = "Lost money due to MEM ($)"
      row    = 11
      column = 9
      height = 4
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT 6.0*{{price_per_hour}}*0.5*
            (
              filter(
                average(kube_pod_container_resource_requests), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics'
                  AND resource = 'memory' AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
              )
              -
              filter(
                average(container_memory_usage_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor'
                  AND container IS NOT NULL AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
              )
            ) AS `result` FACET pod, container, namespace TIMESERIES 6 hours LIMIT MAX) SELECT sum(if(`result` > 0.0, `result`, 0.0))
            /
            (
              FROM Metric SELECT
                filter(
                  average(node_memory_MemTotal_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
                    AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}}
                )
            ) AS `Losts` FACET namespace SINCE 1 week ago
        EOF
      }
    }

    # Lost money due to CPU ($)
    widget_bar {
      title  = "Lost money due to CPU ($)"
      row    = 15
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT 6.0*{{price_per_hour}}*0.5*
            (
              filter(
                average(kube_pod_container_resource_requests), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics'
                  AND resource = 'cpu' AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
              )
              -
              rate(
                filter(
                  sum(container_cpu_usage_seconds_total), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND
                    container IN
                      (
                        FROM Metric SELECT uniques(container) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics'
                          AND kube_pod_container_resource_limits IS NOT NULL AND resource = 'cpu' LIMIT MAX
                      )
                    AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
                ), 1 second
              )
            )
            /
            (
              FROM Metric SELECT 
                filter(
                  uniqueCount(cpu), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
                    AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}}
                )
            ) AS `result` FACET pod, container, namespace TIMESERIES 6 hours LIMIT MAX) SELECT sum(if(`result` > 0.0, `result`, 0.0)) AS `Losts` FACET namespace SINCE 1 week ago
        EOF
      }
    }

    # Lost money due to CPU ($)
    widget_line {
      title  = "Lost money due to CPU ($)"
      row    = 15
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT 6.0*{{price_per_hour}}*0.5*
            (
              filter(
                average(kube_pod_container_resource_requests), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics'
                  AND resource = 'cpu' AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
              )
              -
              rate(
                filter(
                  sum(container_cpu_usage_seconds_total), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND
                    container IN
                      (
                        FROM Metric SELECT uniques(container) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics'
                          AND kube_pod_container_resource_limits IS NOT NULL AND resource = 'cpu' LIMIT MAX
                      )
                    AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
                ), 1 second
              )
            )
            /
            (
              FROM Metric SELECT 
                filter(
                  uniqueCount(cpu), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
                    AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}}
                )
            ) AS `result` FACET pod, container, namespace TIMESERIES 6 hours LIMIT MAX) SELECT sum(if(`result` > 0.0, `result`, 0.0)) AS `Losts` FACET namespace TIMESERIES 6 hours SINCE 1 week ago
        EOF
      }
    }

    # Lost money due to MEM ($)
    widget_bar {
      title  = "Lost money due to MEM ($)"
      row    = 18
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT 6.0*{{price_per_hour}}*0.5*
            (
              filter(
                average(kube_pod_container_resource_requests), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics'
                  AND resource = 'memory' AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
              )
              -
              filter(
                average(container_memory_usage_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor'
                  AND container IS NOT NULL AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
              )
            ) AS `result` FACET pod, container, namespace TIMESERIES 6 hours LIMIT MAX) SELECT sum(if(`result` > 0.0, `result`, 0.0))
            /
            (
              FROM Metric SELECT
                filter(
                  average(node_memory_MemTotal_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
                    AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}}
                )
            ) AS `Losts` FACET namespace SINCE 1 week ago
        EOF
      }
    }

    # Lost money due to MEM ($)
    widget_line {
      title  = "Lost money due to MEM ($)"
      row    = 18
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT 6.0*{{price_per_hour}}*0.5*
            (
              filter(
                average(kube_pod_container_resource_requests), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics'
                  AND resource = 'memory' AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
              )
              -
              filter(
                average(container_memory_usage_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor'
                  AND container IS NOT NULL AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
              )
            ) AS `result` FACET pod, container, namespace TIMESERIES 6 hours LIMIT MAX) SELECT sum(if(`result` > 0.0, `result`, 0.0))
            /
            (
              FROM Metric SELECT
                filter(
                  average(node_memory_MemTotal_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
                    AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}}
                )
            ) AS `Losts` FACET namespace TIMESERIES 6 hours SINCE 1 week ago
        EOF
      }
    }
  }

  ####################
  ### POD OVERVIEW ###
  ####################
  page {
    name = "Pod Overview"

    # Actual cost
    widget_markdown {
      title  = ""
      row    = 1
      column = 1
      height = 4
      width  = 4

      text = "## Actual cost of workloads\nThis page calculates you the amount of money which represents the actual cost of the individual workloads running in your cluster. The calculation is made both for CPU and MEM independently per 6 hours manner where the cost is considered for both CPU and MEM as if they represent the half of the unit price.\n\n### CPU\nThe actual CPU cost is calculated as follows.\n```\nactualCost [$/6hour] = 6 * price [$/6hour] * \ncpuProportion [1/2] * (usedCpu [vcores] / totalCpu [vcores])\n```\n\n\n### MEM\nThe actual MEM cost is calculated as follows.\n```\nactualCost [$/6hour] = 6 * price [$/6hour] * \nmemProportion [1/2] * (usedMemory [GB] / totalMemory [GB])\n```"
    }

    # Actual cost of CPU consumption ($)
    widget_pie {
      title  = "Actual cost of CPU consumption ($)"
      row    = 1
      column = 5
      height = 4
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT 6.0*{{price_per_hour}}*0.5*
            (
              rate(
                filter(
                  sum(container_cpu_usage_seconds_total), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor'
                    AND container IS NOT NULL AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
                ), 1 second
              )
              /
              (
                FROM Metric SELECT 
                  filter(
                    uniqueCount(cpu), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
                      AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}}
                  )
              )
            ) AS `result` FACET pod, container TIMESERIES 6 hours LIMIT MAX) SELECT sum(`result`) AS `Costs` FACET pod, container SINCE 1 week ago
        EOF
      }
    }

    # Actual cost of MEM consumption ($)
    widget_pie {
      title  = "Actual cost of MEM consumption ($)"
      row    = 1
      column = 9
      height = 4
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT 6.0*{{price_per_hour}}*0.5*
            (
              filter(
                average(container_memory_usage_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor'
                  AND container IS NOT NULL AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
              )
            ) AS `result` FACET pod, container TIMESERIES 6 hours LIMIT MAX
          ) SELECT sum(`result`)
          /
          (
            FROM Metric SELECT
              filter(
                average(node_memory_MemTotal_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
                  AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}}
              )
          ) AS `Costs` FACET pod, container SINCE 1 week ago
        EOF
      }
    }

    # Actual cost of CPU consumption ($)
    widget_bar {
      title  = "Actual cost of CPU consumption ($)"
      row    = 5
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT 6.0*{{price_per_hour}}*0.5*
            (
              rate(
                filter(
                  sum(container_cpu_usage_seconds_total), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor'
                    AND container IS NOT NULL AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
                ), 1 second
              )
              /
              (
                FROM Metric SELECT 
                  filter(
                    uniqueCount(cpu), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
                      AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}}
                  )
              )
            ) AS `result` FACET pod, container TIMESERIES 6 hours LIMIT MAX) SELECT sum(`result`) AS `Costs` FACET pod, container SINCE 1 week ago
        EOF
      }
    }

    # Actual cost of CPU consumption ($)
    widget_line {
      title  = "Actual cost of CPU consumption ($)"
      row    = 5
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM Metric SELECT 6.0*{{price_per_hour}}*0.5*
          (
            rate(
              filter(
                sum(container_cpu_usage_seconds_total), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor'
                  AND container IS NOT NULL AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
              ), 1 second
            )
          )
          /
          (
            FROM Metric SELECT
              filter(
                uniqueCount(cpu), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
                  AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}}
              )
          ) AS `Costs` FACET pod, container TIMESERIES 6 hours SINCE 1 week ago
        EOF
      }
    }

    # Actual cost of MEM consumption ($)
    widget_bar {
      title  = "Actual cost of MEM consumption ($)"
      row    = 8
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT 6.0*{{price_per_hour}}*0.5*
            (
              filter(
                average(container_memory_usage_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor'
                  AND container IS NOT NULL AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
              )
            ) AS `result` FACET pod, container TIMESERIES 6 hours LIMIT MAX
          ) SELECT sum(`result`)
          /
          (
            FROM Metric SELECT
              filter(
                average(node_memory_MemTotal_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
                  AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}}
              )
          ) AS `Costs` FACET pod, container SINCE 1 week ago
        EOF
      }
    }

    # Actual cost of MEM consumption ($)
    widget_line {
      title  = "Actual cost of MEM consumption ($)"
      row    = 8
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT 6.0*{{price_per_hour}}*0.5*
            (
              filter(
                average(container_memory_usage_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor'
                  AND container IS NOT NULL AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
              )
            ) AS `result` FACET pod, container TIMESERIES 6 hours LIMIT MAX) SELECT sum(`result`)
            /
            (
              FROM Metric SELECT 
                filter(
                  average(node_memory_MemTotal_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
                    AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}}
                )
            ) AS `Costs` FACET pod, container TIMESERIES 6 hours SINCE 1 week ago
        EOF
      }
    }

    # Lost money
    widget_markdown {
      title  = ""
      row    = 11
      column = 1
      height = 4
      width  = 4

      text = "## Lost money of workloads\nThis page calculates you the amount of money which you lose by not fully profiting from the resources that you have requested for your workloads. The calculation is made both for CPU and MEM per 6 hours manner independently where the cost is considered for both CPU and MEM as if they represent the half of the unit price.\n\n### CPU\nThe actual CPU cost is calculated as follows.\n```\nactualCost [$/6hour] = 6 * price [$/6hour] * \ncpuProportion [1/2] * ((requestedCpu [vcores] - usedCpu [vcores])\n / totalCpu [vcores])\n```\n\n\n### MEM\nThe actual MEM cost is calculated as follows.\n```\nactualCost [$/6hour] = 6 * price [$/6hour] * \nmemProportion [1/2] * (requestedMemory [GB] - usedMemory [GB])\n / totalMemory [GB])\n```"
    }

    # Lost money due to CPU ($)
    widget_pie {
      title  = "Lost money due to CPU ($)"
      row    = 11
      column = 5
      height = 4
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT 6.0*{{price_per_hour}}*0.5*
            (
              filter(
                average(kube_pod_container_resource_requests), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics'
                  AND resource = 'cpu' AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
              )
              -
              rate(
                filter(
                  sum(container_cpu_usage_seconds_total), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND
                    container IN
                      (
                        FROM Metric SELECT uniques(container) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics'
                          AND kube_pod_container_resource_limits IS NOT NULL AND resource = 'cpu' LIMIT MAX
                      )
                    AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
                ), 1 second
              )
            )
            /
            (
              FROM Metric SELECT 
                filter(
                  uniqueCount(cpu), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
                    AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}}
                )
            ) AS `result` FACET pod, container TIMESERIES 6 hours LIMIT MAX) SELECT sum(if(`result` > 0.0, `result`, 0.0)) AS `Losts` FACET pod, container SINCE 1 week ago
        EOF
      }
    }

    # Lost money due to MEM ($)
    widget_pie {
      title  = "Lost money due to MEM ($)"
      row    = 11
      column = 9
      height = 4
      width  = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT 6.0*{{price_per_hour}}*0.5*
            (
              filter(
                average(kube_pod_container_resource_requests), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics'
                  AND resource = 'memory' AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
              )
              -
              filter(
                average(container_memory_usage_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor'
                  AND container IS NOT NULL AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
              )
            ) AS `result` FACET pod, container TIMESERIES 6 hours LIMIT MAX) SELECT sum(if(`result` > 0.0, `result`, 0.0))
            /
            (
              FROM Metric SELECT
                filter(
                  average(node_memory_MemTotal_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
                    AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}}
                )
            ) AS `Losts` FACET pod, container SINCE 1 week ago
        EOF
      }
    }

    # Lost money due to CPU ($)
    widget_bar {
      title  = "Lost money due to CPU ($)"
      row    = 15
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT 6.0*{{price_per_hour}}*0.5*
            (
              filter(
                average(kube_pod_container_resource_requests), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics'
                  AND resource = 'cpu' AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
              )
              -
              rate(
                filter(
                  sum(container_cpu_usage_seconds_total), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND
                    container IN
                      (
                        FROM Metric SELECT uniques(container) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics'
                          AND kube_pod_container_resource_limits IS NOT NULL AND resource = 'cpu' LIMIT MAX
                      )
                    AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
                ), 1 second
              )
            )
            /
            (
              FROM Metric SELECT 
                filter(
                  uniqueCount(cpu), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
                    AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}}
                )
            ) AS `result` FACET pod, container TIMESERIES 6 hours LIMIT MAX) SELECT sum(if(`result` > 0.0, `result`, 0.0)) AS `Losts` FACET pod, container SINCE 1 week ago
        EOF
      }
    }

    # Lost money due to CPU ($)
    widget_line {
      title  = "Lost money due to CPU ($)"
      row    = 15
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT 6.0*{{price_per_hour}}*0.5*
            (
              filter(
                average(kube_pod_container_resource_requests), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics'
                  AND resource = 'cpu' AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
              )
              -
              rate(
                filter(
                  sum(container_cpu_usage_seconds_total), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor' AND
                    container IN
                      (
                        FROM Metric SELECT uniques(container) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics'
                          AND kube_pod_container_resource_limits IS NOT NULL AND resource = 'cpu' LIMIT MAX
                      )
                    AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
                ), 1 second
              )
            )
            /
            (
              FROM Metric SELECT 
                filter(
                  uniqueCount(cpu), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
                    AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}}
                )
            ) AS `result` FACET pod, container TIMESERIES 6 hours LIMIT MAX) SELECT sum(if(`result` > 0.0, `result`, 0.0)) AS `Losts` FACET pod, container TIMESERIES 6 hours SINCE 1 week ago
        EOF
      }
    }

    # Lost money due to MEM ($)
    widget_bar {
      title  = "Lost money due to MEM ($)"
      row    = 18
      column = 1
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT 6.0*{{price_per_hour}}*0.5*
            (
              filter(
                average(kube_pod_container_resource_requests), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics'
                  AND resource = 'memory' AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
              )
              -
              filter(
                average(container_memory_usage_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor'
                  AND container IS NOT NULL AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
              )
            ) AS `result` FACET pod, container TIMESERIES 6 hours LIMIT MAX) SELECT sum(if(`result` > 0.0, `result`, 0.0))
            /
            (
              FROM Metric SELECT
                filter(
                  average(node_memory_MemTotal_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
                    AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}}
                )
            ) AS `Losts` FACET pod, container SINCE 1 week ago
        EOF
      }
    }

    # Lost money due to MEM ($)
    widget_line {
      title  = "Lost money due to MEM ($)"
      row    = 18
      column = 7
      height = 3
      width  = 6

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = <<EOF
        FROM (
          FROM Metric SELECT 6.0*{{price_per_hour}}*0.5*
            (
              filter(
                average(kube_pod_container_resource_requests), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics'
                  AND resource = 'memory' AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
              )
              -
              filter(
                average(container_memory_usage_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor'
                  AND container IS NOT NULL AND pod IS NOT NULL AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}} AND namespace IN ({{namespaces}})
              )
            ) AS `result` FACET pod, container TIMESERIES 6 hours LIMIT MAX) SELECT sum(if(`result` > 0.0, `result`, 0.0))
            /
            (
              FROM Metric SELECT
                filter(
                  average(node_memory_MemTotal_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter'
                    AND cloud.provider = {{cloud_provider}} AND cloud.region = {{cloud_region}} AND vm.type = {{vm_type}}
                )
            ) AS `Losts` FACET pod, container TIMESERIES 6 hours SINCE 1 week ago
        EOF
      }
    }
  }

  # Cloud provider
  variable {
    name  = "cloud_provider"
    title = "Cloud Provider"
    type  = "nrql"

    default_values       = ["*"]
    replacement_strategy = "default"
    is_multi_selection   = false

    nrql_query {
      account_ids = [var.NEW_RELIC_ACCOUNT_ID]
      query       = "FROM Metric SELECT uniques(cloud.provider) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' LIMIT MAX"
    }
  }

  # Cloud provider
  variable {
    name  = "cloud_region"
    title = "Cloud Region"
    type  = "nrql"

    default_values       = ["*"]
    replacement_strategy = "default"
    is_multi_selection   = false

    nrql_query {
      account_ids = [var.NEW_RELIC_ACCOUNT_ID]
      query       = "FROM Metric SELECT uniques(cloud.region) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' LIMIT MAX"
    }
  }

  # VM type
  variable {
    name  = "vm_type"
    title = "VM Type"
    type  = "nrql"

    default_values       = ["*"]
    replacement_strategy = "default"
    is_multi_selection   = false

    nrql_query {
      account_ids = [var.NEW_RELIC_ACCOUNT_ID]
      query       = "FROM Metric SELECT uniques(vm.type) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' LIMIT MAX"
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

  # Price per hour
  variable {
    name  = "price_per_hour"
    title = "$/hour"
    type  = "string"

    default_values       = ["1"]
    replacement_strategy = "number"
  }
}

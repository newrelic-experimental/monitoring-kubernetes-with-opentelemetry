##############
### Alerts ###
##############

# Policy
resource "newrelic_alert_policy" "pod" {
  name                = "K8s | ${var.cluster_name} | Pods"
  incident_preference = "PER_CONDITION"
}

# Condition - Status
resource "newrelic_nrql_alert_condition" "pod_status" {
  account_id = var.NEW_RELIC_ACCOUNT_ID
  policy_id  = newrelic_alert_policy.pod.id
  type       = "static"
  name       = "Pod status"

  description = <<-EOT
  Your pod is down! Check if:
  - it cannot be scheduled on a node.
  - one of its containers cannot pull its image.
  - it is failing to establish a necessary connection as it gets initialized.
  EOT

  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT latest(kube_pod_status_phase) AS `failed` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND phase != 'Running' FACET pod"
  }

  critical {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
  fill_option        = "none"
  aggregation_window = 60
  aggregation_method = "event_timer"
  aggregation_timer  = 5
}

# Condition - CPU utilization too high
resource "newrelic_nrql_alert_condition" "pod_cpu_utilization_high" {
  account_id = var.NEW_RELIC_ACCOUNT_ID
  policy_id  = newrelic_alert_policy.pod.id
  type       = "static"
  name       = "CPU utilization too high"

  description = <<-EOT
  Your pod is about to reach its maximum CPU capacity!
  - Check if there is an external request or an internal batch job has a computation-intensive retry policy.
  - Check if you have reached the maximum amount of replicas in case the pod is attached to an HPA.
     - If not, check why no additional replicas can be scheduled on any node.
        - Check if there are no other schedulable nodes available and if not, why?
  - Consider increasing the given CPU limit.
  EOT

  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT rate(filter(sum(container_cpu_usage_seconds_total), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor'), 1 second) / filter(max(kube_pod_container_resource_limits), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND resource = 'cpu') * 100 WHERE container IS NOT NULL AND pod IS NOT NULL FACET pod, container"
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

# Condition - CPU utilization too low
resource "newrelic_nrql_alert_condition" "pod_cpu_utilization_low" {
  account_id = var.NEW_RELIC_ACCOUNT_ID
  policy_id  = newrelic_alert_policy.pod.id
  type       = "static"
  name       = "CPU utilization too low"

  description = <<-EOT
  Your pod is not benefiting from the CPU request it has been given!
  You are automatically allocating unnecessary CPU on a node for the pod which it's not using. This might cause scheduling issues for other "to-be-scheduled" pods on the nodes where this pod is running since they might not find the necessary empty space in terms of CPU on these nodes.
  - Consider lowering the amount of requested CPU for the pod.
  EOT

  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT rate(filter(sum(container_cpu_usage_seconds_total), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor'), 1 second) / filter(max(kube_pod_container_resource_requests), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND resource = 'cpu') * 100 WHERE container IS NOT NULL AND pod IS NOT NULL FACET pod, container"
  }

  critical {
    operator              = "below"
    threshold             = 50
    threshold_duration    = 21600
    threshold_occurrences = "all"
  }
  fill_option        = "none"
  aggregation_window = 60
  aggregation_method = "event_flow"
  aggregation_delay  = 0
}

# Condition - MEM utilization too high
resource "newrelic_nrql_alert_condition" "pod_mem_utilization_high" {
  account_id = var.NEW_RELIC_ACCOUNT_ID
  policy_id  = newrelic_alert_policy.pod.id
  type       = "static"
  name       = "MEM utilization too high"

  description = <<-EOT
  Your pod is about to reach its maximum memory capacity!
  - Check if there is a memory leak.
  - Check if you have reached the maximum amount of replicas in case the pod is attached to an HPA.
     - If not, check why no additional replicas can be scheduled on any node.
        - Check if there are no other schedulable nodes available and if not, why?
  - Consider increasing the given memory limit.
  EOT

  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT filter(average(container_memory_working_set_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor') / filter(max(kube_pod_container_resource_limits), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND resource = 'memory') * 100 WHERE container IS NOT NULL AND pod IS NOT NULL FACET pod, container"
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

# Condition - MEM utilization too low
resource "newrelic_nrql_alert_condition" "pod_mem_utilization_low" {
  account_id = var.NEW_RELIC_ACCOUNT_ID
  policy_id  = newrelic_alert_policy.pod.id
  type       = "static"
  name       = "MEM utilization too low"

  description = <<-EOT
  Your pod is not benefiting from the memory request it has been given!
  You are automatically allocating unnecessary memory on a node for the pod which it's not using. This might cause scheduling issues for other "to-be-scheduled" pods on the nodes where this pod is running since they might not find the necessary empty space in terms of memory on these nodes.
  - Consider lowering the amount of requested memory for the pod.
  EOT

  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT filter(average(container_memory_working_set_bytes), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-nodes-cadvisor') / filter(max(kube_pod_container_resource_requests), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-kube-state-metrics' AND resource = 'memory') * 100 WHERE container IS NOT NULL AND pod IS NOT NULL FACET pod, container"
  }

  critical {
    operator              = "below"
    threshold             = 50
    threshold_duration    = 21600
    threshold_occurrences = "all"
  }
  fill_option        = "none"
  aggregation_window = 60
  aggregation_method = "event_flow"
  aggregation_delay  = 0
}

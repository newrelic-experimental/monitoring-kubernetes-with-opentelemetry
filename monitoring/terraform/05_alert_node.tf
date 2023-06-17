##############
### Alerts ###
##############

# Policy
resource "newrelic_alert_policy" "node" {
  name                = "K8s | ${var.cluster_name} | Nodes"
  incident_preference = "PER_CONDITION"
}

# Condition - Status
resource "newrelic_nrql_alert_condition" "node_status" {
  account_id = var.NEW_RELIC_ACCOUNT_ID
  policy_id  = newrelic_alert_policy.node.id
  type       = "static"
  name       = "Node status"

  description = <<-EOT
  Your node is down!
  EOT

  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT latest(up) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter' FACET k8s.node.name"
  }

  critical {
    operator              = "below"
    threshold             = 1
    threshold_duration    = 300
    threshold_occurrences = "all"
  }
  fill_option        = "none"
  aggregation_window = 60
  aggregation_method = "event_timer"
  aggregation_timer  = 5
}

# Condition - CPU utilization too high
resource "newrelic_nrql_alert_condition" "node_cpu_utilization_high" {
  account_id = var.NEW_RELIC_ACCOUNT_ID
  policy_id  = newrelic_alert_policy.node.id
  type       = "static"
  name       = "CPU utilization too high"

  description = <<-EOT
  Your node is about to reach its maximum CPU capacity!
  - Check the workloads running on it to see which applications are consuming the most CPU.
  - Check if your cluster scaler has already kicked in and provisioning an additional node.
  EOT

  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT rate(filter(sum(node_cpu_seconds), WHERE mode != 'idle'), 1 SECONDS)/uniqueCount(cpu)*100 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter' FACET k8s.node.name"
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
resource "newrelic_nrql_alert_condition" "node_cpu_utilization_low" {
  account_id = var.NEW_RELIC_ACCOUNT_ID
  policy_id  = newrelic_alert_policy.node.id
  type       = "static"
  name       = "CPU utilization too low"

  description = <<-EOT
  Your node is not benefiting from the CPU capacity it has been given!
  - Check if your node is using its assigned memory properly.
     - If yes, change your VM type. Pick yourself a memory-optimized VM in order not to pay for the unnecessary CPU which you don't use.
     - If not, scale down your VM. Pick yourself a smaller VM to pay only for what you actually use.
  EOT

  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT rate(filter(sum(node_cpu_seconds), WHERE mode != 'idle'), 1 SECONDS)/uniqueCount(cpu)*100 WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter' FACET k8s.node.name"
  }

  critical {
    operator              = "below"
    threshold             = 20
    threshold_duration    = 43200
    threshold_occurrences = "all"
  }
  fill_option        = "none"
  aggregation_window = 300
  aggregation_method = "event_flow"
  aggregation_delay  = 0
}

# Condition - MEM utilization too high
resource "newrelic_nrql_alert_condition" "node_mem_utilization_high" {
  account_id = var.NEW_RELIC_ACCOUNT_ID
  policy_id  = newrelic_alert_policy.node.id
  type       = "static"
  name       = "MEM utilization too high"

  description = <<-EOT
  Your node is about to reach its maximum memory capacity!
  - Check the workloads running on it to see which applications are consuming the most memory.
  - Check if your cluster scaler has already kicked in and provisioning an additional node.
  EOT

  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT (100 * (1 - ((average(node_memory_MemFree_bytes) + average(node_memory_Cached_bytes) + average(node_memory_Buffers_bytes)) / average(node_memory_MemTotal_bytes)))) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter' FACET k8s.node.name"
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
resource "newrelic_nrql_alert_condition" "node_mem_utilization_low" {
  account_id = var.NEW_RELIC_ACCOUNT_ID
  policy_id  = newrelic_alert_policy.node.id
  type       = "static"
  name       = "MEM utilization too low"

  description = <<-EOT
  Your node is not benefiting from the memory capacity it has been given!
  - Check if your node is using its CPU memory properly.
     - If yes, change your VM type. Pick yourself a CPU-optimized VM in order not to pay for the unnecessary memory which you don't use.
     - If not, scale down your VM. Pick yourself a smaller VM to pay only for what you actually use.
  EOT

  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "FROM Metric SELECT (100 * (1 - ((average(node_memory_MemFree_bytes) + average(node_memory_Cached_bytes) + average(node_memory_Buffers_bytes)) / average(node_memory_MemTotal_bytes)))) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter' FACET k8s.node.name"
  }

  critical {
    operator              = "below"
    threshold             = 40
    threshold_duration    = 43200
    threshold_occurrences = "all"
  }
  fill_option        = "none"
  aggregation_window = 300
  aggregation_method = "event_flow"
  aggregation_delay  = 0
}

# Condition - STO utilization too high
resource "newrelic_nrql_alert_condition" "node_sto_utilization_high" {
  account_id = var.NEW_RELIC_ACCOUNT_ID
  policy_id  = newrelic_alert_policy.node.id
  type       = "static"
  name       = "STO utilization too high"

  description = <<-EOT
  Your node is about to reach its maximum storage capacity!
  - Check the workloads running on it to see which applications are consuming the most storage.
  - Check if you can extend the underlying storage.
  EOT

  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "SELECT (1 - (average(node_filesystem_avail_bytes) / average(node_filesystem_size_bytes))) * 100 FROM Metric WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter' FACET k8s.node.name"
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

# Condition - STO utilization too low
resource "newrelic_nrql_alert_condition" "node_sto_utilization_low" {
  account_id = var.NEW_RELIC_ACCOUNT_ID
  policy_id  = newrelic_alert_policy.node.id
  type       = "static"
  name       = "STO utilization too low"

  description = <<-EOT
  Your node is not benefiting from the storage capacity it has been given!
  - Check what sort of IOPS your node is using on the disk and pick yourself a smaller disk.
  EOT

  enabled                      = true
  violation_time_limit_seconds = 86400

  nrql {
    query = "SELECT (1 - (average(node_filesystem_avail_bytes) / average(node_filesystem_size_bytes))) * 100 FROM Metric WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = '${var.cluster_name}' AND service.name = 'kubernetes-node-exporter' FACET k8s.node.name"
  }

  critical {
    operator              = "below"
    threshold             = 40
    threshold_duration    = 43200
    threshold_occurrences = "all"
  }
  fill_option        = "none"
  aggregation_window = 300
  aggregation_method = "event_flow"
  aggregation_delay  = 0
}

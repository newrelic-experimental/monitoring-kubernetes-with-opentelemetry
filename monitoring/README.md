# Monitoring

There is a pre-built [monitoring](#new-relic-resources) for you which you can deploy to your New Relic account per Terraform. But before, it is important to understand how the necessary telemetry data is collected! A detailed explanation of how this solution accomplishes that can be found [here](/monitoring/docs//understanding_prometheus_metrics.md).

Moreover, the solution also provides you with a cost analysis! You can know how much money your individual workloads are costing and how much money you are losing due not utilizing your resources well out-of-the-box! Go check out the [documentation](/monitoring/docs/understanding_cost_analysis.md)!

Regarding to the explanation in the documentation above, the corresponding dashboards and alerts are implemented into a Terraform deployment. In order to deploy that, please refer to this [documentation](/monitoring/docs/terraform_deployment.md).

## New Relic resources

The `Terraform` deployment will create the following New Relic resources for you:

- [Dashboards](#dashboards)
- [Alerts](#alerts)

### Dashboards

[**Cluster Overview - Nodes**](/monitoring/terraform/04_dashboard_cluster_overview.tf)

- Node capacities
- Node to pod mapping
- Namespaces & pods per node
- CPU, MEM & STO usage/utilization per node

![Cluster Overview - Nodes](/monitoring/docs/media/cluster_overview_nodes.png)

[**Cluster Overview - Namespaces**](/monitoring/terraform/04_dashboard_cluster_overview.tf)

- Deployments, statefulsets & daemonsets
- Pods with running, pending, failed & unknown statuses
- Namespaces & pods per node
- CPU & MEM usage/utilization per namespace

![Cluster Overview - Namespaces](/monitoring/docs/media/cluster_overview_namespaces.png)

[**Cluster Overview - Pods**](/monitoring/terraform/04_dashboard_cluster_overview.tf)

- Containers & their statuses
- Pods with running, pending, failed & unknown statuses
- CPU & MEM usage/utilization per pod/container
- Filesystem read/write per pod/container
- Network receive/transmit per pod/container

![Cluster Overview - Pods](/monitoring/docs/media/cluster_overview_pods.png)

[**OTel Collectors Overview**](/monitoring/terraform/04_dashboard_otel_collector.tf)

- Collector node capacities & statuses
- Pods with running, pending, failed & unknown statuses
- CPU & MEM usage/utilization per collector instance
- Ratio of queue size to capacity per collector instance
- Dropped telemetry data per collector instance
- Failed receive/enqueue/export per collector instance

![OTel Collectors Overview 1](/monitoring/docs/media/otel_collector_overview_1.png)
![OTel Collectors Overview 2](/monitoring/docs/media/otel_collector_overview_2.png)

[**Kube API Server Overview**](/monitoring/terraform/04_dashboard_kube_apiserver.tf)

- Collector node capacities & statuses
- Pods with running, pending, failed & unknown statuses
- CPU & MEM usage/utilization
- Response latency
- Throughput per status & request type
- Workqueue

![Kube API Server Overview](/monitoring/docs/media/kube_api_server_overview.png)

[**Core DNS Overview**](/monitoring/terraform/04_dashboard_core_dns.tf)

- Collector node capacities & statuses
- Pods with running, pending, failed & unknown statuses
- CPU & MEM usage/utilization
- Response latency
- Throughput per IP type & rcode
- Rate of panics & cache hits

![Core DNS Overview](/monitoring/docs/media/coredns_overview.png)

[**Data Ingest Overview**](/monitoring/terraform/04_dashboard_data_ingest.tf)

- Ingest per telemetry type
- Ingest of Prometheus scraping
  - per jobs
  - per collector types

![Data Ingest Overview 1](/monitoring/docs/media/data_ingest_overview_1.png)
![Data Ingest Overview 2](/monitoring/docs/media/data_ingest_overview_2.png)

[**Cost Analysis - Nodes**](/monitoring/terraform/04_dashboard_cost_analysis.tf)

- Node capacities
- Node costs
- Lost money of nodes due to not utilizing them to the fullest

![Cost Analysis - Nodes](/monitoring/docs/media/cost_analysis_nodes.png)

[**Cost Analysis - Namespaces**](/monitoring/terraform/04_dashboard_cost_analysis.tf)

- Namespace costs
- Lost money of namespaces due to not utilizing them to the fullest

![Cost Analysis - Namespaces 1](/monitoring/docs/media/cost_analysis_namespaces_1.png)
![Cost Analysis - Namespaces 2](/monitoring/docs/media/cost_analysis_namespaces_2.png)

[**Cost Analysis - Pods**](/monitoring/terraform/04_dashboard_cost_analysis.tf)

- Pod costs
- Lost money of pods due to not utilizing them to the fullest

![Cost Analysis - Pods 1](/monitoring/docs/media/cost_analysis_pods_1.png)
![Cost Analysis - Pods 2](/monitoring/docs/media/cost_analysis_pods_2.png)

### Alerts

The alerts have predefined threshold. If those are not applicable for your use-cases, feel free to adapt them accordingly!

[**Nodes**](/monitoring/terraform/05_alert_node.tf)

- Status per instance remains not healthy for a certain amount of time
- CPU utilization per instance exceeding a certain limit for a certain amount of time
- Memory utilization per instance exceeding a certain limit for a certain amount of time
- Storage utilization per instance exceeding a certain limit for a certain amount of time

[**Pods**](/monitoring/terraform/05_alert_pod.tf)

- Status per instance remains not healthy for a certain amount of time
- CPU utilization per instance exceeding a certain limit for a certain amount of time
- Memory utilization per instance exceeding a certain limit for a certain amount of time

[**OTel Collector**](/monitoring/terraform/05_alert_otel_collector.tf)

- CPU utilization per instance exceeding a certain limit for a certain amount of time
- Memory utilization per instance exceeding a certain limit for a certain amount of time
- Queue utilization per instance exceeding a certain limit for a certain amount of time
- Dropped metrics/spans/logs per instance at least once
- Enqueue failures metrics/spans/logs per instance at least once
- Receive failures metrics/spans/logs per instance at least once
- Export failures metrics/spans/logs per instance at least once

# Understanding Prometheus metrics

Prometheus scrapers within the collectors are configured in a particular manner for us to specifically identify where the metrics are coming from and for what they are standing for. It will also makes our life easy when it comes to querying the necessary telemetry data because it is tagged with unique descriptors.

## General

- Every single scrape job below will end up becoming a `service.name` attribute attached to the corresponding metrics.

- The `attibutes` processor adds the cluster name (`k8s.cluster.name`) to every collected metric for identification of their corresponding clusters.

- The `k8sattributes` processor adds Kubernetes metadata (`k8s.node.name`, `k8s.namespace.name`, `k8s.pod.name`) to every telemetry data which implies where they are collected from.

## Self metrics (job: `otelcollector`)

Every collector exposes, scrapes and forwards its own metrics. This is crucial since once we lose the collectors, we lose the entire cluster visibility. So we have to monitor what's monitoring the cluster.

The metrics themselves alone is not enough though. They do not have the necessary information of from which exact collector they are coming from. Therefore, they are being enriched as follows:

- The `attibutes/self` processor adds the pod specific metadata and the collector type:
  - `otelcollector.type` is important to distinguish the various deployment types of the collectors which helps us analyse them according to their purposes.
  - `k8s.node.name`, `k8s.namespace.name`, `k8s.pod.name` are gathered from the environment variables injected into the collector containers to identify which metrics are coming from which exact collector instance.

## API server (job: `kubernetes-apiservers`)

It is crucial to monitor the Kube API server since it is the heart of the entire communication of our clusters. In order for us to be able to easily query its metrics, it has its own scrape job which can be used as follows:

```
FROM Metric SELECT rate(sum(apiserver_request), 1 minute) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = 'my-dope-cluster' AND service.name = 'kubernetes-apiservers' TIMESERIES AUTO
```

`k8s.cluster.name` ensures that we are querying the correct cluster and `service.name` ensures that we are referring to the telemetry data which is collected by the `kubernetes-apiservers` scrape job.

Important metrics:

- apiserver_request_duration_seconds...
- apiserver_request_total
- workqueue_adds_total
- workqueue_depth
- apiserver_current_inflight_requests
- apiserver_dropped_requests_total

## Nodes (job: `kubernetes-nodes`)

This job is scraping the `/api/v1/nodes/__metrics_path__/proxy/metrics` endpoint on each node and lets us know what pods & containers are running on them per the metric `kubelet_container_log_filesystem_used_bytes`. On top that, the `k8sattributes` processor adds `k8s.node.name` to every metric.

This allows us to query on which node each pod is running:

```
FROM Metric SELECT uniques(concat(k8s.node.name, ' -> ', pod)) AS `Node -> Pod` WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = 'my-dope-cluster' AND service.name = 'kubernetes-nodes' AND pod IS NOT NULL
```

`k8s.cluster.name` ensures that we are querying the correct cluster. Since, the attributes `container` and `pod` are also used in other metrics gathered by other scrape jobs, `service.name` guarantees that we are getting them from the `kubernetes-nodes` job.

## Nodes cAdvisor (job: `kubernetes-nodes-cadvisor`)

This job is scraping the `/api/v1/nodes/__metrics_path__/proxy/metrics/cadvisor` endpoint on each node and provides with extremely important container metrics. On top that, the `k8sattributes` processor adds `k8s.node.name` to every metric so that we can specify not only from which container they are coming from but also from which node.

This allows us to query on which node each pod is running:

```
FROM Metric SELECT uniques(concat(k8s.node.name,' | ', pod)) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = 'my-dope-cluster' AND service.name = 'kubernetes-nodes-cadvisor'
```

We can also query the CPU usage of all containers within each pod:

```
FROM Metric SELECT rate(sum(container_cpu_usage_seconds), 1 second) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = 'my-dope-cluster' AND service.name = 'kubernetes-nodes-cadvisor' AND container IS NOT NULL AND pod IS NOT NULL FACET pod, container TIMESERIES AUTO
```

`k8s.cluster.name` ensures that we are querying the correct cluster. Since, the attributes `container` and `pod` are also used in other metrics gathered by other scrape jobs, `service.name` guarantees that we are getting them from the `kubernetes-nodes-cadvisor` job.

Important metrics:

- container_cpu_usage_seconds_total
- container_memory_usage_bytes
- container_fs_reads_total
- container_fs_writes_total
- container_network_receive_bytes_total
- container_network_transmit_bytes_total

## Core DNS (job: `kubernetes-coredns`)

This job is scraping explicitly the Kubernetes service name `kube-dns` which corresponds to the service of the core DNS.

We can query the latency as follows:

```
FROM Metric SELECT histogram(coredns_dns_request_duration_seconds) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = 'my-dope-cluster' AND service.name = 'kubernetes-coredns'
```

`k8s.cluster.name` ensures that we are querying the correct cluster and `service.name` ensures that we are referring to the telemetry data which is collected by the `kubernetes-coredns` scrape job.

Important metrics:

- coredns_dns_request_duration_seconds
- coredns_dns_requests_total
- coredns_dns_responses_total
- coredns_panics_total
- coredns_cache_hits_total

## Node exporter (job: `kubernetes-node-exporter`)

This job is scraping explicitly the node exporter services. It is possible deploy the node-exporter with the helm chart or if you already have one in your cluster, you can reference its service name. On top that, the `k8sattributes` processor adds `k8s.node.name` to every metric.

We can query the capacities of each node:

```
FROM Metric SELECT uniqueCount(cpu) AS 'CPU (cores)', max(node_memory_MemTotal_bytes)/1000/1000/1000 AS 'MEM (GB)' WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = 'my-dope-cluster' AND service.name = 'kubernetes-node-exporter' AND k8s.node.name IN ({{nodes}}) FACET k8s.node.name
```

Or also the available filesystem:

```
SELECT average(node_filesystem_avail_bytes) FROM Metric WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = 'my-dope-cluster' AND service.name = 'kubernetes-node-exporter' FACET k8s.node.name TIMESERIES AUTO
```

`k8s.cluster.name` ensures that we are querying the correct cluster and `service.name` guarantees that we are getting them from the `kubernetes-node-exporter` job. Moreover, `k8s.node.name` indicates which node we are talking about.

Important metrics

- node_cpu_seconds_total
- node_memory_MemTotal_bytes
- node_memory_MemFree_bytes
- node_memory_Cached_bytes
- node_memory_Buffers_bytes
- node_filesystem_avail_bytes
- node_filesystem_size_bytes

## Kube state metrics (job: `kubernetes-kube-state-metrics`)

This job is scraping explicitly the kube-state-metrics services. It is possible deploy the kube-state-metrics with the helm chart or if you already have one in your cluster, you can reference its service name. On top that, the `k8sattributes` processor adds `k8s.node.name` to every metric to indicate which kube-state-metrics pod on which node is scraping those metrics.

We can query the memory limits assigned on each container within each pod:

```
FROM Metric SELECT filter(max(kube_pod_container_resource_limits), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = 'my-dope-cluster' AND service.name = 'kubernetes-kube-state-metrics' AND resource = 'memory') WHERE container IS NOT NULL AND pod IS NOT NULL FACET pod, container TIMESERIES AUTO
```

`k8s.cluster.name` ensures that we are querying the correct cluster. Since, the attributes `container` and `pod` are also used in other metrics gathered by other scrape jobs, `service.name` guarantees that we are getting them from the `kubernetes-kube-state-metrics` job.

**BEWARE:**
Because of `k8sattributes` processor, the metrics coming from this job are enriched with `k8s.container.name` and `k8s.pod.name` whereas the scraped metrics also contain `container` and `pod` attributes.

- `k8s.container.name` and `k8s.pod.name` stand for the kube-state-metrics instances
- `container` and `pod` stand for the scraped instances by kube-state-metrics instances

So for example, if you would like to query the cpu requests of the container `my-container` within the pod `my-pod`, you would need write query as follows:

```
FROM Metric SELECT filter(max(kube_pod_container_resource_limits), WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = 'my-dope-cluster' AND service.name = 'kubernetes-kube-state-metrics' AND resource = 'cpu') WHERE container = 'my-container' AND pod = 'my-pod'
```

not with `k8s.container.name` and `k8s.pod.name`!

## Service endpoints (job: `kubernetes-service-endpoints`)

This job is scraping all of Kubernetes service endpoints that are annotated except node-exporter, kube-state-metrics and core DNS since they are already being scraped by their dedicated jobs. On top that, the `k8sattributes` processor adds `k8s.node.name`, `k8s.namespace.name`, `k8s.pod.name` and `k8s.container.name` attributes to every metric that are retrieved from the corresponding services of the pods.

We can query a custom metric that an application exposes within the `my-namespace` namespace per each pod:

```
FROM Metric SELECT max(somceCustomMetric) WHERE instrumentation.provider = 'opentelemetry' AND k8s.cluster.name = 'my-dope-cluster' AND service.name = 'kubernetes-service-endpoints' AND k8s.namespace.name = 'my-namespace' FACET k8s.pod.name
```

`k8s.cluster.name` ensures that we are querying the correct cluster and `service.name` guarantees that we are getting them from the `kubernetes-service-endpoints` job. `k8s.namespace.name` and `k8s.pod.name` specifies precisely from which instance of that application the metrics are coming from.

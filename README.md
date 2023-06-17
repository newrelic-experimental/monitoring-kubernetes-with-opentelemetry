<a href="https://opensource.newrelic.com/oss-category/#new-relic-experimental"><picture><source media="(prefers-color-scheme: dark)" srcset="https://github.com/newrelic/opensource-website/raw/main/src/images/categories/dark/Experimental.png"><source media="(prefers-color-scheme: light)" srcset="https://github.com/newrelic/opensource-website/raw/main/src/images/categories/Experimental.png"><img alt="New Relic Open Source experimental project banner." src="https://github.com/newrelic/opensource-website/raw/main/src/images/categories/Experimental.png"></picture></a>

# Monitoring Kubernetes with Open Telemetry

This repository is dedicated to provide a quick start to monitor you Kubernetes cluster. It is designed to be as scalable as possible with the further functionality of exporting necessary telemetry data to multiple New Relic accounts. If want to know where the repo is headed, check out the [roadmap](https://github.com/orgs/newrelic-experimental/projects/12/views/1)!

The collection of telemetry data (`logs`, `traces` and `metrics`) is achieved per Open Telemetry collectors configured and deployed as following Kubernetes resources:

- Daemonset
- Deployment
- Statefulset

## Prerequisites

The Helm chart uses Open Telemetry collector Custom Resource Definition (CRD) which requires the [Open Telemetry operator](https://github.com/open-telemetry/opentelemetry-operator) to be deployed. In order to deploy the operator refer to this [Helm chart](https://github.com/open-telemetry/opentelemetry-helm-charts/tree/main/charts/opentelemetry-operator) or simply use the [`00_deploy_operator.sh`](./helm/scripts/00_deploy_operator.sh).

## Purpose of various collectors

### Daemonset

The daemonset is primarily used to gather the logs of the applications. It uses the `filelogreceiver` to _tail_ the logs from the nodes (`var/log/pods/...`). Each collector instance is responsible for the collection and forwarding of the logs to corresponding New Relic accounts on its own node where they are running. [`Daemonset collector config`](./helm/charts/collectors/templates/daemonset-otelcollector.yaml) can be adapted in order to filter or enrich the logs.

### Deployment

The deployment is primarily used to gather the application traces & metrics per the `otlprecevier` and consists of 2 separate deployments as `recevier` and `sampler`.

The `receiver` collector is responsible of collecting the traces and metrics where

- the metrics are enriched (& filtered if necessary) and will be directly exported to the corresponding New Relic accounts.
- the traces, on the other hand, are enriched as well but will be exported to the `sampler` collector.

The reason for this is that the traces are mostly to be sampled and sampling works properly only when all the spans of a trace are processed by one collector instance. Therefore, the `loadbalancingexporter` is used to send all spans of a trace to one `sampler` collector instance. After sampling, the `sampler` collector will flush all the spans to necessary New Relic accounts. Please see official Open Telemetry [docs](https://opentelemetry.io/docs/collector/scaling/#scaling-stateful-collectors) for more!

### Statefulset

The statefulset is primarily used to scrape the metrics throughout the cluster. It uses the `prometheusreceiver` to fetch metrics per various Kubernetes service discovery possibilities (`services`, `nodes`, `cadvisor`...).

In order to be able able to scale it out, the [Target Allocator](https://github.com/open-telemetry/opentelemetry-operator#target-allocator) is used which distributes the to be scraped endpoints that are discovered by the Kubernetes service discovery as evenly as possible across the instances of the statefulsets so that each endpoint is scraped only once by one collector instance at a time. Thereby, the requirement to maintain a central Prometheus server with huge memory needs can be replaced by multiple smaller instances of collector scrapers. Please refer to the official Open Telemetry [docs](https://opentelemetry.io/docs/collector/scaling/#scaling-the-scrapers) for more!

## Multi-account export

A highly demanded use-case is to be able to:

- gather data from all possible objects
- filter them according to various requirements
- send them to multiple New Relic accounts

A typical example can be given as an organization with an ops team and multiple dev teams where

- the ops team is responsible for the health of the cluster and the commonly running applications on it (Nginx, Kafka, service mesh...)
- the dev team is responsible for their own applications which are mostly running in a dedicated namespace

Since the monitoring tools are mostly deployed by the ops team, the collected telemetry data tends to end up being forwarded only to their New Relic account and the dev teams are supposed to deploy the same tools to their namespaces in order to have the necessary data forwarded to their New Relic accounts.

**An example** complication with this methodology would be to distribute the container metrics that are exposed by the `cadvisor` which is not running per namespace but per node and requires cluster-wide RBAC rights to be accessed. Mostly, these rights are not preferred to be given to individual dev teams which makes the situation even more complicated for the dev teams to obtain the container metrics of their own applications.

### Solution

Every collector is configured to accept multiple filtering & exporting possibilities (see [`values.yaml`](./helm/charts/collectors/values.yaml)):

- `1` ops team
- `x` dev teams

If you were to have 1 ops team & 2 dev teams and would like to send the telemetry data

- from the entire cluster to ops team
- from the individual namespaces to corresponding dev teams

you can use the following configuration for daemonset, deployment and statefulset:

```yaml
statefulset: # also deployment or daemonset
  newrelic:
    teams:
      opsteam:
        endpoint: "OTLP_ENDPOINT_OPS_TEAM"
        licenseKey:
          value: "LICENSE_KEY_OPS_TEAM"
        namespaces: []
      devteam1:
        endpoint: "OTLP_ENDPOINT_DEV_TEAM_1"
        licenseKey:
          value: "LICENSE_KEY_DEV_TEAM_1"
        namespaces:
          - namespace-devteam-1
      devteam2:
        endpoint: "OTLP_ENDPOINT_DEV_TEAM_2"
        licenseKey:
          value: "LICENSE_KEY_DEV_TEAM_2"
        namespaces:
          - namespace-devteam-2
```

Since all of the telemetry data is centrally collected by 3 variations of collectors, each variation can filter the data according to the namespaces where the data is coming from. So centrally gathered data will be

- filtered by multiple processors depending on the config above
- routed to corresponding exporters and thereby to corresponding New Relic accounts

The configuration above is the default way of setting up individual accounts to export the telemetry data.

If,

- all of your New Relic accounts are in the same New Relic datacenter (US or EU)
- the individual teams are to be given only the telemetry data which belong to their namespaces

you can simplify the deployment per the global configuration as follows:

```yaml
global:
  newrelic:
    enabled: true
    endpoint: "OTLP_ENDPOINT_FOR_ALL_ACCOUNTS"
    teams:
      opsteam:
        licenseKey:
          value: "LICENSE_KEY_OPS_TEAM"
        namespaces: []
      devteam1:
        licenseKey:
          value: "LICENSE_KEY_DEV_TEAM_1"
        namespaces:
          - namespace-devteam-1
      devteam2:
        licenseKey:
          value: "LICENSE_KEY_DEV_TEAM_2"
        namespaces:
          - namespace-devteam-2
```

How to set up the license keys properly is explained [here](#setting-up-license-keys).

## Deploy!

Feel free to customize the [Kubernetes manifest files](./helm/charts/collectors/templates/)! You can simply add your OTLP endpoints and license keys according to your New Relic accounts and run the [`01_deploy_collectors.sh`](./helm/scripts/01_deploy_collectors.sh).

The script deploys `node-exporter` and `kube-state-metrics` with the OTel collectors which are **REQUIRED** for a complete monitoring (see [Monitoring](#monitoring) section below).

Moreover, you will need to define a cluster name:

```shell
# cluster name
clusterName="my-dope-cluster"

...

# otelcollector
helm upgrade ${otelcollectors[name]} \
  ...
  --set clusterName=$clusterName \
  ...
  "../charts/collectors"
```

The cluster name that you define will be added as an additional attribute `k8s.cluster.name` to all of telemetry data which are collected by the collectors so that later, you can filter them out according to your various clusters.

### Setting up OTLP endpoints & license keys

If the New Relic account where you want to send the data to is

- in US, use `otlp.nr-data.net:4317`
- in EU, use `otlp.eu01.nr-data.net:4317`

In the [`01_deploy_collectors.sh`](./helm/scripts/01_deploy_collectors.sh), the default value is set for EU as follows:

````shell
newrelicOtlpEndpoint="otlp.eu01.nr-data.net:4317"

```shell
helm upgrade ... \
...
--set daemonset.newrelic.teams.opsteam.endpoint=$newrelicOtlpEndpoint \
...
````

When it comes to defining the New Relic license keys, you have 2 ways:

**Reference an existing secret**

If you already have put your secrets into a Kubernetes secret within the same namespace as this Helm deployment's, you can reference that as follows:

1. Define in `values.yaml`

```yaml
newrelic:
  teams:
    opsteam:
      endpoint: "<NEW_RELIC_OTLP_ENDPOINT>"
      licenseKey:
        secretRef:
          name: "<YOUR_EXISTING_SECRET>"
          key: "<KEY_TO_LICENSE_KEY_WITHIN_THE_SECRET>"
```

2. Set per `helm --set`

```shell
helm upgrade ... \
...
--set statefulset.newrelic.teams.opsteam.endpoint="<NEW_RELIC_OTLP_ENDPOINT>" \
--set statefulset.newrelic.teams.opsteam.licenseKey.secretRef.name="<YOUR_EXISTING_SECRET>" \
--set statefulset.newrelic.teams.opsteam.licenseKey.secretRef.key="<KEY_TO_LICENSE_KEY_WITHIN_THE_SECRET>" \
...
```

**Create a new secret**

If you haven't defined any secret for your license key and want to create it from scratch, you can

1. Define in `values.yaml`

```yaml
newrelic:
  teams:
    opsteam:
      endpoint: "<NEW_RELIC_OTLP_ENDPOINT>"
      licenseKey:
        value: "<YOUR_EXISTING_SECRET>"
```

2. Set per `helm --set`

```shell
helm upgrade ... \
...
--set statefulset.newrelic.teams.opsteam.endpoint="<NEW_RELIC_OTLP_ENDPOINT>" \
--set statefulset.newrelic.teams.opsteam.licenseKey.value="<NEW_RELIC_LICENSE_KEY>" \
...
```

### Set service names for `node-exporter` & `kube-state-metrics`

The `statefulset` collectors are designed to scrape `node-exporter` and `kube-state-metrics` decoupled from the rest of the service endpoints. Therefore, they need to know their service names. If you already have these in your cluster, you can simply refer to their service names:

1. Define in `values.yaml`

```yaml
prometheus:
  nodeExporter:
    enabled: false
    serviceNameRef: <NODE_EXPORTER_SVC_NAME>
  kubeStateMetrics:
    enabled: false
    serviceNameRef: <KUBE_STATE_METRICS_SVC_NAME>
```

2. Set per `helm --set`

```shell
helm upgrade ... \
...
  --set statefulset.prometheus.nodeExporter.enabled=false \
  --set statefulset.prometheus.nodeExporter.serviceNameRef=<NODE_EXPORTER_SVC_NAME> \
  --set statefulset.prometheus.kubeStateMetrics.enabled=false \
  --set statefulset.prometheus.kubeStateMetrics.serviceNameRef=<KUBE_STATE_METRICS_SVC_NAME> \
...
```

If you don't have `node-exporter` and `kube-state-metrics` in your cluster, you can do the following:

1. Define in `values.yaml`

```yaml
prometheus:
  nodeExporter:
    enabled: true
  kubeStateMetrics:
    enabled: true
```

2. Set per `helm --set`

```shell
helm upgrade ... \
...
  --set statefulset.prometheus.nodeExporter.enabled=true \
  --set statefulset.prometheus.kubeStateMetrics.enabled=true \
...
```

where the default values already enable both of them. You can find the helm dependencies of them [here](/helm/charts/collectors/Chart.yaml).

Moreover, the script [`01_deploy_collectors.sh`](./helm/scripts/01_deploy_collectors.sh) already has both implementations for you.

- If you run it without specifying anything, it will deploy the `node-exporter` and `kube-state-metrics` along with the collectors.
- if you run it with the flag `--external`, it will first deploy the `node-exporter` and `kube-state-metrics` separately and then deploy the collectors by assigning their service names.

### Data ingest control

Have full control over your data! Drop whatever you don't need. The Helm chart might cause a significant amount of data ingest when it is deployed with default values. The deployment with values is recommended for the start of the journey (and for troubleshooting) so that you familiarize yourself with all of the metrics and their labels. After you decide which metrics are crucial for you, simply drop the rest.

The Helm chart is already built with 2 flags for this purpose:

- `lowDataMode`: It increases the scrape duration for Prometheus collector instances so that the fetched data is ingested less frequently.
- `importantMetricsOnly`: It only keeps and forwards the required metrics which are used in the [dashboards](./monitoring/terraform/).

These flags are to be defined per each collecter type: `statefulset`, `deployment`, `daemonset`.

1. Define in `values.yaml`

```yaml
prometheus:
  lowDataMode: true
  importantMetricsOnly: true
```

2. Set per `helm --set`

```shell
helm upgrade ... \
...
  --set statefulset.prometheus.lowDataMode=true \
  --set statefulset.prometheus.importantMetricsOnly=true \
...
```

Along with the [Terraform deployment](./monitoring/), a [data ingest](./monitoring/terraform/04_dashboard_data_ingest.tf) dashboard is created for you to keep track of which services is causing how much data ingest.

## Monitoring

Check out the [`README`](./monitoring/README.md)! An example [monitoring](/monitoring) is already prepared for you which explains how the scraping works, what to be careful about and what New Relic resources are deployed into your account.

For that, you can easily run the [`00_create_newrelic_resources.sh`](/monitoring/scripts/00_create_newrelic_resources.sh) script.

## Maintainers

- [Ugur Turkarslan](https://github.com/utr1903)

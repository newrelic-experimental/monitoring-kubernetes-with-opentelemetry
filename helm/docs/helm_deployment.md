# Helm deployment

The Helm chart is being hosted as a remote chart for you. If you wouldn't like to clone the repo, simply deploy the chart as follows.

1. you can run add the repo:

```shell
helm repo add newrelic-experimental https://newrelic-experimental.github.io/monitoring-kubernetes-with-opentelemetry/charts

helm repo update newrelic-experimental
```

2. and then install it with necessary flags:

```shell
helm upgrade nrotelk8s \
  --install \
  ...
  "newrelic-experimental/nrotelk8s"
```

On the other hand, if you would like to customize the [Kubernetes manifest files](./helm/charts/collectors/templates/), of course feel free to clone the repo and create your own Helm chart locally.

## Configuration

All the necessary parameters are to be found under the [`values.yaml`](/helm/charts/collectors/values.yaml) file. Morever, you can refer to the [README](/helm/scripts/README.md) and use the [`01_deploy_collectors.sh`](./helm/scripts/01_deploy_collectors.sh) script to bootstrap the Helm installation.

The script deploys `node-exporter` and `kube-state-metrics` with the OTel collectors which are **REQUIRED** for a complete monitoring (see [Monitoring](/monitoring/README.md) section).

### Cluster name

You **HAVE TO** name your cluster on which you are deploying the Helm chart. This cluster name will be added as an additional attribute `k8s.cluster.name` to all of telemetry data which are collected by the collectors so that later, you can figure out which data is coming from which cluster.

```shell
helm upgrade nrotelk8s \
  --install \
  ...
  --set clusterName="<YOUR_CLUSTER_NAME>" \
  ...
  "newrelic-experimental/nrotelk8s"
```

### Setting up OTLP endpoints & license keys

If the New Relic account where you want to send the data to is

- in US, use `otlp.nr-data.net:4317`
- in EU, use `otlp.eu01.nr-data.net:4317`

There 2 ways: global & individual.

#### Global

This is the default way. If all of your New Relic accounts to which you are willing to send various telemetry data are in the same New Relic datacenter (US or EU), you can simply use the global configuration:

```shell
helm upgrade nrotelk8s \
  --install \
  ...
  # global
  --set global.newrelic.enabled=true \ # default
  --set global.newrelic.endpoint=<NEW_RELIC_OTLP_ENDPOINT> \

  # opsteam
  --set global.newrelic.teams.opsteam.licenseKey.value=<NEW_RELIC_LICENSE_KEY_OPSTEAM> \

  # devteamx
  --set global.newrelic.teams.devteamx.licenseKey.value=<NEW_RELIC_LICENSE_KEY_DEVTEAMX> \
  ...
  "newrelic-experimental/nrotelk8s"
```

#### Individual

If your New Relic accounts to which you are willing to send various telemetry data are scattered across multiple New Relic datacenters (US or EU), you can then use the individual configuration to define each one of them granularly.

```shell
helm upgrade nrotelk8s \
  --install \
  ...
  --set global.newrelic.enabled=false \

  ## deployment
  # opsteam
  --set deployment.newrelic.teams.opsteam.endpoint=<NEW_RELIC_OTLP_ENDPOINT_OPSTEAM> \
  --set deployment.newrelic.teams.opsteam.licenseKey.value=<NEW_RELIC_LICENSE_KEY_OPSTEAM> \
  # devteamx
  --set deployment.newrelic.teams.devteamx.endpoint=<NEW_RELIC_OTLP_ENDPOINT_DEVTEAMX> \
  --set deployment.newrelic.teams.devteamx.licenseKey.value=<NEW_RELIC_LICENSE_KEY_DEVTEAMX> \

  ## daemonset
  # opsteam
  --set daemonset.newrelic.teams.opsteam.endpoint=<NEW_RELIC_OTLP_ENDPOINT_OPSTEAM> \
  --set daemonset.newrelic.teams.opsteam.licenseKey.value=<NEW_RELIC_LICENSE_KEY_OPSTEAM> \
  # devteamx
  --set daemonset.newrelic.teams.devteamx.endpoint=<NEW_RELIC_OTLP_ENDPOINT_DEVTEAMX> \
  --set daemonset.newrelic.teams.devteamx.licenseKey.value=<NEW_RELIC_LICENSE_KEY_DEVTEAMX> \

  ## statefulset
  # opsteam
  --set statefulset.newrelic.teams.opsteam.endpoint=<NEW_RELIC_OTLP_ENDPOINT_OPSTEAM> \
  --set statefulset.newrelic.teams.opsteam.licenseKey.value=<NEW_RELIC_LICENSE_KEY_OPSTEAM> \
  # devteamx
  --set statefulset.newrelic.teams.devteamx.endpoint=<NEW_RELIC_OTLP_ENDPOINT_DEVTEAMX> \
  --set statefulset.newrelic.teams.devteamx.licenseKey.value=<NEW_RELIC_LICENSE_KEY_DEVTEAMX> \
  ...
  "newrelic-experimental/nrotelk8s"
```

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
        value: "<NEW_RELIC_LICENSE_KEY>"
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
- `importantMetricsOnly`: It only keeps and forwards the required metrics which are used in the [dashboards](/monitoring/terraform/).

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

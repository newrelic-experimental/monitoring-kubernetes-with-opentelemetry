# Purpose of various collectors

The collection of telemetry data (`logs`, `traces` and `metrics`) is achieved per Open Telemetry collectors configured and deployed as following Kubernetes resources:

- Daemonset
- Deployment
- Statefulset

## Daemonset

The daemonset is primarily used to gather the logs of the applications. It uses the `filelogreceiver` to _tail_ the logs from the nodes (`var/log/pods/...`). Each collector instance is responsible for the collection and forwarding of the logs to corresponding New Relic accounts on its own node where they are running. [`Daemonset collector config`](./helm/charts/collectors/templates/daemonset-otelcollector.yaml) can be adapted in order to filter or enrich the logs.

## Deployment

The deployment is primarily used to gather the application traces & metrics per the `otlprecevier` and consists of 2 separate deployments as `recevier` and `sampler`.

The `receiver` collector is responsible of collecting the traces and metrics where

- the metrics are enriched (& filtered if necessary) and will be directly exported to the corresponding New Relic accounts.
- the traces, on the other hand, are enriched as well but will be exported to the `sampler` collector.

The reason for this is that the traces are mostly to be sampled and sampling works properly only when all the spans of a trace are processed by one collector instance. Therefore, the `loadbalancingexporter` is used to send all spans of a trace to one `sampler` collector instance. After sampling, the `sampler` collector will flush all the spans to necessary New Relic accounts. Please see official Open Telemetry [docs](https://opentelemetry.io/docs/collector/scaling/#scaling-stateful-collectors) for more!

## Statefulset

The statefulset is primarily used to scrape the metrics throughout the cluster. It uses the `prometheusreceiver` to fetch metrics per various Kubernetes service discovery possibilities (`services`, `nodes`, `cadvisor`...).

In order to be able able to scale it out, the [Target Allocator](https://github.com/open-telemetry/opentelemetry-operator#target-allocator) is used which distributes the to be scraped endpoints that are discovered by the Kubernetes service discovery as evenly as possible across the instances of the statefulsets so that each endpoint is scraped only once by one collector instance at a time. Thereby, the requirement to maintain a central Prometheus server with huge memory needs can be replaced by multiple smaller instances of collector scrapers. Please refer to the official Open Telemetry [docs](https://opentelemetry.io/docs/collector/scaling/#scaling-the-scrapers) for more!

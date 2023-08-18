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

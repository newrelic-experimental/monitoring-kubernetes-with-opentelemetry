# Tests

## Helm chart inputs

The following tests are implemented to be triggered by the Github workflow on [`validate_helm_input.yaml`](/.github/workflows/validate_helm_input.yml) every pull request in order to check that new commits do not break the expected outcome of the Helm chart.

### Case 01 - Cluster name should be defined

The variable cluster name is mandatory. Every telemetry data is enriched with to be provided cluster name so that one can differentiate from which cluster the corresponding telemetry data is coming.

### Case 02 - At least 1 telemetry type should be enabled

There are 4 different telemetry types for the chart which are primarily having different responsibilities:

| Telemetry | K8s object   |
| --------- | ------------ |
| `traces`  | `deployment` |
| `logs`    | `daemonset`  |
| `metrics` | `statefulet` |
| `events`  | `singleton`  |

At least one of these telemetry types must be enabled.

### Case 03, 04, 05, 06 - New Relic account should be defined

If any telemetry type is enabled, it also has to have a New Relic block defined so that the gathered telemetry data could be sent to a New Relic account.

| K8s object   | Case |
| ------------ | ---- |
| `deployment` | `03` |
| `daemonset`  | `04` |
| `statefulet` | `05` |
| `singleton`  | `06` |

### Case 07, 08, 09, 10 - OTLP endpoint should be valid (global)

If any telemetry type and global config are enabled, the OTLP endpoint of the corresponding New Relic account should be valid where

- US -> `https://otlp.nr-data.net`
- EU -> `https://otlp.eu01.nr-data.net`

| K8s object   | Case |
| ------------ | ---- |
| `deployment` | `07` |
| `daemonset`  | `08` |
| `statefulet` | `09` |
| `singleton`  | `10` |

### Case 11, 12, 13, 14 - OTLP endpoint should be valid (individual)

If any telemetry type is enabled and individual configs are used, the OTLP endpoint of the corresponding New Relic account should be valid where

- US -> `https://otlp.nr-data.net`
- EU -> `https://otlp.eu01.nr-data.net`

| K8s object   | Case |
| ------------ | ---- |
| `deployment` | `11` |
| `daemonset`  | `12` |
| `statefulet` | `13` |
| `singleton`  | `14` |

### Case 15, 16, 17, 18 - License key should be defined (global)

If any telemetry type and global config are enabled, the license key of the corresponding New Relic account should either be defined directly by providing the value to the helm chart or by referencing an existing secret which holds the license key.

| K8s object   | Case |
| ------------ | ---- |
| `deployment` | `15` |
| `daemonset`  | `16` |
| `statefulet` | `17` |
| `singleton`  | `18` |

### Case 19, 20, 21, 22 - License key should be defined (individual)

If any telemetry type is enabled and individual configs are used, the license key of the corresponding New Relic account should either be defined directly by providing the value to the helm chart or by referencing an existing secret which holds the license key.

| K8s object   | Case |
| ------------ | ---- |
| `deployment` | `19` |
| `daemonset`  | `20` |
| `statefulet` | `21` |
| `singleton`  | `22` |

### Case 23, 24, 25, 26 - License key reference should have a name (global)

If the license key of the corresponding New Relic account is defined globally by referencing an existing secret which holds the license key, the name of the secret should be given.

| K8s object   | Case |
| ------------ | ---- |
| `deployment` | `23` |
| `daemonset`  | `24` |
| `statefulet` | `25` |
| `singleton`  | `26` |

### Case 27, 28, 29, 30 - License key reference should have a name (individual)

If the license key of the corresponding New Relic account is defined individually by referencing an existing secret which holds the license key, the name of the secret should be given.

| K8s object   | Case |
| ------------ | ---- |
| `deployment` | `27` |
| `daemonset`  | `28` |
| `statefulet` | `29` |
| `singleton`  | `30` |

### Case 31, 32, 33, 34 - License key reference should have a key (global)

If the license key of the corresponding New Relic account is defined globally by referencing an existing secret which holds the license key, the key in itself that points to the license key should be given.

| K8s object   | Case |
| ------------ | ---- |
| `deployment` | `31` |
| `daemonset`  | `32` |
| `statefulet` | `33` |
| `singleton`  | `34` |

### Case 35, 36, 37, 38 - License key reference should have a key (individual)

If the license key of the corresponding New Relic account is defined individually by referencing an existing secret which holds the license key, the key in itself that points to the license key should be given.

| K8s object   | Case |
| ------------ | ---- |
| `deployment` | `35` |
| `daemonset`  | `36` |
| `statefulet` | `37` |
| `singleton`  | `38` |

## Helm chart outputs

The following tests are implemented to be triggered by the Github workflow on [`validate_helm_output.yaml`](/.github/workflows/validate_helm_output.yml) every pull request in order to check that new commits do not break the expected outcome of the Helm chart.

- There are 2 different cases: `global` & `individual`.
- There are 3 teams defined in total `opsteam`, `devteam1` & `devteam2`
  - where `opsteam` does not have any namespace filter.
  - where `devteam1` has the namespace filter [`devteam1`].
  - where `devteam2` is tagged to be ignored.
- All types of collectors are deployed: `daemonset`, `deployment-receiver`, `deployment-sampler`, `statefulset` & `singleton`.

The expected outcome is as follows:

| Operation                                          | `opsteam` | `devteam1` | `devteam2` |
| -------------------------------------------------- | --------- | ---------- | ---------- |
| Secret creation                                    | ✅        | ✅         | ❌         |
| Collector secret environment variables assignment  | ✅        | ✅         | ❌         |
| Collector filterprocessor configuration            | ❌        | ✅         | ❌         |
| Collector exporter configuration                   | ✅        | ✅         | ❌         |
| Collector pipeline configuration - filterprocessor | ❌        | ✅         | ❌         |
| Collector pipeline configuration - exporter        | ✅        | ✅         | ❌         |

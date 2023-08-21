# Deployment scripts

The scripts represents example Helm deployments which you can use to bootstrap the solution. Feel free to customize the parameters as you wish.

[00_deploy_operator.sh](/helm/scripts/00_deploy_operator.sh) contains an example deployment of the prerequisites which the solution needs:

- cert-manager
- opentelemetry-operator

[01_deploy_collectors.sh](/helm/scripts/01_deploy_collectors.sh) contains example use-cases with which you can understand configuring your Helm inputs. Before running this script, the prerequisite components mentioned above should be running on the cluster.

## Example cases

As mentioned in the Helm deployment [docs](/helm/docs/helm_deployment.md), there are various ways you can deploy the chart. Here is a representative matrix that summarizes what the [01_deploy_collectors.sh](/helm/scripts/01_deploy_collectors.sh) script covers in terms of using

- global configurations (column -> `Global`)
- external node-exporter & kube-state-metrics (column -> `External`)

| Case | Global | External |
| ---- | ------ | -------- |
| `01` | ✅     | ❌       |
| `02` | ❌     | ❌       |
| `03` | ✅     | ✅       |
| `04` | ❌     | ✅       |

Example:
```shell
bash 01_deploy_collectors.sh \
  --cluster-name my-dope-cluster \
  --newrelic-region eu \
  --case 1
```

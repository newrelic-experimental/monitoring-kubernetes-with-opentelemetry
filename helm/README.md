# Solution

## Open Telemetry collectors

Before directly diving into the Helm deployment itself, it is recommended for you to be aware of how this solution works in sense of:

- How are the necessary telemetry data being collected?
- Why am I deploying what?

Therefore, please refer to the [documentation](/helm/docs/purpose_of_various_collectors.md) of purpose of various collectors.

## Helm deployment

Now, you can deploy the solution! Bare in mind that this solution requires `node-exporter` and `kube-state-metrics`.

Moreover, you will be needing to set up your own New Relic credentials in order to send the telemetry data to your own New Relic account. You can refer to this [documentation](/helm/docs/helm_deployment.md) to have detailed understanding of each parameter in the configuration.

## Multi-account export

As it was mentioned in the repository description, multi-account export of the collected telemetry data is a pretty hot topic. This repo aims to satisfy that requirement as well. Please refer to this [documentation](/helm/docs/multi_account_export.md) to learn more!

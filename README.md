<a href="https://opensource.newrelic.com/oss-category/#new-relic-experimental"><picture><source media="(prefers-color-scheme: dark)" srcset="https://github.com/newrelic/opensource-website/raw/main/src/images/categories/dark/Experimental.png"><source media="(prefers-color-scheme: light)" srcset="https://github.com/newrelic/opensource-website/raw/main/src/images/categories/Experimental.png"><img alt="New Relic Open Source experimental project banner." src="https://github.com/newrelic/opensource-website/raw/main/src/images/categories/Experimental.png"></picture></a>

# Monitoring Kubernetes with Open Telemetry

This repository is dedicated to provide a quick start to monitor you Kubernetes cluster. It is designed to be as scalable as possible with the further functionality of exporting necessary telemetry data to multiple New Relic accounts. If want to know where the repo is headed, check out the [issues](https://github.com/newrelic-experimental/monitoring-kubernetes-with-opentelemetry/issues) and the [roadmap](https://github.com/orgs/newrelic-experimental/projects/12/views/1)!

## Prerequisites

The Helm chart uses Open Telemetry collector Custom Resource Definition (CRD) which requires the [Open Telemetry operator](https://github.com/open-telemetry/opentelemetry-operator) to be deployed. In order to deploy the operator refer to this [Helm chart](https://github.com/open-telemetry/opentelemetry-helm-charts/tree/main/charts/opentelemetry-operator) or simply use the [`00_deploy_operator.sh`](./helm/scripts/00_deploy_operator.sh).

## Getting started

### Understanding the solution

Before directly diving into the Helm deployment itself, it is recommended for you to be aware of how this solution works in sense of:

- How are the necessary telemetry data being collected?
- Why am I deploying what?

Therefore, please refer to the [documentation](/helm/docs/purpose_of_various_collectors.md) of purpose of various collectors.

### Helm deployment

Now, you can deploy the solution! Bare in mind that this solution requires `node-exporter` and `kube-state-metrics`.

Moreover, you will be needing to set up your own New Relic credentials in order to send the telemetry data to your own New Relic account. You can refer to this [documentation](/helm/docs/helm_deployment.md) to have detailed understanding of each parameter in the configuration.

### Multi-account export

As it was mentioned in the repository description, multi-account export of the collected telemetry data is a pretty hot topic. This repo aims to satisfy that requirement as well. Please refer to this [documentation](/helm/docs/multi_account_export.md) to learn more!

### Monitoring

Obviously, sending all the telemetry data to New Relic alone doesn't make any sense. It is crucial to comprehend how the data is collected and what attributes are refering to what exactly. That's why, there is a pre-built monitoring stack is waiting for you [here](./monitoring/README.md) which you can easily deploy per Terraform!

## Support

New Relic has open-sourced this project. This project is provided AS-IS WITHOUT WARRANTY OR DEDICATED SUPPORT. Issues and contributions should be reported to the project here on GitHub.

## Contributing

We encourage your contributions to improve this project! Keep in mind when you submit your pull request, you'll need to sign the CLA via the click-through using CLA-Assistant. You only have to sign the CLA one time per project. If you have any questions, or to execute our corporate CLA, required if your contribution is on behalf of a company, please drop us an email at opensource@newrelic.com.

**A note about vulnerabilities**

As noted in our [security policy](../../security/policy), New Relic is committed to the privacy and security of our customers and their data. We believe that providing coordinated disclosure by security researchers and engaging with the security community are important means to achieve our security goals.

If you believe you have found a security vulnerability in this project or any of New Relic's products or websites, we welcome and greatly appreciate you reporting it to New Relic through [HackerOne](https://hackerone.com/newrelic).

## License

This project is licensed under the [Apache 2.0](http://apache.org/licenses/LICENSE-2.0.txt) License.

## Maintainers

- [Ugur Turkarslan](https://github.com/utr1903)

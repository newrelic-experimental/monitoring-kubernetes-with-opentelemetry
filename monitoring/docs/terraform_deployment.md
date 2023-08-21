# Terraform setup

Now, you know where the necessary metrics are coming from. So you can monitor your cluster instantly per the given Terraform deployment.

## Deploy as a module

The [terraform](/monitoring/terraform/) folder contains all the relevant New Relic resources you need. You can deploy those resources remotely without needing to clone the repo as follows:

### Create a Terraform file

Create or integrate the following Terraform module to deploy the **latest** version of the module:

```
module "<NAME_YOUR_MODULE>" {
  source = "github.com/newrelic-experimental/monitoring-kubernetes-with-opentelemetry.git/monitoring/terraform"

  NEW_RELIC_ACCOUNT_ID = var.NEW_RELIC_ACCOUNT_ID
  NEW_RELIC_API_KEY    = var.NEW_RELIC_API_KEY
  NEW_RELIC_REGION     = var.NEW_RELIC_REGION
  cluster_name         = var.cluster_name
}
```

If you are willing to deploy a **specific** version, do the following:

```
source = "github.com/newrelic-experimental/monitoring-kubernetes-with-opentelemetry.git?ref=newrelic-monitoring-x.y.z/monitoring/terraform"
```

where `newrelic-monitoring-x.y.z` stands for the corresponding Github release.

### Run the deployment

Initialize Terraform (and thereby the module):

```shell
# Initialize
terraform init

# Plan
terraform plan \
  -var NEW_RELIC_ACCOUNT_ID=<YOUR_NEWRELIC_ACCOUNT_ID> \
  -var NEW_RELIC_API_KEY=<YOUR_NEWRELIC_API_KEY> \
  -var NEW_RELIC_REGION=<YOUR_NEWRELIC_REGION> \
  -var cluster_name=<YOUR_CLUSTER_NAME> \
  -out "./tfplan"

# Apply
terraform apply tfplan
```

where

- `NEW_RELIC_ACCOUNT_ID` corresponds to your New Relic account ID
- `NEW_RELIC_API_KEY` to your [User API Key](https://docs.newrelic.com/docs/apis/intro-apis/new-relic-api-keys/#user-key)
- `NEWRELIC_REGION` to the data center region of your New Relic account (`us` or `eu`)
- `cluster_name` to the cluster name which you have deployed the [Helm](/helm/docs/helm_deployment.md) chart with

## Deploy locally

If you prefer to clone the repository and customize the New Relic Terraform resources, you can run the [`00_create_newrelic_resources.sh`](/monitoring/scripts/00_create_newrelic_resources.sh) script as below!

You need to define the following variables within the `terraform` commands

```shell
terraform -chdir=../terraform plan \
  -var NEW_RELIC_ACCOUNT_ID=<YOUR_NEWRELIC_ACCOUNT_ID> \
  -var NEW_RELIC_API_KEY=<YOUR_NEWRELIC_API_KEY> \
  -var NEW_RELIC_REGION=<YOUR_NEWRELIC_REGION> \
  -var cluster_name=<YOUR_CLUSTER_NAME> \
  -out "./tfplan"
```

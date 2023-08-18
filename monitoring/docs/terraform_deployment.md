# Terraform setup

Now, you know where the necessary metrics are coming from. So you can monitor your cluster instantly per the given Terraform deployment. For that, run the [`00_create_newrelic_resources.sh`](/monitoring/scripts/00_create_newrelic_resources.sh) script as below!

## Set your New Relic parameters

You need to define the following variables within the `terraform` commands

```shell
terraform -chdir=../terraform plan \
  -var NEW_RELIC_ACCOUNT_ID=$NEWRELIC_ACCOUNT_ID \
  -var NEW_RELIC_API_KEY=$NEWRELIC_API_KEY \
  -var NEW_RELIC_REGION=$NEWRELIC_REGION \
  -var cluster_name=$clusterName \
  -out "./tfplan"
```

where `NEW_RELIC_ACCOUNT_ID` corresponds to your New Relic account ID, `NEW_RELIC_API_KEY` to your [User API Key](https://docs.newrelic.com/docs/apis/intro-apis/new-relic-api-keys/#user-key) and `NEWRELIC_REGION` to the data center region of your New Relic account (`us` or `eu`).

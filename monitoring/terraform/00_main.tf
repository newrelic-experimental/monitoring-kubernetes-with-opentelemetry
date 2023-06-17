############
### Main ###
############

terraform {
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = ">=3.20.2"
    }
  }
}

# Configure the NR Provider
provider "newrelic" {
  account_id = var.NEW_RELIC_ACCOUNT_ID
  api_key    = var.NEW_RELIC_API_KEY
  region     = var.NEW_RELIC_REGION
}
#########
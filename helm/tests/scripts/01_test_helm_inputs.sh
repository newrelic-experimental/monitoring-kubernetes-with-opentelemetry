#!/bin/bash

# Get commandline arguments
while (( "$#" )); do
  case "$1" in
    --case)
      case="$2"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

### Set variables

# cluster name
clusterName="my-dope-cluster"

# otelcollectors
declare -A otelcollectors
otelcollectors["name"]="nr-otel"
otelcollectors["namespace"]="monitoring"

### Case 01 - Cluster name should be defined
if [[ $case == "01" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

### Case 02 - At least 1 telemetry type should be enabled
if [[ $case == "02" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

### Case 03, 04, 05 - New Relic account should be defined

# Deployment
if [[ $case == "03" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=true \
    --set deployment.newrelic=null \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

# Daemonset
if [[ $case == "04" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set daemonset.newrelic=null \
    --set metrics.enabled=false \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

# Statefulset
if [[ $case == "05" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    --set statefulset.newrelic=null \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

### Case 06, 07, 08 - OTLP endpoint should be valid (global)

# Deployment
if [[ $case == "06" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="INVALID_ENDPOINT" \
    --set traces.enabled=true \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

# Daemonset
if [[ $case == "07" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="INVALID_ENDPOINT" \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set metrics.enabled=false \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

# Statefulset
if [[ $case == "08" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="INVALID_ENDPOINT" \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

### Case 09, 10, 11 - OTLP endpoint should be valid (individual)

# Deployment
if [[ $case == "09" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=true \
    --set deployment.newrelic.opsteam.endpoint="INVALID_ENDPOINT" \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

# Daemonset
if [[ $case == "10" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set daemonset.newrelic.opsteam.endpoint="INVALID_ENDPOINT" \
    --set metrics.enabled=false \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

# Statefulset
if [[ $case == "11" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    --set statefulset.newrelic.opsteam.endpoint="INVALID_ENDPOINT" \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

### Case 12, 13, 14 - License key should be defined (global)

# Deployment
if [[ $case == "12" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="otlp.nr-data.net:4317" \
    --set traces.enabled=true \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

# Daemonset
if [[ $case == "13" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="otlp.nr-data.net:4317" \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set metrics.enabled=false \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

# Statefulset
if [[ $case == "14" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="otlp.nr-data.net:4317" \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    --set statefulset.newrelic.opsteam.endpoint="otlp.nr-data.net:4317" \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

### Case 15, 16, 17 - License key should be defined (individual)

# Deployment
if [[ $case == "15" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set traces.enabled=true \
    --set deployment.newrelic.opsteam.endpoint="otlp.nr-data.net:4317" \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

# Daemonset
if [[ $case == "16" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set daemonset.newrelic.opsteam.endpoint="otlp.nr-data.net:4317" \
    --set metrics.enabled=false \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

# Statefulset
if [[ $case == "17" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    --set statefulset.newrelic.opsteam.endpoint="otlp.nr-data.net:4317" \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

### Case 18, 19, 20 - License key reference should have a name (global)

# Deployment
if [[ $case == "18" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="otlp.nr-data.net:4317" \
    --set global.newrelic.teams.opsteam.licenseKey.secretRef.key="key" \
    --set traces.enabled=true \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

# Daemonset
if [[ $case == "19" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="otlp.nr-data.net:4317" \
    --set global.newrelic.teams.opsteam.licenseKey.secretRef.key="key" \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set metrics.enabled=false \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

# Statefulset
if [[ $case == "20" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="otlp.nr-data.net:4317" \
    --set global.newrelic.teams.opsteam.licenseKey.secretRef.key="key" \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

### Case 21, 22, 23 - License key reference should have a name (individual)

# Deployment
if [[ $case == "21" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=true \
    --set deployment.newrelic.opsteam.endpoint="otlp.nr-data.net:4317" \
    --set deployment.newrelic.opsteam.licenseKey.secretRef.key="key" \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

# Daemonset
if [[ $case == "22" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set daemonset.newrelic.opsteam.endpoint="otlp.nr-data.net:4317" \
    --set daemonset.newrelic.opsteam.licenseKey.secretRef.key="key" \
    --set metrics.enabled=false \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

# Statefulset
if [[ $case == "23" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    --set statefulset.newrelic.opsteam.endpoint="otlp.nr-data.net:4317" \
    --set statefulset.newrelic.opsteam.licenseKey.secretRef.key="key" \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

### Case 24, 25, 26 - License key reference should have a key (global)

# Deployment
if [[ $case == "24" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="otlp.nr-data.net:4317" \
    --set global.newrelic.teams.opsteam.licenseKey.secretRef.name="name" \
    --set traces.enabled=true \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

# Daemonset
if [[ $case == "25" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="otlp.nr-data.net:4317" \
    --set global.newrelic.teams.opsteam.licenseKey.secretRef.name="name" \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set metrics.enabled=false \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

# Statefulset
if [[ $case == "26" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="otlp.nr-data.net:4317" \
    --set global.newrelic.teams.opsteam.licenseKey.secretRef.name="name" \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

### Case 27, 28, 29 - License key reference should have a key (individual)

# Deployment
if [[ $case == "27" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=true \
    --set deployment.newrelic.opsteam.endpoint="otlp.nr-data.net:4317" \
    --set deployment.newrelic.opsteam.licenseKey.secretRef.name="name" \
    --set logs.enabled=false \
    --set metrics.enabled=false \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

# Daemonset
if [[ $case == "28" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=false \
    --set logs.enabled=true \
    --set daemonset.newrelic.opsteam.endpoint="otlp.nr-data.net:4317" \
    --set daemonset.newrelic.opsteam.licenseKey.secretRef.name="name" \
    --set metrics.enabled=false \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

# Statefulset
if [[ $case == "29" ]]; then
  result=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set traces.enabled=false \
    --set logs.enabled=false \
    --set metrics.enabled=true \
    --set statefulset.newrelic.opsteam.endpoint="otlp.nr-data.net:4317" \
    --set statefulset.newrelic.opsteam.licenseKey.secretRef.name="name" \
    "../../helm/charts/collectors" \
    2> /dev/null)
fi

# All of the cases are implemented to output an error as a result.
# If there is no error, the result would be an empty string.
# -> This means that the test case has failed to validate.
if [[ $result != "" ]]; then
  echo "Validation failed!"
  exit 1
fi

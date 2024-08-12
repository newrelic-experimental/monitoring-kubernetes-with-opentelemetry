#!/bin/bash

### Set variables

# cluster name
clusterName="my-dope-cluster"

# otelcollectors
declare -A otelcollectors
otelcollectors["name"]="nrotelk8s"
otelcollectors["namespace"]="monitoring"

runTests() {

  local helmTemplate="$1"
  local telemetryTypeInput="$2"

  ### Deployment
  echo ""
  echo "### ${telemetryTypeInput} ###"

  collectorDeploymentReceiverName="${otelcollectors[name]}-dep-rec"

  ## Collector pipeline configuration
  echo -e "\n---"
  echo "Message: Testing collector pipeline configuration for ${telemetryTypeInput}..."

  # Loop through the telemetry types: metrics, traces, logs
  for telemetryType in metrics traces logs; do
    echo -e "\n---"
    echo "Testing ${telemetryType} pipeline configuration..."

    echo "Mode: ${telemetryTypeInput} only"
    echo "Component: ${telemetryType} pipeline"

    # If the given telemetry type equals to the input telemetry type, then the relevant pipeline must be configured
    if [[ $telemetryType == $telemetryTypeInput ]]; then
      check=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentReceiverName}'")).spec.config' | yq '.service.pipelines.'"$entry"'/opsteam')
      if [[ $check == "" ]]; then
        echo "Message: Pipeline should be configured but it has not!"
        exit 1
      fi
    # If the given telemetry type does not equal to the input telemetry type, then the relevant pipeline should be null
    else
      check=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentReceiverName}'")).spec.config' | yq '.service.pipelines.'"$entry"'/opsteam')
      if [[ $check != "null" ]]; then
        echo "Message: Pipeline should not be configured but it has!"
        exit 1
      fi
    fi    
  done

  echo "Message: Tests for collector pipelines are run successfully."
  echo "---"
}

### Case - Only metrics
helmTemplate=$(helm template ${otelcollectors[name]} \
  --create-namespace \
  --namespace ${otelcollectors[namespace]} \
  --set clusterName=$clusterName \
  --set global.newrelic.enabled=true \
  --set daemonset.enabled=false \
  --set deployment.enabled=true \
  --set statefulset.enabled=false \
  --set singleton.enabled=false \
  --set global.newrelic.endpoint="https://otlp.nr-data.net" \
  --set global.newrelic.teams.opsteam.licenseKey.value="value_ops" \
  --set deployment.receiverPipeline.metrics.enabled=true \
  --set deployment.receiverPipeline.traces.enabled=false \
  --set deployment.receiverPipeline.logs.enabled=false \
  "../../charts/collectors" | yq)

runTests "$helmTemplate" "metrics"

### Case - Only traces
helmTemplate=$(helm template ${otelcollectors[name]} \
  --create-namespace \
  --namespace ${otelcollectors[namespace]} \
  --set clusterName=$clusterName \
  --set global.newrelic.enabled=true \
  --set daemonset.enabled=false \
  --set deployment.enabled=true \
  --set statefulset.enabled=false \
  --set singleton.enabled=false \
  --set global.newrelic.endpoint="https://otlp.nr-data.net" \
  --set global.newrelic.teams.opsteam.licenseKey.value="value_ops" \
  --set deployment.receiverPipeline.metrics.enabled=false \
  --set deployment.receiverPipeline.traces.enabled=true \
  --set deployment.receiverPipeline.logs.enabled=false \
  "../../charts/collectors" | yq)

runTests "$helmTemplate" "traces"

### Case - Only logs
helmTemplate=$(helm template ${otelcollectors[name]} \
  --create-namespace \
  --namespace ${otelcollectors[namespace]} \
  --set clusterName=$clusterName \
  --set global.newrelic.enabled=true \
  --set daemonset.enabled=false \
  --set deployment.enabled=true \
  --set statefulset.enabled=false \
  --set singleton.enabled=false \
  --set global.newrelic.endpoint="https://otlp.nr-data.net" \
  --set global.newrelic.teams.opsteam.licenseKey.value="value_ops" \
  --set deployment.receiverPipeline.metrics.enabled=false \
  --set deployment.receiverPipeline.traces.enabled=false \
  --set deployment.receiverPipeline.logs.enabled=true \
  "../../charts/collectors" | yq)

runTests "$helmTemplate" "logs"

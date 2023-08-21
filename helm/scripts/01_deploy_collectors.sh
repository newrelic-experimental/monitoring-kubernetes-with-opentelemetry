#!/bin/bash

# Get commandline arguments
while (( "$#" )); do
  case "$1" in
    --cluster-name)
      clusterName="${2}"
      shift
      ;;
    --newrelic-region)
      newrelicRegion="${2}"
      shift
      ;;
    --case)
      case="${2}"
      shift
      ;;    
    *)
      shift
      ;;
  esac
done

### Check input

# Cluster name
if [[ $clusterName == "" ]]; then
  echo "Cluster name is not defined! Use the flag [--cluster-name]."
  exit 1
fi

# New Relic OTLP endpoint
newrelicOtlpEndpoint="otlp.nr-data.net:4317"
if [[ $newrelicRegion == "eu" ]]; then
  newrelicOtlpEndpoint="otlp.eu01.nr-data.net:4317"
fi

### Set parameters

# nodeexporter
declare -A nodeexporter
nodeexporter["name"]="nodeexporter"
nodeexporter["remoteChartName"]="prometheus-node-exporter"
nodeexporter["namespace"]="monitoring"

# kubestatemetrics
declare -A kubestatemetrics
kubestatemetrics["name"]="kubestatemetrics"
kubestatemetrics["remoteChartName"]="kube-state-metrics"
kubestatemetrics["namespace"]="monitoring"

# otelcollectors
declare -A otelcollectors
otelcollectors["name"]="nrotelk8s"
otelcollectors["namespace"]="monitoring"

###################
### Deploy Helm ###
###################

echo "##################"
echo "### CASE $case ###"
echo "##################"

### CASE 01 ###
# Global configuration enabled: true
# External NE & KSM dependency: false
if [[ $case == "1" ]]; then

  # Deploy otelcollectors
  helm upgrade ${otelcollectors[name]} \
    --install \
    --wait \
    --debug \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint=$newrelicOtlpEndpoint \
    --set global.newrelic.teams.opsteam.licenseKey.value=$NEWRELIC_LICENSE_KEY \
    "newrelic-experimental/nrotelk8s"
fi

### CASE 02 ###
# Global configuration enabled: false
# External NE & KSM dependency: false
if [[ $case == "2" ]]; then

  # Deploy otelcollectors
  helm upgrade ${otelcollectors[name]} \
    --install \
    --wait \
    --debug \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set deployment.newrelic.teams.opsteam.endpoint=$newrelicOtlpEndpoint \
    --set deployment.newrelic.teams.opsteam.licenseKey.value=$NEWRELIC_LICENSE_KEY \
    --set daemonset.newrelic.teams.opsteam.endpoint=$newrelicOtlpEndpoint \
    --set daemonset.newrelic.teams.opsteam.licenseKey.value=$NEWRELIC_LICENSE_KEY \
    --set statefulset.newrelic.teams.opsteam.endpoint=$newrelicOtlpEndpoint \
    --set statefulset.newrelic.teams.opsteam.licenseKey.value=$NEWRELIC_LICENSE_KEY \
    "newrelic-experimental/nrotelk8s"
fi

### CASE 03 ###
# Global configuration enabled: true
# External NE & KSM dependency: true
if [[ $case == "3" ]]; then

  # Add and update Prometheus repositories
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update prometheus-community

  # Deploy nodeexporter
  helm upgrade ${nodeexporter[name]} \
    --install \
    --wait \
    --debug \
    --create-namespace \
    --namespace ${nodeexporter[namespace]} \
    --set tolerations[0].key="node-role.kubernetes.io/master" \
    --set tolerations[0].operator="Exists" \
    --set tolerations[0].effect="NoSchedule" \
    --set tolerations[1].key="node-role.kubernetes.io/control-plane" \
    --set tolerations[1].operator="Exists" \
    --set tolerations[1].effect="NoSchedule" \
    "prometheus-community/${nodeexporter[remoteChartName]}"

  # Deploy kubestatemetrics
  helm upgrade ${kubestatemetrics[name]} \
    --install \
    --wait \
    --debug \
    --create-namespace \
    --namespace ${kubestatemetrics[namespace]} \
    --set autosharding.enabled=true \
    "prometheus-community/${kubestatemetrics[remoteChartName]}"

  # Deploy otelcollectors
  helm upgrade ${otelcollectors[name]} \
    --install \
    --wait \
    --debug \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint=$newrelicOtlpEndpoint \
    --set global.newrelic.teams.opsteam.licenseKey.value=$NEWRELIC_LICENSE_KEY \
    --set statefulset.prometheus.nodeExporter.enabled=false \
    --set statefulset.prometheus.nodeExporter.serviceNameRef="${nodeexporter[name]}-${nodeexporter[remoteChartName]}" \
    --set statefulset.prometheus.kubeStateMetrics.enabled=false \
    --set statefulset.prometheus.kubeStateMetrics.serviceNameRef="${kubestatemetrics[name]}-${kubestatemetrics[remoteChartName]}" \
    "newrelic-experimental/nrotelk8s"
fi

### CASE 04 ###
# Global configuration enabled: false
# External NE & KSM dependency: true
if [[ $case == "4" ]]; then

  # Add and update Prometheus repositories
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update prometheus-community

  # Deploy nodeexporter
  helm upgrade ${nodeexporter[name]} \
    --install \
    --wait \
    --debug \
    --create-namespace \
    --namespace ${nodeexporter[namespace]} \
    --set tolerations[0].key="node-role.kubernetes.io/master" \
    --set tolerations[0].operator="Exists" \
    --set tolerations[0].effect="NoSchedule" \
    --set tolerations[1].key="node-role.kubernetes.io/control-plane" \
    --set tolerations[1].operator="Exists" \
    --set tolerations[1].effect="NoSchedule" \
    "prometheus-community/${nodeexporter[remoteChartName]}"

  # Deploy kubestatemetrics
  helm upgrade ${kubestatemetrics[name]} \
    --install \
    --wait \
    --debug \
    --create-namespace \
    --namespace ${kubestatemetrics[namespace]} \
    --set autosharding.enabled=true \
    "prometheus-community/${kubestatemetrics[remoteChartName]}"

  # Deploy otelcollectors
  helm upgrade ${otelcollectors[name]} \
    --install \
    --wait \
    --debug \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set deployment.newrelic.teams.opsteam.endpoint=$newrelicOtlpEndpoint \
    --set deployment.newrelic.teams.opsteam.licenseKey.value=$NEWRELIC_LICENSE_KEY \
    --set daemonset.newrelic.teams.opsteam.endpoint=$newrelicOtlpEndpoint \
    --set daemonset.newrelic.teams.opsteam.licenseKey.value=$NEWRELIC_LICENSE_KEY \
    --set statefulset.newrelic.teams.opsteam.endpoint=$newrelicOtlpEndpoint \
    --set statefulset.newrelic.teams.opsteam.licenseKey.value=$NEWRELIC_LICENSE_KEY \
    --set statefulset.prometheus.nodeExporter.enabled=false \
    --set statefulset.prometheus.nodeExporter.serviceNameRef="${nodeexporter[name]}-${nodeexporter[remoteChartName]}" \
    --set statefulset.prometheus.kubeStateMetrics.enabled=false \
    --set statefulset.prometheus.kubeStateMetrics.serviceNameRef="${kubestatemetrics[name]}-${kubestatemetrics[remoteChartName]}" \
    "newrelic-experimental/nrotelk8s"
fi

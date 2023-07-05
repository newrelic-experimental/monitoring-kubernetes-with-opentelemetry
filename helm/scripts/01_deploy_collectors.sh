#!/bin/bash

# Get commandline arguments
while (( "$#" )); do
  case "$1" in
    --external)
      externalNodeExporterAndKubeStateMetrics="true"
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

# New Relic OTLP endpoint
newrelicOtlpEndpoint="otlp.eu01.nr-data.net:4317"

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
otelcollectors["name"]="nr-otel"
otelcollectors["namespace"]="monitoring"
otelcollectors["deploymentPrometheusPort"]=8888
otelcollectors["daemonsetPrometheusPort"]=8888
otelcollectors["statefulsetPrometheusPort"]=8888

###################
### Deploy Helm ###
###################

# Repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# If the flag for "external" is set, deploy the node-exporter and
# kube-state-metrics separately from the actual chart and reference
# their services.
if [[ $externalNodeExporterAndKubeStateMetrics == "true" ]]; then
  # nodeexporter
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

  # kubestatemetrics
  helm upgrade ${kubestatemetrics[name]} \
    --install \
    --wait \
    --debug \
    --create-namespace \
    --namespace ${kubestatemetrics[namespace]} \
    --set autosharding.enabled=true \
    "prometheus-community/${kubestatemetrics[remoteChartName]}"

  # otelcollector
  helm upgrade ${otelcollectors[name]} \
    --install \
    --wait \
    --debug \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set traces.enabled=true \
    --set deployment.ports.prometheus.port=${otelcollectors[deploymentPrometheusPort]} \
    --set deployment.newrelic.teams.opsteam.endpoint=$newrelicOtlpEndpoint \
    --set deployment.newrelic.teams.opsteam.licenseKey.value=$NEWRELIC_LICENSE_KEY \
    --set logs.enabled=true \
    --set daemonset.ports.prometheus.port=${otelcollectors[daemonsetPrometheusPort]} \
    --set daemonset.newrelic.teams.opsteam.endpoint=$newrelicOtlpEndpoint \
    --set daemonset.newrelic.teams.opsteam.licenseKey.value=$NEWRELIC_LICENSE_KEY \
    --set metrics.enabled=true \
    --set statefulset.ports.prometheus.port=${otelcollectors[statefulsetPrometheusPort]} \
    --set statefulset.prometheus.nodeExporter.enabled=false \
    --set statefulset.prometheus.nodeExporter.serviceNameRef="${nodeexporter[name]}-${nodeexporter[remoteChartName]}" \
    --set statefulset.prometheus.kubeStateMetrics.enabled=false \
    --set statefulset.prometheus.kubeStateMetrics.serviceNameRef="${kubestatemetrics[name]}-${kubestatemetrics[remoteChartName]}" \
    --set statefulset.newrelic.teams.opsteam.endpoint=$newrelicOtlpEndpoint \
    --set statefulset.newrelic.teams.opsteam.licenseKey.value=$NEWRELIC_LICENSE_KEY \
    "../charts/collectors"

# If the flag "external" is not set, deploy the node-exporter and
# the kube-state-metrics with the actual chart as dependencies.
else
  # otelcollector
  helm dependency update "../charts/collectors"
  helm upgrade ${otelcollectors[name]} \
    --install \
    --wait \
    --debug \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set traces.enabled=true \
    --set deployment.ports.prometheus.port=${otelcollectors[deploymentPrometheusPort]} \
    --set deployment.newrelic.teams.opsteam.endpoint=$newrelicOtlpEndpoint \
    --set deployment.newrelic.teams.opsteam.licenseKey.value=$NEWRELIC_LICENSE_KEY \
    --set logs.enabled=true \
    --set daemonset.ports.prometheus.port=${otelcollectors[daemonsetPrometheusPort]} \
    --set daemonset.newrelic.teams.opsteam.endpoint=$newrelicOtlpEndpoint \
    --set daemonset.newrelic.teams.opsteam.licenseKey.value=$NEWRELIC_LICENSE_KEY \
    --set metrics.enabled=true \
    --set statefulset.ports.prometheus.port=${otelcollectors[statefulsetPrometheusPort]} \
    --set statefulset.newrelic.teams.opsteam.endpoint=$newrelicOtlpEndpoint \
    --set statefulset.newrelic.teams.opsteam.licenseKey.value=$NEWRELIC_LICENSE_KEY \
    "../charts/collectors"
fi

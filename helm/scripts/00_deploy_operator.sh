#!/bin/bash

# certmanager
declare -A certmanager
certmanager["name"]="cert-manager"
certmanager["namespace"]="cert-manager"

# oteloperator
declare -A oteloperator
oteloperator["name"]="oteloperator"
oteloperator["namespace"]="monitoring"

###################
### Deploy Helm ###
###################

# Add helm repos
helm repo add jetstack https://charts.jetstack.io
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update

# cert-manager
helm upgrade ${certmanager[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace ${certmanager[namespace]} \
  --version v1.15.0 \
  --set installCRDs=true \
  "jetstack/cert-manager"

# otel-operator
helm upgrade ${oteloperator[name]} \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace ${oteloperator[namespace]} \
  --set manager.collectorImage.repository="otel/opentelemetry-collector-contrib" \
  --set manager.collectorImage.tag="0.102.1" \
  --version "0.62.0" \
  "open-telemetry/opentelemetry-operator"

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
otelcollectors["name"]="nrotelk8s"
otelcollectors["namespace"]="monitoring"

runTests() {

  local helmTemplate="$1"

  ### Daemonset
  echo ""
  echo "#################################"
  echo "### Collector type: Daemonset ###"
  echo "#################################"

  collectorDaemonsetName="${otelcollectors[name]}-ds"
  secretDaemonsetOpsteamName="${otelcollectors[name]}-ds-opsteam"
  secretDaemonsetDevteam1Name="${otelcollectors[name]}-ds-devteam1"
  secretDaemonsetDevteam2Name="${otelcollectors[name]}-ds-devteam2"

  ## Secret creation
  echo -e "\n---"
  echo "Message: Testing secret creation..."

  # Secret for opsteam should be created
  secretDaemonsetOpsteamCheck=$(echo "$helmTemplate" | yq 'select((.kind == "Secret") and (.metadata.name == "'${secretDaemonsetOpsteamName}'")).metadata.name')
  if [[ $secretDaemonsetOpsteamCheck != $secretDaemonsetOpsteamName ]]; then
    echo "Team: opsteam"
    echo "Message: Secret should have been created but it has not!"
    exit 1
  fi

  # Secret for devteam1 should be created
  secretDaemonsetDevteam1Check=$(echo "$helmTemplate" | yq 'select((.kind == "Secret") and (.metadata.name == "'${secretDaemonsetDevteam1Name}'")).metadata.name')
  if [[ $secretDaemonsetDevteam1Check != $secretDaemonsetDevteam1Name ]]; then
    echo "Team: devteam1"
    echo "Message: Secret should have been created but it has not!"
    exit 1
  fi

  # Secret for devteam2 should not be created
  secretDaemonsetDevteam2Check=$(echo "$helmTemplate" | yq 'select((.kind == "Secret") and (.metadata.name == "'${secretDaemonsetDevteam2Name}'")).metadata.name')
  if [[ $secretDaemonsetDevteam2Check != "" ]]; then
    echo "Team: devteam2"
    echo "Message: Secret should not have been created but it has!"
    exit 1
  fi

  echo "Message: Tests for secret creation are run successfully."
  echo "---"

  ## Collector secret environment variables assignment
  echo -e "\n---"
  echo "Message: Testing collector secret environment variables assignment..."

  # Secret for opsteam should be assigned
  collectorDaemonsetOpsteamEnvVarCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDaemonsetName}'")).spec.env[] | select(.valueFrom.secretKeyRef.name == "'${secretDaemonsetOpsteamName}'").valueFrom.secretKeyRef.name')
  if [[ $collectorDaemonsetOpsteamEnvVarCheck != $secretDaemonsetOpsteamName ]]; then
    echo "Team: opsteam"
    echo "Message: Environment variable should have been assigned but it has not!"
    exit 1
  fi

  # Secret for devteam1 should be assigned
  collectorDaemonsetDevteam1EnvVarCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDaemonsetName}'")).spec.env[] | select(.valueFrom.secretKeyRef.name == "'${secretDaemonsetDevteam1Name}'").valueFrom.secretKeyRef.name')
  if [[ $collectorDaemonsetDevteam1EnvVarCheck != $secretDaemonsetDevteam1Name ]]; then
    echo "Team: devteam1"
    echo "Message: Environment variable should have been assigned but it has not!"
    exit 1
  fi

  # Secret for devteam2 should not be assigned
  collectorDaemonsetDevteam2EnvVarCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDaemonsetName}'")).spec.env[] | select(.valueFrom.secretKeyRef.name == "'${secretDaemonsetDevteam2Name}'").valueFrom.secretKeyRef.name')
  if [[ $collectorDaemonsetDevteam2EnvVarCheck != "" ]]; then
    echo "Team: devteam2"
    echo "Message: Environment variable should not have been assigned but it has!"
    exit 1
  fi

  echo "Message: Tests for secret assignments as environment variables are run successfully."
  echo "---"

  ## Collector processors configuration
  echo -e "\n---"
  echo "Message: Testing collector processors configuration..."

  # Filter processor for devteam1 should be configured
  collectorDaemonsetDevteam1ProcessorFilterConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDaemonsetName}'")).spec.config' | yq '.processors.filter/devteam1')
  if [[ $collectorDaemonsetDevteam1ProcessorFilterConfigCheck == "" ]]; then
    echo "Team: devteam1"
    echo "Component: filterprocessor"
    echo "Processor should be configured but it has not!"
    exit 1
  fi

  # Filter processor for devteam2 should not be configured
  collectorDaemonsetDevteam2ProcessorFilterConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDaemonsetName}'")).spec.config' | yq '.processors.filter/devteam2')
  if [[ $collectorDaemonsetDevteam2ProcessorFilterConfigCheck != "null" ]]; then
    echo "Team: devteam2"
    echo "Component: filterprocessor"
    echo "Processor should not be configured but it has!"
    exit 1
  fi

  echo "Message: Tests for collector processors are run successfully."
  echo "---"

  ## Collector exporter configuration
  echo -e "\n---"
  echo "Message: Testing collector exporter configuration..."

  # OTLP exporter for opsteam should be configured
  collectorDaemonsetOpsteamExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDaemonsetName}'")).spec.config' | yq '.exporters.otlp/opsteam')
  if [[ $collectorDaemonsetOpsteamExporterOtlpConfigCheck == "" ]]; then
    echo "Team: opsteam"
    echo "Component: otlpexporter"
    echo "Message: Exporter should be configured but it has not!"
    exit 1
  fi

  # OTLP exporter for devteam1 should be configured
  collectorDaemonsetDevteam1ExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDaemonsetName}'")).spec.config' | yq '.exporters.otlp/devteam1')
  if [[ $collectorDaemonsetDevteam1ExporterOtlpConfigCheck == "" ]]; then
    echo "Team: devteam1"
    echo "Component: otlpexporter"
    echo "Message: Exporter should be configured but it has not!"
    exit 1
  fi

  # OTLP exporter for devteam2 should not be configured
  collectorDaemonsetDevteam2ExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDaemonsetName}'")).spec.config' | yq '.exporters.otlp/devteam2')
  if [[ $collectorDaemonsetDevteam2ExporterOtlpConfigCheck != "null" ]]; then
    echo "Team: devteam2"
    echo "Component: otlpexporter"
    echo "Message: Exporter should not be configured but it has!"
    exit 1
  fi

  echo "Message: Tests for collector exporters are run successfully."
  echo "---"

  ## Collector pipeline configuration
  echo -e "\n---"
  echo "Message: Testing collector pipeline configuration..."

  # Pipeline otlp exporter for opsteam should be configured
  collectorDaemonsetOpsteamPipelineExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDaemonsetName}'")).spec.config' | yq '.service.pipelines.logs/opsteam.exporters[]' | yq 'select("otlp/opsteam")')
  if [[ $collectorDaemonsetOpsteamPipelineExporterOtlpConfigCheck == "" ]]; then
    echo "Team: opsteam"
    echo "Component: otlpexporter"
    echo "Telemetry: logs"
    echo "Message: Pipeline should be configured but it has not!"
    exit 1
  fi

  # Pipeline filter processor for devteam1 should be configured
  collectorDaemonsetDevteam1PipelineProcessorFilterConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDaemonsetName}'")).spec.config' | yq '.service.pipelines.logs/devteam1.processors[]' | yq 'select("filter/devteam1")')
  if [[ $collectorDaemonsetDevteam1PipelineProcessorFilterConfigCheck == "" ]]; then
    echo "Team: devteam1"
    echo "Component: filterprocessor"
    echo "Telemetry: logs"
    echo "Message: Pipeline should be configured but it has not!"
    exit 1
  fi

  # Pipeline otlp exporter for devteam1 should be configured
  collectorDaemonsetDevteam1PipelineExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDaemonsetName}'")).spec.config' | yq '.service.pipelines.logs/devteam1.exporters[]' | yq 'select("otlp/devteam1")')
  if [[ $collectorDaemonsetDevteam1PipelineExporterOtlpConfigCheck == "" ]]; then
    echo "Team: devteam1"
    echo "Component: otlpexporter"
    echo "Telemetry: logs"
    echo "Message: Pipeline should be configured but it has not!"
    exit 1
  fi

  # Pipeline filter processor for devteam2 should be configured
  collectorDaemonsetDevteam2PipelineProcessorFilterConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDaemonsetName}'")).spec.config' | yq '.service.pipelines.logs/devteam2.processors[]' | yq 'select("filter/devteam2")')
  if [[ $collectorDaemonsetDevteam2PipelineProcessorFilterConfigCheck != "" ]]; then
    echo "Team: devteam2"
    echo "Component: filterprocessor"
    echo "Telemetry: logs"
    echo "Message: Pipeline should not be configured but it has!"
    exit 1
  fi

  # Pipeline otlp exporter for devteam2 should not be configured
  collectorDaemonsetDevteam2PipelineExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDaemonsetName}'")).spec.config' | yq '.service.pipelines.logs/devteam2.exporters[]' | yq 'select("otlp/devteam2")')
  if [[ $collectorDaemonsetDevteam2PipelineExporterOtlpConfigCheck != "" ]]; then
    echo "Team: devteam2"
    echo "Component: otlpexporter"
    echo "Telemetry: logs"
    echo "Message: Pipeline should not be configured but it has!"
    exit 1
  fi

  echo "Message: Tests for collector pipelines are run successfully."
  echo "---"

  ### Deployment
  echo ""
  echo "##################################"
  echo "### Collector type: Deployment ###"
  echo "##################################"

  collectorDeploymentReceiverName="${otelcollectors[name]}-dep-rec"
  collectorDeploymentSamplerName="${otelcollectors[name]}-dep-smp"
  secretDeploymentOpsteamName="${otelcollectors[name]}-dep-opsteam"
  secretDeploymentDevteam1Name="${otelcollectors[name]}-dep-devteam1"
  secretDeploymentDevteam2Name="${otelcollectors[name]}-dep-devteam2"

  ## Secret creation
  echo -e "\n---"
  echo "Message: Testing secret creation..."

  # Secret for opsteam should be created
  secretDeploymentOpsteamCheck=$(echo "$helmTemplate" | yq 'select((.kind == "Secret") and (.metadata.name == "'${secretDeploymentOpsteamName}'")).metadata.name')
  if [[ $secretDeploymentOpsteamCheck != $secretDeploymentOpsteamName ]]; then
    echo "Team: opsteam"
    echo "Message: Secret should have been created but it has not!"
    exit 1
  fi

  # Secret for devteam1 should be created
  secretDeploymentDevteam1Check=$(echo "$helmTemplate" | yq 'select((.kind == "Secret") and (.metadata.name == "'${secretDeploymentDevteam1Name}'")).metadata.name')
  if [[ $secretDeploymentDevteam1Check != $secretDeploymentDevteam1Name ]]; then
    echo "Team: devteam1"
    echo "Secret should have been created but it has not!"
    exit 1
  fi

  # Secret for devteam2 should not be created
  secretDeploymentDevteam2Check=$(echo "$helmTemplate" | yq 'select((.kind == "Secret") and (.metadata.name == "'${secretDeploymentDevteam2Name}'")).metadata.name')
  if [[ $secretDeploymentDevteam2Check != "" ]]; then
    echo "Team: devteam2"
    echo "Secret should not have been created but it has!"
    exit 1
  fi

  echo "Message: Tests for secret creation are run successfully."
  echo "---"

  ## Collector secret environment variables assignment
  echo -e "\n---"
  echo "Message: Testing collector secret environment variables assignment..."

  # Secret for opsteam should be assigned - receiver
  collectorDeploymentReceiverOpsteamEnvVarCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentReceiverName}'")).spec.env[] | select(.valueFrom.secretKeyRef.name == "'${secretDeploymentOpsteamName}'").valueFrom.secretKeyRef.name')
  if [[ $collectorDeploymentReceiverOpsteamEnvVarCheck != $secretDeploymentOpsteamName ]]; then
    echo "Mode: receiver"
    echo "Team: opsteam"
    echo "Message: Environment variable should have been assigned but it has not!"
    exit 1
  fi

  # Secret for devteam1 should be assigned - receiver
  collectorDeploymentReceiverDevteam1EnvVarCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentReceiverName}'")).spec.env[] | select(.valueFrom.secretKeyRef.name == "'${secretDeploymentDevteam1Name}'").valueFrom.secretKeyRef.name')
  if [[ $collectorDeploymentReceiverDevteam1EnvVarCheck != $secretDeploymentDevteam1Name ]]; then
    echo "Mode: receiver"
    echo "Team: devteam1"
    echo "Message: Environment variable should have been assigned but it has not!"
    exit 1
  fi

  # Secret for devteam2 should not be assigned - receiver
  collectorDeploymentReceiverDevteam2EnvVarCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentReceiverName}'")).spec.env[] | select(.valueFrom.secretKeyRef.name == "'${secretDeploymentDevteam2Name}'").valueFrom.secretKeyRef.name')
  if [[ $collectorDeploymentReceiverDevteam2EnvVarCheck != "" ]]; then
    echo "Mode: receiver"
    echo "Team: devteam2"
    echo "Message: Environment variable should not have been assigned but it has!"
    exit 1
  fi

  # Secret for opsteam should be assigned - sampler
  collectorDeploymentSamplerOpsteamEnvVarCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentSamplerName}'")).spec.env[] | select(.valueFrom.secretKeyRef.name == "'${secretDeploymentOpsteamName}'").valueFrom.secretKeyRef.name')
  if [[ $collectorDeploymentSamplerOpsteamEnvVarCheck != $secretDeploymentOpsteamName ]]; then
    echo "Mode: sampler"
    echo "Team: opsteam"
    echo "Message: Environment variable should have been assigned but it has not!"
    exit 1
  fi

  # Secret for devteam1 should be assigned - sampler
  collectorDeploymentSamplerDevteam1EnvVarCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentSamplerName}'")).spec.env[] | select(.valueFrom.secretKeyRef.name == "'${secretDeploymentDevteam1Name}'").valueFrom.secretKeyRef.name')
  if [[ $collectorDeploymentSamplerDevteam1EnvVarCheck != $secretDeploymentDevteam1Name ]]; then
    echo "Mode: sampler"
    echo "Team: devteam1"
    echo "Message: Environment variable should have been assigned but it has not!"
    exit 1
  fi

  # Secret for devteam2 should not be assigned - sampler
  collectorDeploymentSamplerDevteam2EnvVarCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentSamplerName}'")).spec.env[] | select(.valueFrom.secretKeyRef.name == "'${secretDeploymentDevteam2Name}'").valueFrom.secretKeyRef.name')
  if [[ $collectorDeploymentSamplerDevteam2EnvVarCheck != "" ]]; then
    echo "Mode: sampler"
    echo "Team: devteam2"
    echo "Message: Environment variable should not have been assigned but it has!"
    exit 1
  fi

  echo "Message: Tests for secret assignments as environment variables are run successfully."
  echo "---"

  ## Collector processors configuration
  echo -e "\n---"
  echo "Message: Testing collector processors configuration..."

  # Filter processor for devteam1 should be configured - receiver
  collectorDeploymentReceiverDevteam1ProcessorFilterConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentReceiverName}'")).spec.config' | yq '.processors.filter/devteam1')
  if [[ $collectorDeploymentReceiverDevteam1ProcessorFilterConfigCheck == "" ]]; then
    echo "Mode: receiver"
    echo "Team: devteam1"
    echo "Component: filterprocessor"
    echo "Processor should be configured but it has not!"
    exit 1
  fi

  # Filter processor for devteam2 should not be configured - receiver
  collectorDeploymentReceiverDevteam2ProcessorFilterConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentReceiverName}'")).spec.config' | yq '.processors.filter/devteam2')
  if [[ $collectorDeploymentReceiverDevteam2ProcessorFilterConfigCheck != "null" ]]; then
    echo "Mode: receiver"
    echo "Team: devteam2"
    echo "Component: filterprocessor"
    echo "Processor should not be configured but it has!"
    exit 1
  fi

  # Filter processor for devteam1 should be configured - sampler
  collectorDeploymentSamplerDevteam1ProcessorFilterConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentSamplerName}'")).spec.config' | yq '.processors.filter/devteam1')
  if [[ $collectorDeploymentSamplerDevteam1ProcessorFilterConfigCheck == "" ]]; then
    echo "Mode: sampler"
    echo "Team: devteam1"
    echo "Component: filterprocessor"
    echo "Processor should be configured but it has not!"
    exit 1
  fi

  # Filter processor for devteam2 should not be configured - sampler
  collectorDeploymentSamplerDevteam2ProcessorFilterConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentSamplerName}'")).spec.config' | yq '.processors.filter/devteam2')
  if [[ $collectorDeploymentSamplerDevteam2ProcessorFilterConfigCheck != "null" ]]; then
    echo "Mode: sampler"
    echo "Team: devteam2"
    echo "Component: filterprocessor"
    echo "Processor should not be configured but it has!"
    exit 1
  fi

  echo "Message: Tests for collector processors are run successfully."
  echo "---"

  ## Collector exporter configuration
  echo -e "\n---"
  echo "Message: Testing collector exporter configuration..."

  # OTLP exporter for opsteam should be configured - receiver
  collectorDeploymentReceiverOpsteamExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentReceiverName}'")).spec.config' | yq '.exporters.otlp/opsteam')
  if [[ $collectorDeploymentReceiverOpsteamExporterOtlpConfigCheck == "" ]]; then
    echo "Mode: receiver"
    echo "Team: opsteam"
    echo "Component: otlpexporter"
    echo "Message: Exporter should be configured but it has not!"
    exit 1
  fi

  # OTLP exporter for devteam1 should be configured - receiver
  collectorDeploymentReceiverDevteam1ExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentReceiverName}'")).spec.config' | yq '.exporters.otlp/devteam1')
  if [[ $collectorDeploymentReceiverDevteam1ExporterOtlpConfigCheck == "" ]]; then
    echo "Mode: receiver"
    echo "Team: devteam1"
    echo "Component: otlpexporter"
    echo "Message: Exporter should be configured but it has not!"
    exit 1
  fi

  # OTLP exporter for devteam2 should not be configured - receiver
  collectorDeploymentReceiverDevteam2ExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentReceiverName}'")).spec.config' | yq '.exporters.otlp/devteam2')
  if [[ $collectorDeploymentReceiverDevteam2ExporterOtlpConfigCheck != "null" ]]; then
    echo "Mode: receiver"
    echo "Team: devteam2"
    echo "Component: otlpexporter"
    echo "Message: Exporter should not be configured but it has!"
    exit 1
  fi

  # Loadbalancing exporter should be configured - receiver
  collectorDeploymentReceiverExporterLoadbalancingConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentReceiverName}'")).spec.config' | yq '.exporters.loadbalancing')
  if [[ $collectorDeploymentReceiverExporterLoadbalancingConfigCheck == "" ]]; then
    echo "Mode: receiver"
    echo "Component: loadbalancingexporter"
    echo "Message: Exporter should be configured but it has not!"
    exit 1
  fi

  # OTLP exporter for opsteam should be configured - sampler
  collectorDeploymentSamplerOpsteamExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentSamplerName}'")).spec.config' | yq '.exporters.otlp/opsteam')
  if [[ $collectorDeploymentSamplerOpsteamExporterOtlpConfigCheck == "" ]]; then
    echo "Mode: sampler"
    echo "Team: opsteam"
    echo "Component: otlpexporter"
    echo "Message: Exporter should be configured but it has not!"
    exit 1
  fi

  # OTLP exporter for devteam1 should be configured - sampler
  collectorDeploymentSamplerDevteam1ExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentSamplerName}'")).spec.config' | yq '.exporters.otlp/devteam1')
  if [[ $collectorDeploymentSamplerDevteam1ExporterOtlpConfigCheck == "" ]]; then
    echo "Mode: sampler"
    echo "Team: devteam1"
    echo "Component: otlpexporter"
    echo "Message: Exporter should be configured but it has not!"
    exit 1
  fi

  # OTLP exporter for devteam2 should not be configured - sampler
  collectorDeploymentSamplerDevteam2ExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentSamplerName}'")).spec.config' | yq '.exporters.otlp/devteam2')
  if [[ $collectorDeploymentSamplerDevteam2ExporterOtlpConfigCheck != "null" ]]; then
    echo "Mode: sampler"
    echo "Team: devteam2"
    echo "Component: otlpexporter"
    echo "Message: Exporter should not be configured but it has!"
    exit 1
  fi

  echo "Message: Tests for collector exporters are run successfully."
  echo "---"

  ## Collector pipeline configuration
  echo -e "\n---"
  echo "Message: Testing collector pipeline configuration..."

  # Pipeline otlp exporter for opsteam should be configured - receiver
  collectorDeploymentReceiverOpsteamPipelineExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentReceiverName}'")).spec.config' | yq '.service.pipelines.metrics/opsteam.exporters[]' | yq 'select("otlp/opsteam")')
  if [[ $collectorDeploymentReceiverOpsteamPipelineExporterOtlpConfigCheck == "" ]]; then
    echo "Mode: receiver"
    echo "Team: opsteam"
    echo "Component: otlpexporter"
    echo "Telemetry: metrics"
    echo "Message: Pipeline should be configured but it has not!"
    exit 1
  fi

  # Pipeline filter processor for devteam1 should be configured - receiver
  collectorDeploymentReceiverDevteam1PipelineProcessorFilterConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentReceiverName}'")).spec.config' | yq '.service.pipelines.metrics/devteam1.processors[]' | yq 'select("filter/devteam1")')
  if [[ $collectorDeploymentReceiverDevteam1PipelineProcessorFilterConfigCheck == "" ]]; then
    echo "Mode: receiver"
    echo "Team: devteam1"
    echo "Component: filterprocessing"
    echo "Telemetry: metrics"
    echo "Message: Pipeline should be configured but it has not!"
    exit 1
  fi

  # Pipeline otlp exporter for devteam1 should be configured - receiver
  collectorDeploymentReceiverDevteam1PipelineExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentReceiverName}'")).spec.config' | yq '.service.pipelines.metrics/devteam1.exporters[]' | yq 'select("otlp/devteam1")')
  if [[ $collectorDeploymentReceiverDevteam1PipelineExporterOtlpConfigCheck == "" ]]; then
    echo "Mode: receiver"
    echo "Team: devteam1"
    echo "Component: otlpexporter"
    echo "Telemetry: metrics"
    echo "Message: Pipeline should be configured but it has not!"
    exit 1
  fi

  # Pipeline filter processor for devteam2 should be configured - receiver
  collectorDeploymentReceiverDevteam2PipelineProcessorFilterConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentReceiverName}'")).spec.config' | yq '.service.pipelines.metrics/devteam2.processors[]' | yq 'select("filter/devteam2")')
  if [[ $collectorDeploymentReceiverDevteam2PipelineProcessorFilterConfigCheck != "" ]]; then
    echo "Mode: receiver"
    echo "Team: devteam2"
    echo "Component: filterprocessing"
    echo "Telemetry: metrics"
    echo "Message: Pipeline should not be configured but it has!"
    exit 1
  fi

  # Pipeline otlp exporter for devteam2 should not be configured - receiver
  collectorDeploymentReceiverDevteam2PipelineExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentReceiverName}'")).spec.config' | yq '.service.pipelines.metrics/devteam2.exporters[]' | yq 'select("otlp/devteam2")')
  if [[ $collectorDeploymentReceiverDevteam2PipelineExporterOtlpConfigCheck != "" ]]; then
    echo "Mode: receiver"
    echo "Team: devteam2"
    echo "Component: otlpexporter"
    echo "Telemetry: metrics"
    echo "Message: Pipeline should not be configured but it has!"
    exit 1
  fi

  # Pipeline loadbalancing exporter should be configured - receiver
  collectorDeploymentReceiverPipelineExporterLoadbalancingConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentReceiverName}'")).spec.config' | yq '.service.pipelines.traces.exporters[]' | yq 'select("loadbalancing")')
  if [[ $collectorDeploymentReceiverPipelineExporterLoadbalancingConfigCheck == "" ]]; then
    echo "Mode: receiver"
    echo "Component: loadbalancingexporter"
    echo "Telemetry: traces"
    echo "Message: Pipeline should be configured but it has not!"
    exit 1
  fi

  # Pipeline otlp exporter for opsteam should be configured - sampler
  collectorDeploymentSamplerOpsteamPipelineExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentSamplerName}'")).spec.config' | yq '.service.pipelines.traces/opsteam.exporters[]' | yq 'select("otlp/opsteam")')
  if [[ $collectorDeploymentSamplerOpsteamPipelineExporterOtlpConfigCheck == "" ]]; then
    echo "Mode: sampler"
    echo "Team: opsteam"
    echo "Component: otlpexporter"
    echo "Telemetry: traces"
    echo "Message: Pipeline should be configured but it has not!"
    exit 1
  fi

  # Pipeline filter processor for devteam1 should be configured - sampler
  collectorDeploymentSamplerDevteam1PipelineProcessorFilterConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentSamplerName}'")).spec.config' | yq '.service.pipelines.traces/devteam1.processors[]' | yq 'select("filter/devteam1")')
  if [[ $collectorDeploymentSamplerDevteam1PipelineProcessorFilterConfigCheck == "" ]]; then
    echo "Mode: sampler"
    echo "Team: devteam1"
    echo "Component: filterprocessing"
    echo "Telemetry: traces"
    echo "Message: Pipeline should be configured but it has not!"
    exit 1
  fi

  # Pipeline otlp exporter for devteam1 should be configured - sampler
  collectorDeploymentSamplerDevteam1PipelineExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentSamplerName}'")).spec.config' | yq '.service.pipelines.traces/devteam1.exporters[]' | yq 'select("otlp/devteam1")')
  if [[ $collectorDeploymentSamplerDevteam1PipelineExporterOtlpConfigCheck == "" ]]; then
    echo "Mode: sampler"
    echo "Team: devteam1"
    echo "Component: otlpexporter"
    echo "Telemetry: traces"
    echo "Message: Pipeline should be configured but it has not!"
    exit 1
  fi

  # Pipeline filter processor for devteam2 should not be configured - sampler
  collectorDeploymentSamplerDevteam2PipelineProcessorFilterConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentSamplerName}'")).spec.config' | yq '.service.pipelines.traces/devteam2.processors[]' | yq 'select("filter/devteam2")')
  if [[ $collectorDeploymentSamplerDevteam2PipelineProcessorFilterConfigCheck != "" ]]; then
    echo "Mode: sampler"
    echo "Team: devteam2"
    echo "Component: filterprocessing"
    echo "Telemetry: traces"
    echo "Message: Pipeline should not be configured but it has!"
    exit 1
  fi

  # Pipeline otlp exporter for devteam2 should not be configured - sampler
  collectorDeploymentSamplerDevteam2PipelineExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorDeploymentSamplerName}'")).spec.config' | yq '.service.pipelines.traces/devteam2.exporters[]' | yq 'select("otlp/devteam2")')
  if [[ $collectorDeploymentSamplerDevteam2PipelineExporterOtlpConfigCheck != "" ]]; then
    echo "Mode: sampler"
    echo "Team: devteam2"
    echo "Component: otlpexporter"
    echo "Telemetry: traces"
    echo "Message: Pipeline should not be configured but it has!"
    exit 1
  fi

  echo "Message: Tests for collector pipelines are run successfully."
  echo "---"

  ### Statefulset
  echo ""
  echo "###################################"
  echo "### Collector type: Statefulset ###"
  echo "###################################"

  collectorStatefulsetName="${otelcollectors[name]}-sts"
  secretStatefulsetOpsteamName="${otelcollectors[name]}-sts-opsteam"
  secretStatefulsetDevteam1Name="${otelcollectors[name]}-sts-devteam1"
  secretStatefulsetDevteam2Name="${otelcollectors[name]}-sts-devteam2"

  ## Secret creation
  echo -e "\n---"
  echo "Message: Testing secret creation..."

  # Secret for opsteam should be created
  secretStatefulsetOpsteamCheck=$(echo "$helmTemplate" | yq 'select((.kind == "Secret") and (.metadata.name == "'${secretStatefulsetOpsteamName}'")).metadata.name')
  if [[ $secretStatefulsetOpsteamCheck != $secretStatefulsetOpsteamName ]]; then
    echo "Team: opsteam"
    echo "Message: Secret should have been created but it has not!"
    exit 1
  fi

  # Secret for devteam1 should be created
  secretStatefulsetDevteam1Check=$(echo "$helmTemplate" | yq 'select((.kind == "Secret") and (.metadata.name == "'${secretStatefulsetDevteam1Name}'")).metadata.name')
  if [[ $secretStatefulsetDevteam1Check != $secretStatefulsetDevteam1Name ]]; then
    echo "Team: devteam1"
    echo "Message: Secret should have been created but it has not!"
    exit 1
  fi

  # Secret for devteam2 should not be created
  secretStatefulsetDevteam2Check=$(echo "$helmTemplate" | yq 'select((.kind == "Secret") and (.metadata.name == "'${secretStatefulsetDevteam2Name}'")).metadata.name')
  if [[ $secretStatefulsetDevteam2Check != "" ]]; then
    echo "Team: devteam2"
    echo "Message: Secret should not have been created but it has!"
    exit 1
  fi

  echo "Message: Tests for secret creation are run successfully."
  echo "---"

  ## Collector secret environment variables assignment
  echo -e "\n---"
  echo "Message: Testing collector secret environment variables assignment..."

  # Secret for opsteam should be assigned
  collectorStatefulsetOpsteamEnvVarCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorStatefulsetName}'")).spec.env[] | select(.valueFrom.secretKeyRef.name == "'${secretStatefulsetOpsteamName}'").valueFrom.secretKeyRef.name')
  if [[ $collectorStatefulsetOpsteamEnvVarCheck != $secretStatefulsetOpsteamName ]]; then
    echo "Team: opsteam"
    echo "Message: Environment variable should have been assigned but it has not!"
    exit 1
  fi

  # Secret for devteam1 should be assigned
  collectorStatefulsetDevteam1EnvVarCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorStatefulsetName}'")).spec.env[] | select(.valueFrom.secretKeyRef.name == "'${secretStatefulsetDevteam1Name}'").valueFrom.secretKeyRef.name')
  if [[ $collectorStatefulsetDevteam1EnvVarCheck != $secretStatefulsetDevteam1Name ]]; then
    echo "Team: devteam1"
    echo "Message: Environment variable should have been assigned but it has not!"
    exit 1
  fi

  # Secret for devteam2 should not be assigned
  collectorStatefulsetDevteam2EnvVarCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorStatefulsetName}'")).spec.env[] | select(.valueFrom.secretKeyRef.name == "'${secretStatefulsetDevteam2Name}'").valueFrom.secretKeyRef.name')
  if [[ $collectorStatefulsetDevteam2EnvVarCheck != "" ]]; then
    echo "Team: devteam2"
    echo "Message: Environment variable should not have been assigned but it has!"
    exit 1
  fi

  echo "Message: Tests for secret assignments as environment variables are run successfully."
  echo "---"

  ## Collector processors configuration
  echo -e "\n---"
  echo "Message: Testing collector processors configuration..."

  # Filter processor for devteam1 should be configured
  collectorStatefulsetDevteam1ProcessorFilterConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorStatefulsetName}'")).spec.config' | yq '.processors.filter/devteam1')
  if [[ $collectorStatefulsetDevteam1ProcessorFilterConfigCheck == "" ]]; then
    echo "Team: devteam1"
    echo "Component: filterprocessor"
    echo "Processor should be configured but it has not!"
    exit 1
  fi

  # Filter processor for devteam2 should not be configured
  collectorStatefulsetDevteam2ProcessorFilterConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorStatefulsetName}'")).spec.config' | yq '.processors.filter/devteam2')
  if [[ $collectorStatefulsetDevteam2ProcessorFilterConfigCheck != "null" ]]; then
    echo "Team: devteam2"
    echo "Component: filterprocessor"
    echo "Processor should not be configured but it has!"
    exit 1
  fi

  echo "Message: Tests for collector processors are run successfully."
  echo "---"

  ## Collector exporter configuration
  echo -e "\n---"
  echo "Message: Testing collector exporter configuration..."

  # OTLP exporter for opsteam should be configured
  collectorStatefulsetOpsteamExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorStatefulsetName}'")).spec.config' | yq '.exporters.otlp/opsteam')
  if [[ $collectorStatefulsetOpsteamExporterOtlpConfigCheck == "" ]]; then
    echo "Team: opsteam"
    echo "Component: otlpexporter"
    echo "Message: Exporter should be configured but it has not!"
    exit 1
  fi

  # OTLP exporter for devteam1 should be configured
  collectorStatefulsetDevteam1ExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorStatefulsetName}'")).spec.config' | yq '.exporters.otlp/devteam1')
  if [[ $collectorStatefulsetDevteam1ExporterOtlpConfigCheck == "" ]]; then
    echo "Team: devteam1"
    echo "Component: otlpexporter"
    echo "Message: Exporter should be configured but it has not!"
    exit 1
  fi

  # OTLP exporter for devteam2 should not be configured
  collectorStatefulsetDevteam2ExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorStatefulsetName}'")).spec.config' | yq '.exporters.otlp/devteam2')
  if [[ $collectorStatefulsetDevteam2ExporterOtlpConfigCheck != "null" ]]; then
    echo "Team: devteam2"
    echo "Component: otlpexporter"
    echo "Message: Exporter should not be configured but it has!"
    exit 1
  fi

  echo "Message: Tests for collector exporters are run successfully."
  echo "---"

  ## Collector pipeline configuration
  echo -e "\n---"
  echo "Message: Testing collector pipeline configuration..."

  # Pipeline otlp exporter for opsteam should be configured
  collectorStatefulsetOpsteamPipelineExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorStatefulsetName}'")).spec.config' | yq '.service.pipelines.metrics/opsteam.exporters[]' | yq 'select("otlp/opsteam")')
  if [[ $collectorStatefulsetOpsteamPipelineExporterOtlpConfigCheck == "" ]]; then
    echo "Team: opsteam"
    echo "Component: otlpexporter"
    echo "Telemetry: metrics"
    echo "Message: Pipeline should be configured but it has not!"
    exit 1
  fi

  # Pipeline filter processor for devteam1 should be configured
  collectorStatefulsetDevteam1PipelineProcessorFilterConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorStatefulsetName}'")).spec.config' | yq '.service.pipelines.metrics/devteam1.processors[]' | yq 'select("filter/devteam1")')
  if [[ $collectorStatefulsetDevteam1PipelineProcessorFilterConfigCheck == "" ]]; then
    echo "Team: devteam1"
    echo "Component: filterprocessor"
    echo "Telemetry: metrics"
    echo "Message: Pipeline should be configured but it has not!"
    exit 1
  fi

  # Pipeline otlp exporter for devteam1 should be configured
  collectorStatefulsetDevteam1PipelineExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorStatefulsetName}'")).spec.config' | yq '.service.pipelines.metrics/devteam1.exporters[]' | yq 'select("otlp/devteam1")')
  if [[ $collectorStatefulsetDevteam1PipelineExporterOtlpConfigCheck == "" ]]; then
    echo "Team: devteam1"
    echo "Component: otlpexporter"
    echo "Telemetry: metrics"
    echo "Message: Pipeline should be configured but it has not!"
    exit 1
  fi

  # Pipeline filter processor for devteam2 should be configured
  collectorStatefulsetDevteam2PipelineProcessorFilterConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorStatefulsetName}'")).spec.config' | yq '.service.pipelines.metrics/devteam2.processors[]' | yq 'select("filter/devteam2")')
  if [[ $collectorStatefulsetDevteam2PipelineProcessorFilterConfigCheck != "" ]]; then
    echo "Team: devteam2"
    echo "Component: filterprocessor"
    echo "Telemetry: metrics"
    echo "Message: Pipeline should be configured but it has not!"
    exit 1
  fi

  # Pipeline otlp exporter for devteam2 should not be configured
  collectorStatefulsetDevteam2PipelineExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorStatefulsetName}'")).spec.config' | yq '.service.pipelines.metrics/devteam2.exporters[]' | yq 'select("otlp/devteam2")')
  if [[ $collectorStatefulsetDevteam2PipelineExporterOtlpConfigCheck != "" ]]; then
    echo "Team: devteam2"
    echo "Component: otlpexporter"
    echo "Telemetry: metrics"
    echo "Message: Pipeline should not be configured but it has!"
    exit 1
  fi

  echo "Message: Tests for collector pipelines are run successfully."
  echo "---"

  ### Singleton
  echo ""
  echo "#################################"
  echo "### Collector type: Singleton ###"
  echo "#################################"

  collectorSingletonName="${otelcollectors[name]}-sng"
  secretSingletonOpsteamName="${otelcollectors[name]}-sng-opsteam"
  secretSingletonDevteam1Name="${otelcollectors[name]}-sng-devteam1"
  secretSingletonDevteam2Name="${otelcollectors[name]}-sng-devteam2"

  ## Secret creation
  echo -e "\n---"
  echo "Message: Testing secret creation..."

  # Secret for opsteam should be created
  secretSingletonOpsteamCheck=$(echo "$helmTemplate" | yq 'select((.kind == "Secret") and (.metadata.name == "'${secretSingletonOpsteamName}'")).metadata.name')
  if [[ $secretSingletonOpsteamCheck != $secretSingletonOpsteamName ]]; then
    echo "Team: opsteam"
    echo "Message: Secret should have been created but it has not!"
    exit 1
  fi

  # Secret for devteam1 should not be created
  secretSingletonDevteam1Check=$(echo "$helmTemplate" | yq 'select((.kind == "Secret") and (.metadata.name == "'${secretSingletonDevteam1Name}'")).metadata.name')
  if [[ $secretSingletonDevteam1Check != "" ]]; then
    echo "Team: devteam1"
    echo "Message: Secret should not have been created but it has!"
    exit 1
  fi

  # Secret for devteam2 should not be created
  secretSingletonDevteam2Check=$(echo "$helmTemplate" | yq 'select((.kind == "Secret") and (.metadata.name == "'${secretSingletonDevteam2Name}'")).metadata.name')
  if [[ $secretSingletonDevteam2Check != "" ]]; then
    echo "Team: devteam2"
    echo "Message: Secret should not have been created but it has!"
    exit 1
  fi

  echo "Message: Tests for secret creation are run successfully."
  echo "---"

  ## Collector secret environment variables assignment
  echo -e "\n---"
  echo "Message: Testing collector secret environment variables assignment..."

  # Secret for opsteam should be assigned
  collectorSingletonOpsteamEnvVarCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorSingletonName}'")).spec.env[] | select(.valueFrom.secretKeyRef.name == "'${secretSingletonOpsteamName}'").valueFrom.secretKeyRef.name')
  if [[ $collectorSingletonOpsteamEnvVarCheck != $secretSingletonOpsteamName ]]; then
    echo "Team: opsteam"
    echo "Message: Environment variable should have been assigned but it has not!"
    exit 1
  fi

  # Secret for devteam1 should not be assigned
  collectorSingletonDevteam1EnvVarCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorSingletonName}'")).spec.env[] | select(.valueFrom.secretKeyRef.name == "'${secretSingletonDevteam1Name}'").valueFrom.secretKeyRef.name')
  if [[ $collectorSingletonDevteam1EnvVarCheck != "" ]]; then
    echo "Team: devteam1"
    echo "Message: Environment variable should not have been assigned but it has!"
    exit 1
  fi

  # Secret for devteam2 should not be assigned
  collectorSingletonDevteam2EnvVarCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorSingletonName}'")).spec.env[] | select(.valueFrom.secretKeyRef.name == "'${secretSingletonDevteam2Name}'").valueFrom.secretKeyRef.name')
  if [[ $collectorSingletonDevteam2EnvVarCheck != "" ]]; then
    echo "Team: devteam2"
    echo "Message: Environment variable should not have been assigned but it has!"
    exit 1
  fi

  echo "Message: Tests for secret assignments as environment variables are run successfully."
  echo "---"

  ## Collector processors configuration
  echo -e "\n---"
  echo "Message: Testing collector processors configuration..."

  # Filter processor for devteam1 should not be configured
  collectorSingletonDevteam1ProcessorFilterConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorSingletonName}'")).spec.config' | yq '.processors.filter/devteam1')
  if [[ $collectorSingletonDevteam1ProcessorFilterConfigCheck != "null" ]]; then
    echo "Team: devteam1"
    echo "Component: filterprocessor"
    echo "Processor should be configured but it has not!"
    exit 1
  fi

  # Filter processor for devteam2 should not be configured
  collectorSingletonDevteam2ProcessorFilterConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorSingletonName}'")).spec.config' | yq '.processors.filter/devteam2')
  if [[ $collectorSingletonDevteam2ProcessorFilterConfigCheck != "null" ]]; then
    echo "Team: devteam2"
    echo "Component: filterprocessor"
    echo "Processor should not be configured but it has!"
    exit 1
  fi

  echo "Message: Tests for collector processors are run successfully."
  echo "---"

  ## Collector exporter configuration
  echo -e "\n---"
  echo "Message: Testing collector exporter configuration..."

  # OTLP exporter for opsteam should be configured
  collectorSingletonOpsteamExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorSingletonName}'")).spec.config' | yq '.exporters.otlp/opsteam')
  if [[ $collectorSingletonOpsteamExporterOtlpConfigCheck == "" && $collectorSingletonOpsteamExporterOtlpConfigCheck != "null" ]]; then
    echo "Team: opsteam"
    echo "Component: otlpexporter"
    echo "Message: Exporter should be configured but it has not!"
    exit 1
  fi

  # OTLP exporter for devteam1 should not be configured
  collectorSingletonDevteam1ExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorSingletonName}'")).spec.config' | yq '.exporters.otlp/devteam1')
  if [[ $collectorSingletonDevteam1ExporterOtlpConfigCheck != "null" ]]; then
    echo "Team: devteam1"
    echo "Component: otlpexporter"
    echo "Message: Exporter should not be configured but it has!"
    exit 1
  fi

  # OTLP exporter for devteam2 should not be configured
  collectorSingletonDevteam2ExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorSingletonName}'")).spec.config' | yq '.exporters.otlp/devteam2')
  if [[ $collectorSingletonDevteam2ExporterOtlpConfigCheck != "null" ]]; then
    echo "Team: devteam2"
    echo "Component: otlpexporter"
    echo "Message: Exporter should not be configured but it has!"
    exit 1
  fi

  echo "Message: Tests for collector exporters are run successfully."
  echo "---"

  ## Collector pipeline configuration
  echo -e "\n---"
  echo "Message: Testing collector pipeline configuration..."

  # Pipeline otlp exporter for opsteam should be configured
  collectorSingletonOpsteamPipelineExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorSingletonName}'")).spec.config' | yq '.service.pipelines.logs/opsteam.exporters[]' | yq 'select("otlp/opsteam")')
  if [[ $collectorSingletonOpsteamPipelineExporterOtlpConfigCheck == "" ]]; then
    echo "Team: opsteam"
    echo "Component: otlpexporter"
    echo "Telemetry: logs"
    echo "Message: Pipeline should be configured but it has not!"
    exit 1
  fi

  # Pipeline filter processor for devteam1 should not be configured
  collectorSingletonDevteam1PipelineProcessorFilterConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorSingletonName}'")).spec.config' | yq '.service.pipelines.logs/devteam1.processors[]' | yq 'select("filter/devteam1")')
  if [[ $collectorSingletonDevteam1PipelineProcessorFilterConfigCheck != "" ]]; then
    echo "Team: devteam1"
    echo "Component: filterprocessor"
    echo "Telemetry: logs"
    echo "Message: Pipeline should not be configured but it has!"
    exit 1
  fi

  # Pipeline otlp exporter for devteam1 should not be configured
  collectorSingletonDevteam1PipelineExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorSingletonName}'")).spec.config' | yq '.service.pipelines.logs/devteam1.exporters[]' | yq 'select("otlp/devteam1")')
  if [[ $collectorSingletonDevteam1PipelineExporterOtlpConfigCheck != "" ]]; then
    echo "Team: devteam1"
    echo "Component: otlpexporter"
    echo "Telemetry: logs"
    echo "Message: Pipeline should not be configured but it has!"
    exit 1
  fi

  # Pipeline filter processor for devteam2 should not be configured
  collectorSingletonDevteam2PipelineProcessorFilterConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorSingletonName}'")).spec.config' | yq '.service.pipelines.logs/devteam2.processors[]' | yq 'select("filter/devteam2")')
  if [[ $collectorSingletonDevteam2PipelineProcessorFilterConfigCheck != "" ]]; then
    echo "Team: devteam2"
    echo "Component: filterprocessor"
    echo "Telemetry: logs"
    echo "Message: Pipeline should not be configured but it has!"
    exit 1
  fi

  # Pipeline otlp exporter for devteam2 should not be configured
  collectorSingletonDevteam2PipelineExporterOtlpConfigCheck=$(echo "$helmTemplate" | yq 'select((.kind == "OpenTelemetryCollector") and (.metadata.name == "'${collectorSingletonName}'")).spec.config' | yq '.service.pipelines.logs/devteam2.exporters[]' | yq 'select("otlp/devteam2")')
  if [[ $collectorSingletonDevteam2PipelineExporterOtlpConfigCheck != "" ]]; then
    echo "Team: devteam2"
    echo "Component: otlpexporter"
    echo "Telemetry: logs"
    echo "Message: Pipeline should not be configured but it has!"
    exit 1
  fi

  echo "Message: Tests for collector pipelines are run successfully."
  echo "---"
}

### Case Global - Complete successful deployment
if [[ $case == "global" ]]; then
  helmTemplate=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=true \
    --set global.newrelic.endpoint="otlp.nr-data.net:4317" \
    --set global.newrelic.teams.opsteam.licenseKey.value="value_ops" \
    --set global.newrelic.teams.devteam1.licenseKey.value="value_dev1" \
    --set global.newrelic.teams.devteam1.namespaces[0]="devteam1" \
    --set global.newrelic.teams.devteam2.licenseKey.value="value_dev2" \
    --set global.newrelic.teams.devteam2.namespaces[0]="devteam2" \
    --set global.newrelic.teams.devteam2.ignore=true \
    "../../charts/collectors" | yq)

  runTests "$helmTemplate"
fi

### Case Individual - Complete successful deployment
if [[ $case == "individual" ]]; then
  helmTemplate=$(helm template ${otelcollectors[name]} \
    --create-namespace \
    --namespace ${otelcollectors[namespace]} \
    --set clusterName=$clusterName \
    --set global.newrelic.enabled=false \
    --set daemonset.newrelic.teams.opsteam.endpoint="otlp.nr-data.net:4317" \
    --set daemonset.newrelic.teams.opsteam.licenseKey.value="value_ops" \
    --set daemonset.newrelic.teams.devteam1.endpoint="otlp.nr-data.net:4317" \
    --set daemonset.newrelic.teams.devteam1.licenseKey.value="value_dev1" \
    --set daemonset.newrelic.teams.devteam1.namespaces[0]="devteam1" \
    --set daemonset.newrelic.teams.devteam2.endpoint="otlp.nr-data.net:4317" \
    --set daemonset.newrelic.teams.devteam2.licenseKey.value="value_dev2" \
    --set daemonset.newrelic.teams.devteam2.namespaces[0]="devteam2" \
    --set daemonset.newrelic.teams.devteam2.ignore=true \
    --set deployment.newrelic.teams.opsteam.endpoint="otlp.nr-data.net:4317" \
    --set deployment.newrelic.teams.opsteam.licenseKey.value="value_ops" \
    --set deployment.newrelic.teams.devteam1.endpoint="otlp.nr-data.net:4317" \
    --set deployment.newrelic.teams.devteam1.licenseKey.value="value_dev1" \
    --set deployment.newrelic.teams.devteam1.namespaces[0]="devteam1" \
    --set deployment.newrelic.teams.devteam2.endpoint="otlp.nr-data.net:4317" \
    --set deployment.newrelic.teams.devteam2.licenseKey.value="value_dev2" \
    --set deployment.newrelic.teams.devteam2.namespaces[0]="devteam2" \
    --set deployment.newrelic.teams.devteam2.ignore=true \
    --set statefulset.newrelic.teams.opsteam.endpoint="otlp.nr-data.net:4317" \
    --set statefulset.newrelic.teams.opsteam.licenseKey.value="value_ops" \
    --set statefulset.newrelic.teams.devteam1.endpoint="otlp.nr-data.net:4317" \
    --set statefulset.newrelic.teams.devteam1.licenseKey.value="value_dev1" \
    --set statefulset.newrelic.teams.devteam1.namespaces[0]="devteam1" \
    --set statefulset.newrelic.teams.devteam2.endpoint="otlp.nr-data.net:4317" \
    --set statefulset.newrelic.teams.devteam2.licenseKey.value="value_dev2" \
    --set statefulset.newrelic.teams.devteam2.namespaces[0]="devteam2" \
    --set statefulset.newrelic.teams.devteam2.ignore=true \
    --set singleton.newrelic.teams.opsteam.endpoint="otlp.nr-data.net:4317" \
    --set singleton.newrelic.teams.opsteam.licenseKey.value="value_ops" \
    --set singleton.newrelic.teams.devteam1.endpoint="otlp.nr-data.net:4317" \
    --set singleton.newrelic.teams.devteam1.licenseKey.value="value_dev1" \
    --set singleton.newrelic.teams.devteam1.namespaces[0]="devteam1" \
    --set singleton.newrelic.teams.devteam2.endpoint="otlp.nr-data.net:4317" \
    --set singleton.newrelic.teams.devteam2.licenseKey.value="value_dev2" \
    --set singleton.newrelic.teams.devteam2.namespaces[0]="devteam2" \
    --set singleton.newrelic.teams.devteam2.ignore=true \
    "../../charts/collectors" | yq)

  runTests "$helmTemplate"
fi
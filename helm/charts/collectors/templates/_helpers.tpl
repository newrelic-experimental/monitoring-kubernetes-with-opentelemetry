{{/*
Expand the name of the chart.
*/}}
{{- define "nrotel.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Set image tag for deployment collectors.
*/}}
{{- define "nrotel.deploymentImageTag" -}}
{{- if .Values.deployment.image.tag -}}
{{- printf "%s" .Values.deployment.image.tag -}}
{{- else -}}
{{- printf "%s" .Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{/*
Set image tag for daemonset collectors.
*/}}
{{- define "nrotel.daemonsetImageTag" -}}
{{- if .Values.daemonset.image.tag -}}
{{- printf "%s" .Values.daemonset.image.tag -}}
{{- else -}}
{{- printf "%s" .Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{/*
Set image tag for statefulset collectors.
*/}}
{{- define "nrotel.statefulsetImageTag" -}}
{{- if .Values.statefulset.image.tag -}}
{{- printf "%s" .Values.statefulset.image.tag -}}
{{- else -}}
{{- printf "%s" .Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{/*
Set image tag for singleton collectors.
*/}}
{{- define "nrotel.singletonImageTag" -}}
{{- if .Values.singleton.image.tag -}}
{{- printf "%s" .Values.singleton.image.tag -}}
{{- else -}}
{{- printf "%s" .Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{/*
Set name for deployment collectors.
*/}}
{{- define "nrotel.deploymentName" -}}
{{- printf "%s-%s" (include "nrotel.name" .) "dep" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "nrotel.deploymentNameReceiver" -}}
{{- printf "%s-%s" (include "nrotel.deploymentName" .) "rec" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "nrotel.deploymentNameSampler" -}}
{{- printf "%s-%s" (include "nrotel.deploymentName" .) "smp" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "nrotel.headlessServiceNameSampler" -}}
{{- printf "%s-%s.%s.%s" (include "nrotel.deploymentNameSampler" .) "collector-headless" .Release.Namespace "svc.cluster.local" | trimSuffix "-" -}}
{{- end -}}

{{/*
Set name for target allocator.
*/}}
{{- define "nrotel.targetAllocatorName" -}}
{{- printf "%s-%s" (include "nrotel.name" .) "sts-targetallocator" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Set name for daemonset collectors.
*/}}
{{- define "nrotel.daemonsetName" -}}
{{- printf "%s-%s" (include "nrotel.name" .) "ds" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Set name for statefulset collectors.
*/}}
{{- define "nrotel.statefulsetName" -}}
{{- printf "%s-%s" (include "nrotel.name" .) "sts" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Set name for singleton collector.
*/}}
{{- define "nrotel.singletonName" -}}
{{- printf "%s-%s" (include "nrotel.name" .) "sng" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Set name for node-exporter service discovery.
*/}}
{{- define "nrotel.nodeExporterServiceName" -}}
{{- if .Values.statefulset.prometheus.nodeExporter.serviceNameRef -}}
{{- printf "%s" .Values.statefulset.prometheus.nodeExporter.serviceNameRef | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" (include "nrotel.name" .) "prometheus-node-exporter" | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Set name for kube-state-metrics service discovery.
*/}}
{{- define "nrotel.kubeStateMetricsServiceName" -}}
{{- if .Values.statefulset.prometheus.kubeStateMetrics.serviceNameRef -}}
{{- printf "%s" .Values.statefulset.prometheus.kubeStateMetrics.serviceNameRef | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" (include "nrotel.name" .) "kube-state-metrics" | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

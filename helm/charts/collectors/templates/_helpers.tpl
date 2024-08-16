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

{{- define "deploymentTeamConfig" -}}
{{/*
  Depending on which config setting is used (global.enabled), create one "teams"
  variable to loop over.
*/}}
{{- $teams := dict -}}
{{- if .Values.global.newrelic.enabled -}}
  {{- $teams = .Values.global.newrelic.teams -}}
  {{/*
    "global" setting does not have the endpoint field on every team info. In order to
    loop without if/else cases, add the endpoint to every team info.
  */}}
  {{- range $teamName, $teamInfo := $teams -}}
    {{- $_ := set $teamInfo "endpoint" $.Values.global.newrelic.endpoint -}}
  {{- end -}}
{{- else -}}
  {{- $teams = .Values.deployment.newrelic.teams -}}
{{- end -}}

{{/*
  Set the namespaced filtering conditions only if
  - team is not marked as "ignore"
  - team has namespaces defined
*/}}
{{- range $teamName, $teamInfo := $teams -}}
  {{- if and (ne $teamInfo.ignore true) (ne (len $teamInfo.namespaces) 0) -}}

    {{- $conditionForK8sNamespaceName := "" -}}
    {{- range $index, $namespace := $teamInfo.namespaces -}}
      {{- if eq $index 0 -}}
        {{- $conditionForK8sNamespaceName = printf "not (IsMatch(resource.attributes[\"k8s.namespace.name\"], \"%s\") or IsMatch(attributes[\"k8s.namespace.name\"], \"%s\"))" $namespace $namespace -}}
      {{- else -}}
        {{- $conditionForK8sNamespaceName = printf "%s and not (IsMatch(resource.attributes[\"k8s.namespace.name\"], \"%s\") or IsMatch(resource.attributes[\"k8s.namespace.name\"], \"%s\"))" $conditionForK8sNamespaceName $namespace $namespace -}}
      {{- end -}}
    {{- end -}}

    {{- $_ := set $teamInfo "filter" $conditionForK8sNamespaceName -}}
  {{- end }}
{{- end }}

{{- $teams | toYaml -}}
{{- end -}}

{{- define "daemonsetTeamConfig" -}}
{{/*
  Depending on which config setting is used (global.enabled), create one "teams"
  variable to loop over.
*/}}
{{- $teams := dict -}}
{{- if .Values.global.newrelic.enabled -}}
  {{- $teams = .Values.global.newrelic.teams -}}
  {{/*
    "global" setting does not have the endpoint field on every team info. In order to
    loop without if/else cases, add the endpoint to every team info.
  */}}
  {{- range $teamName, $teamInfo := $teams -}}
    {{- $_ := set $teamInfo "endpoint" $.Values.global.newrelic.endpoint -}}
  {{- end -}}
{{- else -}}
  {{- $teams = .Values.daemonset.newrelic.teams -}}
{{- end -}}

{{/*
  Set the namespaced filtering conditions only if
  - team is not marked as "ignore"
  - team has namespaces defined
*/}}
{{- range $teamName, $teamInfo := $teams -}}
  {{- if and (ne $teamInfo.ignore true) (ne (len $teamInfo.namespaces) 0) -}}

    {{- $conditionForK8sNamespaceName := "" -}}
    {{- range $index, $namespace := $teamInfo.namespaces -}}
      {{- if eq $index 0 -}}
        {{- $conditionForK8sNamespaceName = printf "not (IsMatch(resource.attributes[\"k8s.namespace.name\"], \"%s\") or IsMatch(attributes[\"k8s.namespace.name\"], \"%s\"))" $namespace $namespace -}}
      {{- else -}}
        {{- $conditionForK8sNamespaceName = printf "%s and not (IsMatch(resource.attributes[\"k8s.namespace.name\"], \"%s\") or IsMatch(resource.attributes[\"k8s.namespace.name\"], \"%s\"))" $conditionForK8sNamespaceName $namespace $namespace -}}
      {{- end -}}
    {{- end -}}

    {{- $_ := set $teamInfo "filter" $conditionForK8sNamespaceName -}}
  {{- end }}
{{- end }}

{{- $teams | toYaml -}}
{{- end -}}

{{- define "statefulsetTeamConfig" -}}
{{/*
  Depending on which config setting is used (global.enabled), create one "teams"
  variable to loop over.
*/}}
{{- $teams := dict -}}
{{- if .Values.global.newrelic.enabled -}}
  {{- $teams = .Values.global.newrelic.teams -}}
  {{/*
    "global" setting does not have the endpoint field on every team info. In order to
    loop without if/else cases, add the endpoint to every team info.
  */}}
  {{- range $teamName, $teamInfo := $teams -}}
    {{- $_ := set $teamInfo "endpoint" $.Values.global.newrelic.endpoint -}}
  {{- end -}}
{{- else -}}
  {{- $teams = .Values.statefulset.newrelic.teams -}}
{{- end -}}

{{/*
  Set the namespaced filtering conditions only if
  - team is not marked as "ignore"
  - team has namespaces defined
*/}}
{{- range $teamName, $teamInfo := $teams -}}
  {{- if and (ne $teamInfo.ignore true) (ne (len $teamInfo.namespaces) 0) -}}
    {{/*
      The scrape jobs
      - "kubernetes-nodes-cadvisor"
      - "kubernetes-kube-state-metrics" 
      have the relevant namespace info under the "namespace" attribute. Set the namespace
      filter conditions.
    */}}
    {{- $conditionForNamespace := "" -}}
    {{- range $index, $namespace := $teamInfo.namespaces -}}
      {{- if eq $index 0 -}}
        {{- $conditionForNamespace = printf "not (IsMatch(attributes[\"namespace\"], \"%s\"))" $namespace -}}
      {{- else -}}
        {{- $conditionForNamespace = printf "%s and not (IsMatch(attributes[\"namespace\"], \"%s\"))" $conditionForNamespace $namespace -}}
      {{- end -}}
    {{- end -}}

    {{/*
      Now, merge these conditions with the scrape job names. Scrape job names are added into
      the "service.name" attribute.
    */}}
    {{- $baseFilterConditionForNamespace := "" -}}
    {{- $scrapeJobsForNamespace := list "kubernetes-nodes-cadvisor" "kubernetes-kube-state-metrics" -}}
    {{- range $index, $scrapeJobName := $scrapeJobsForNamespace -}}
      {{- if eq $index 0 -}}
        {{- $baseFilterConditionForNamespace = printf "(resource.attributes[\"service.name\"] != \"%s\" or (%s))" $scrapeJobName $conditionForNamespace -}}
      {{- else -}}
        {{- $baseFilterConditionForNamespace = printf "%s and (resource.attributes[\"service.name\"] != \"%s\" or (%s))" $baseFilterConditionForNamespace $scrapeJobName $conditionForNamespace -}}
      {{- end -}}
    {{- end -}}

    {{/*
      The scrape jobs
      - "kubernetes-apiservers"
      - "kubernetes-coredns"
      - "kubernetes-node-exporter"
      - "kubernetes-service-endpoints"
      - and all from the "extraScrapeConfigs"
      have the relevant namespace info under the "k8s.namespace.name" attribute. Set the namespace
      filter conditions.
    */}}
    {{- $conditionForK8sNamespaceName := "" -}}
    {{- range $index, $namespace := $teamInfo.namespaces -}}
      {{- if eq $index 0 -}}
        {{- $conditionForK8sNamespaceName = printf "not (IsMatch(resource.attributes[\"k8s.namespace.name\"], \"%s\") or IsMatch(attributes[\"k8s.namespace.name\"], \"%s\"))" $namespace $namespace -}}
      {{- else -}}
        {{- $conditionForK8sNamespaceName = printf "%s and not (IsMatch(resource.attributes[\"k8s.namespace.name\"], \"%s\") or IsMatch(resource.attributes[\"k8s.namespace.name\"], \"%s\"))" $conditionForK8sNamespaceName $namespace $namespace -}}
      {{- end -}}
    {{- end -}}

    {{/*
      Now, merge these conditions with the scrape job names. Scrape job names are added into
      the "service.name" attribute.
    */}}
    {{- $baseFilterConditionForK8sNamespaceName := "" -}}
    {{- $scrapeJobsForK8sNamespaceName := list "kubernetes-apiservers" "kubernetes-coredns" "kubernetes-node-exporter" "kubernetes-service-endpoints" -}}
    {{- range $index, $job := $.Values.statefulset.prometheus.extraScrapeJobs -}}
      {{- $scrapeJobsForK8sNamespaceName = append $scrapeJobsForK8sNamespaceName $job.job_name -}}
    {{- end -}}
    {{- range $index, $scrapeJobName := $scrapeJobsForK8sNamespaceName -}}
      {{- if eq $index 0 -}}
        {{- $baseFilterConditionForK8sNamespaceName = printf "(resource.attributes[\"service.name\"] != \"%s\" or (%s))" $scrapeJobName $conditionForK8sNamespaceName -}}
      {{- else -}}
        {{- $baseFilterConditionForK8sNamespaceName = printf "%s and (resource.attributes[\"service.name\"] != \"%s\" or (%s))" $baseFilterConditionForK8sNamespaceName $scrapeJobName $conditionForK8sNamespaceName -}}
      {{- end -}}
    {{- end -}}

    {{/*
      Merge both conditions for "namespace" and "k8s.namespace.name".
      Set the filter condition to the relevant team.
    */}}
    {{- $baseFilterCondition := printf "%s and %s" $baseFilterConditionForNamespace $baseFilterConditionForK8sNamespaceName -}}

    {{/*
      If it's the opsteam, add the "kubernetes-nodes" job.
    */}}
    {{- if eq $teamName "opsteam" -}}
      {{ $baseFilterCondition = printf "'%s and (resource.attributes[\"service.name\"] != \"kubernetes-nodes\")'" $baseFilterCondition -}}
    {{- else -}}
      {{ $baseFilterCondition = printf "'%s'" $baseFilterCondition -}}
    {{- end -}}
    {{- $_ := set $teamInfo "filter" $baseFilterCondition -}}
  {{- end }}
{{- end }}

{{- $teams | toYaml -}}
{{- end -}}

{{- define "singletonTeamConfig" -}}
{{/*
  Depending on which config setting is used (global.enabled), create one "teams"
  variable to loop over.
*/}}
{{- $teams := dict -}}
{{- if .Values.global.newrelic.enabled -}}
  {{- $teams = .Values.global.newrelic.teams -}}
  {{/*
    "global" setting does not have the endpoint field on every team info. In order to
    loop without if/else cases, add the endpoint to every team info.
  */}}
  {{- range $teamName, $teamInfo := $teams -}}
    {{- $_ := set $teamInfo "endpoint" $.Values.global.newrelic.endpoint -}}
  {{- end -}}
{{- else -}}
  {{- $teams = .Values.singleton.newrelic.teams -}}
{{- end -}}

{{/*
  Set the namespaced filtering conditions only if
  - team is not marked as "ignore"
  - team has namespaces defined
*/}}
{{- range $teamName, $teamInfo := $teams -}}
  {{- if and (ne $teamInfo.ignore true) (ne (len $teamInfo.namespaces) 0) -}}

    {{- $conditionForK8sNamespaceName := "" -}}
    {{- range $index, $namespace := $teamInfo.namespaces -}}
      {{- if eq $index 0 -}}
        {{- $conditionForK8sNamespaceName = printf "not (IsMatch(resource.attributes[\"k8s.namespace.name\"], \"%s\") or IsMatch(attributes[\"k8s.namespace.name\"], \"%s\"))" $namespace $namespace -}}
      {{- else -}}
        {{- $conditionForK8sNamespaceName = printf "%s and not (IsMatch(resource.attributes[\"k8s.namespace.name\"], \"%s\") or IsMatch(resource.attributes[\"k8s.namespace.name\"], \"%s\"))" $conditionForK8sNamespaceName $namespace $namespace -}}
      {{- end -}}
    {{- end -}}

    {{- $_ := set $teamInfo "filter" $conditionForK8sNamespaceName -}}
  {{- end }}
{{- end }}

{{- $teams | toYaml -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "rstmdb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rstmdb.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "rstmdb.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "rstmdb.labels" -}}
helm.sh/chart: {{ include "rstmdb.chart" . }}
{{ include "rstmdb.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "rstmdb.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rstmdb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "rstmdb.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "rstmdb.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the proper image name
*/}}
{{- define "rstmdb.image" -}}
{{- $registryName := .Values.image.registry -}}
{{- $repositoryName := .Values.image.repository -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion -}}
{{- if $registryName }}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag }}
{{- else }}
{{- printf "%s:%s" $repositoryName $tag }}
{{- end }}
{{- end }}

{{/*
Return the headless service name
*/}}
{{- define "rstmdb.headlessServiceName" -}}
{{- printf "%s-headless" (include "rstmdb.fullname" .) }}
{{- end }}

{{/*
Return the metrics service name
*/}}
{{- define "rstmdb.metricsServiceName" -}}
{{- printf "%s-metrics" (include "rstmdb.fullname" .) }}
{{- end }}

{{/*
Return the auth secret name
*/}}
{{- define "rstmdb.authSecretName" -}}
{{- if .Values.auth.existingSecret }}
{{- .Values.auth.existingSecret }}
{{- else }}
{{- printf "%s-auth" (include "rstmdb.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Return the TLS secret name
*/}}
{{- define "rstmdb.tlsSecretName" -}}
{{- if .Values.tls.existingSecret }}
{{- .Values.tls.existingSecret }}
{{- else }}
{{- printf "%s-tls" (include "rstmdb.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Return the configmap name
*/}}
{{- define "rstmdb.configMapName" -}}
{{- printf "%s-config" (include "rstmdb.fullname" .) }}
{{- end }}

{{/*
Return the studio fullname
*/}}
{{- define "rstmdb.studioFullname" -}}
{{- printf "%s-studio" (include "rstmdb.fullname" .) }}
{{- end }}

{{/*
Studio labels
*/}}
{{- define "rstmdb.studioLabels" -}}
helm.sh/chart: {{ include "rstmdb.chart" . }}
{{ include "rstmdb.studioSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Studio selector labels
*/}}
{{- define "rstmdb.studioSelectorLabels" -}}
app.kubernetes.io/name: {{ include "rstmdb.name" . }}-studio
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: studio
{{- end }}

{{/*
Return the studio image
*/}}
{{- define "rstmdb.studioImage" -}}
{{- $registryName := .Values.studio.image.registry -}}
{{- $repositoryName := .Values.studio.image.repository -}}
{{- $tag := .Values.studio.image.tag | default "latest" -}}
{{- if $registryName }}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag }}
{{- else }}
{{- printf "%s:%s" $repositoryName $tag }}
{{- end }}
{{- end }}

{{/*
Generate fsync_policy value
*/}}
{{- define "rstmdb.fsyncPolicy" -}}
{{- $policy := .Values.storage.fsyncPolicy -}}
{{- if eq $policy "every_write" -}}
every_write
{{- else if hasPrefix "every_n:" $policy -}}
{{ $policy }}
{{- else if hasPrefix "every_ms:" $policy -}}
{{ $policy }}
{{- else if eq $policy "never" -}}
never
{{- else -}}
every_write
{{- end }}
{{- end }}

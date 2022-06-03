{{/*
Expand the name of the chart.
*/}}
{{- define "gia.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gia.fullname" -}}
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
Create gia-api name.
*/}}
{{- define "gia.api.fullname" -}}
{{- printf "%s-%s" (include "gia.fullname" .) .Values.api.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create gia-front name.
*/}}
{{- define "gia.front.fullname" -}}
{{- printf "%s-%s" (include "gia.fullname" .) .Values.front.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create pgbackrest name.
*/}}
{{- define "gia.pgbackrest.fullname" -}}
{{- printf "%s-%s" (include "gia.fullname" .) .Values.pgbackrest.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gia.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gia.labels" -}}
helm.sh/chart: {{ include "gia.chart" .context }}
{{ include "gia.selectorLabels" (dict "context" .context "component" .component "name" .name) }}
app.kubernetes.io/managed-by: {{ .context.Release.Service }}
app.kubernetes.io/part-of: gia
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gia.selectorLabels" -}}
{{- if .name -}}
app.kubernetes.io/name: {{ include "gia.name" .context }}-{{ .name }}
{{ end -}}
app.kubernetes.io/instance: {{ .context.Release.Name }}
{{- if .component }}
app.kubernetes.io/component: {{ .component }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "gia.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "gia.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

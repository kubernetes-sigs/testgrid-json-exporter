{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "testgrid-exporter.name" -}}
{{- default .Chart.Name .Values.exporter.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "testgrid-exporter.fullname" -}}
{{- if .Values.exporter.fullnameOverride -}}
{{- .Values.exporter.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.exporter.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "testgrid-exporter.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Generate chart secret name
*/}}
{{- define "testgrid-exporter.secretName" -}}
{{ default (include "testgrid-exporter.fullname" .) .Values.exporter.existingSecret }}
{{- end -}}

{{/*
Service docker image
*/}}
{{- define "testgrid-exporter.image" -}}
{{- $tag := default .Chart.AppVersion .Values.exporter.overrideAppVersion -}}
{{- printf "%s/%s:%s" .Values.global.dockerRegistry .Values.exporter.image.name $tag -}}
{{- end -}}

{{/*
Image pull secrets
*/}}
{{- define "testgrid-exporter.imagePullSecrets" -}}
{{- if not (empty .Values.global.dockerRegistrySecret) -}}
imagePullSecrets:
  - name: {{ .Values.global.dockerRegistrySecret -}}
{{- end -}}
{{- end -}}

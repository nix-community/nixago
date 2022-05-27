package just

import "text/template"

#Config: {
	head: string | *""
	tasks: [string]: [...string]
}

data: #Config

tmpl:
"""
{{ .head -}}
{{ range $name, $tasks := .tasks -}}
    {{ $name -}}:
    {{ range $tasks -}}
        {{ . }}
    {{ end }}
{{- end }}
"""

rendered: template.Execute(tmpl, data)

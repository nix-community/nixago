package just

import "strings"
import "text/template"

#Settings: {
	"allow-duplicate-settings"?: bool
	"dotenv-load"?:              bool
	"export"?:                   bool
	"positional-arguments"?:     bool
	"shell"?: [...string]
	"windows-powershell"?: bool
}

#Config: {
	settings: #Settings
	definitions: [string]: string
	tasks: [string]: [...string]
}

data: #Config
_final: {
    if data.settings.shell != _|_ {
        _shell_quoted: [for v in data.settings.shell { "\"\(v)\"" }]
        _shell_str: "shell := [" + strings.Join(_shell_quoted, ",") + "]"
        settings: [for k,v in data.settings if k != "shell" { "set \(k) := \(v)" }] + [_shell_str]
    }
    if data.settings.shell == _|_ {
        settings: [for k,v in data.settings { "set \(k) := \(v)" }]
    }
    definitions: data.definitions
    tasks: data.tasks
}

tmpl:
"""
{{ range .settings -}}
    {{ . }}
{{ end }}
{{ range $key, $value := .definitions -}}
    {{ $key }} := {{ $value }}
{{ end }}
{{ range $name, $tasks := .tasks -}}
    {{ $name -}}:
    {{ range $tasks -}}
        {{ . }}
    {{ end }}
{{ end }}
"""

rendered: template.Execute(tmpl, _final)

import "strings"
import "text/template"

first_name: string
last_name: string
address: string

_data: {
    name: strings.ToTitle("\(first_name) \(last_name)")
    location: address
}
_tmpl:
"""
{{ .name }}
{{ .location }}
"""

rendered: template.Execute(_tmpl, _data)
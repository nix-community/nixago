# Plugins

Nixago provides most functionality through plugins. Each plugin targets a
specific configuration by providing a clean interface for end-users. While most
plugins follow a standard schema, the varying requirements of formats can
require minor differences.

Plugins are accessed via `nixago.plugins.${pluginName}`. See the relevant
documentation page or check the source code for what functions a plugin
provides.

# Overview

Nixago provides most functionality through plugins. Each plugin targets a
specific configuration by providing a clean interface for end-users. While most
plugins follow a common schema, the varying requirements of configurations can
require minor differences.

Plugins can be accessed via `nixago.plugins.${pluginName}`. For what functions
a plugin provides, see the relevant documentation page or check the source code.

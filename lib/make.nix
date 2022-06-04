{ pkgs, lib, plugins }:
{ name, configData, type ? "", output ? "", mode ? "", options ? { } }:
with pkgs.lib;
let
  # Build the plugin configuration
  plugin = plugins.${name};
  allOptions = ({ inherit configData; }
    // optionalAttrs (type != "") { inherit type; }
    // optionalAttrs (output != "") { inherit output; }
    // optionalAttrs (mode != "") { inherit mode; }
    // optionalAttrs (options != { }) { inherit options; });

  pluginConfig = (evalModules {
    modules = [
      ../modules/plugin.nix
      allOptions
    ];
  }).config;
in
plugin pluginConfig

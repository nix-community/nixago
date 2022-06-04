{ pkgs, lib, plugins }:
{ name, config, type ? "", output ? "", mode ? "", options ? { } }:
with pkgs.lib;
let
  plugin = plugins.${name};
  options = ({ configData = config; }
    // optionalAttrs (type != "") { inherit type; }
    // optionalAttrs (output != "") { inherit output; }
    // optionalAttrs (mode != "") { inherit mode; }
    // optionalAttrs (options != { }) { inherit options; });

  config = (evalModules {
    modules = [
      ../modules/plugin.nix
      options
    ];
  }).config;
in
plugin config

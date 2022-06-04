{ config, lib, flakeLib, pkgs, ... }:
with pkgs.lib;
{
  options = {
    configData = mkOption {
      type = types.attrs;
      description = "The raw configuration data";
    };
    mode = mkOption {
      type = types.str;
      description = "The output mode to use";
      default = "link";
    };
    name = mkOption {
      type = types.str;
      description = "The plugin to use";
    };
    options = mkOption {
      type = types.attrs;
      description = "Additional options to pass to the plugin";
      default = { };
    };
    output = mkOption {
      type = types.str;
      description = "The output path of the generated configuration file";
      default = "";
    };
    type = mkOption {
      type = types.str;
      description = "The type of configuration to generate";
      default = "default";
    };
  };
}

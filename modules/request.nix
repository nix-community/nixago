/* This module holds the main data structure that's used when handling a
  "request" from the user to generate a configuration file. It's ultimately
  processed by the `eval` function to create the derivation.
*/
{ config, lib, ... }:
with lib;
{
  options = {
    name = mkOption {
      type = types.str;
      description = "The plugin being used";
    };
    configData = mkOption {
      type = types.anything;
      description = "The raw configuration data";
    };
    flags = mkOption {
      type = types.attrs;
      description = "An optional list of flags to pass to cue";
      default = { };
    };
    mode = mkOption {
      type = types.str;
      description = "The output mode to use";
      default = "link";
    };
    package = mkOption {
      type = types.str;
      description = "The name of the cue package to evaluate";
      default = "";
    };
    pluginOpts = mkOption {
      type = types.attrs;
      description = "Additional options to pass to the plugin";
      default = { };
    };
    output = mkOption {
      type = types.str;
      description = "The output path of the generated configuration file";
      default = "";
    };
    postBuild = mkOption {
      type = types.str;
      description = "Shell code to run after executing cue eval";
      default = "";
    };
    shellHookExtra = mkOption {
      type = types.str;
      description = "Shell code to run after configuration file is updated";
      default = "";
    };
    type = mkOption {
      type = types.str;
      description = "The type of configuration to generate";
      default = "default";
    };
  };
}

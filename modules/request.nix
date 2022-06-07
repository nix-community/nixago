/* This module holds the main data structure that's used when handling a
  "request" from the user to generate a configuration file. It's ultimately
  processed by the `eval` function to create the derivation.
*/
{ config, lib, ... }:
with lib;
let
  cue = types.submodule ({ config, lib, ... }:
    {
      options = {
        flags = mkOption {
          type = types.attrs;
          description = "An optional list of flags to pass to cue";
          default = { };
        };
        format = mkOption {
          type = types.str;
          description = "The output format to generate";
          default = "";
        };
        package = mkOption {
          type = types.str;
          description = "The name of the cue package to evaluate";
          default = "";
        };
        path = mkOption {
          type = types.path;
          description = "The base path to search for packages in";
          default = ./.;
        };
        postBuild = mkOption {
          type = types.str;
          description = "Shell code to run after executing cue eval";
          default = "";
        };
      };
    });

  hook = types.submodule ({ config, lib, ... }:
    {
      options = {
        # TODO: Make this a list
        extra = mkOption {
          type = types.str;
          description = "Shell code to run after configuration file is updated";
          default = "";
        };
        mode = mkOption {
          type = types.str;
          description = "The output mode to use";
          default = "link";
        };
        output = mkOption {
          type = types.str;
          description = "The output path of the generated configuration file";
          default = "";
        };
      };
    });

  plugin = types.submodule ({ config, lib, ... }:
    {
      options = {
        name = mkOption {
          type = types.str;
          description = "The plugin being used";
          default = "";
        };
        opts = mkOption {
          type = types.attrs;
          description = "Additional options to pass to the plugin";
          default = { };
        };
        type = mkOption {
          type = types.str;
          description = "The type of configuration to generate";
          default = "default";
        };
      };
    });
in
{
  options = {
    configData = mkOption {
      type = types.anything;
      description = "The raw configuration data";
    };
    cue = mkOption {
      type = cue;
      description = "Additional options for controlling cue evaluation";
      default = { };
    };
    hook = mkOption {
      type = hook;
      description = "Additional options for controlling hook generation";
      default = { };
    };
    plugin = mkOption {
      type = plugin;
      description = "Options for selecting and controlling plugin usage";
      default = { };
    };
  };
}

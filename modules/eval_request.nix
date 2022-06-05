{ config, lib, ... }:
with lib;
{
  options = {
    pluginRequest = mkOption {
      type = types.submodule (import ./plugin_request.nix);
      description = "The embedded plugin request";
    };
    files = mkOption {
      type = types.listOf types.str;
      description = "A list of input files to evaluate";
    };
    flags = mkOption {
      type = types.attrs;
      description = "An optional list of flags to pass to cue eval";
      default = [ ];
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
  };
}

/*
  This module holds the main data structure that's used when handling a
  "request" from the user to generate a configuration file.
*/
{ lib, engines, ... }:
with lib;
let
  hook = types.submodule ({ config, lib, ... }:
    {
      options = {
        # TODO: Make this a list
        extra = mkOption {
          type = types.str;
          description = "Shell code to run when the file is updated";
          default = "";
        };
        mode = mkOption {
          type = types.str;
          description = "The output mode to use (copy or link)";
          default = "link";
        };
      };
    });
in
{
  freeformType = types.anything;

  options = {
    configData = mkOption {
      type = types.anything;
      description = "The raw configuration data";
    };
    engine = mkOption {
      type = types.functionTo types.package;
      description = "The engine to use for generating the derivation";
      default = engines.nix { };
    };
    format = mkOption {
      type = types.str;
      description = "The format of the output file";
    };
    hook = mkOption {
      type = hook;
      description = "Additional options for controlling hook generation";
      default = { };
    };
    output = mkOption {
      type = types.str;
      description = "The relative path to link the generated file";
    };
    root = mkOption {
      type = types.path;
      description = "The root path from which the relative path is derived";
      default =
        if builtins.getEnv "PRJ_ROOT" == ""
        then ./. else /. + (builtins.getEnv "PRJ_ROOT");
    };
  };
}

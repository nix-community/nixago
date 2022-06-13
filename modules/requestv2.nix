{ config, lib, ... }:
with lib;
{
  options = {
    configData = mkOption {
      type = types.anything;
      description = "The raw configuration data";
    };
    engine = mkOption {
      type = types.functionTo types.package;
      description = "The engine to use for generating output";
    };
    format = mkOption {
      type = types.str;
      description = "The format of the output file";
    };
    output = mkOption {
      type = types.str;
      description = "The relative path to link the generated file";
    };
    root = mkOption {
      type = type.path;
      description = "The root path from which the relative path is derived";
      default =
        if builtins.getEnv "PRJ_ROOT" == ""
        then ./. else /. + (builtins.getEnv "PRJ_ROOT");
    };
  };
}

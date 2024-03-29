/*
This module holds the main data structure that's used when handling a
"request" from the user to generate a configuration file.
*/
{
  lib,
  config,
  engines,
  ...
}:
with lib; let
  hook = types.submodule ({
    config,
    lib,
    ...
  }: {
    options = {
      # TODO: Make this a list
      extra = mkOption {
        type = types.either types.str (types.functionTo types.str);
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
in {
  freeformType = types.anything;

  options = {
    data = mkOption {
      type = types.anything;
      description = "The raw configuration data";
    };
    engine = mkOption {
      type = types.functionTo types.package;
      description = "The engine to use for generating the derivation";
      default = engines.nix {};
    };
    format = mkOption {
      type = types.str;
      description = "The format of the output file";
      default = (
        let
          parts = splitString "." config.output;
        in
          builtins.elemAt parts ((builtins.length parts) - 1)
      );
    };
    hook = mkOption {
      type = hook;
      description = "Additional options for controlling hook generation";
      default = {};
    };
    apply = mkOption {
      type = types.functionTo types.anything;
      description = "Apply this transformation to `data`";
      default = x: x;
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
        then ./.
        else /. + (builtins.getEnv "PRJ_ROOT");
    };
  };
}

{ config, lib, ... }:
with lib;
{
  options = {
    file = mkOption {
      type = types.package;
      description = "The derivation for generating the configuration file";
    };
    shellHook = mkOption {
      type = types.str;
      description = "The shell hook for managing the generated file";
    };
  };
}

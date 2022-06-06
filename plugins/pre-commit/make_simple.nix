{ pkgs, lib }:
config:
with pkgs.lib;
let
  inherit (config) configData;
  files = [ ./template.cue ];
  defaultOutput = ".pre-commit-config.yaml";
  pre-commit = pkgs.pre-commit;

  # Build configData and shellHookExtra
  common = import ./common.nix {
    inherit pkgs pre-commit; inherit (config) type; data = config.configData;
  };
in
lib.genConfig
{
  inherit defaultOutput files;
  inherit (common) shellHookExtra;
  config = lib.overrideData config common.configData;
}

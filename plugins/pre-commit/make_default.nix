{ pkgs, lib }:
userData:
with pkgs.lib;
let
  inherit (userData) configData type;
  files = [ ./templates/default.cue ];
  pre-commit = pkgs.pre-commit;

  # Build configData and shellHookExtra
  common = import ./common.nix {
    inherit pkgs pre-commit type; data = configData;
  };
in
{
  inherit files;
  inherit (common) configData shellHookExtra;
}

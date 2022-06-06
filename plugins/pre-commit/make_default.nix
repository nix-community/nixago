{ pkgs, lib }:
userData:
with pkgs.lib;
let
  inherit (userData) configData type;
  pre-commit = pkgs.pre-commit;

  # Build configData and shellHookExtra
  common = import ./common.nix {
    inherit pkgs pre-commit type; data = configData;
  };
in
{
  inherit (common) configData shellHookExtra;
}

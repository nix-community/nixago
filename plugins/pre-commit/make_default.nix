{ pkgs, lib }:
userData:
with pkgs.lib;
let
  inherit (userData) configData;
  inherit (userData.plugin) type;
  pre-commit = pkgs.pre-commit;

  # Build configData and shellHookExtra
  common = import ./common.nix {
    inherit pkgs pre-commit type; data = configData;
  };
in
{
  inherit (common) configData;
  hook = {
    inherit (common) extra;
  };
}

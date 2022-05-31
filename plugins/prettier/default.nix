{ pkgs, lib }:
rec {
  default = mkConfig;

  /* Creates a .prettierrc.json file for configuring prettier.
  */
  mkConfig = import ./mkConfig.nix { inherit pkgs lib; };
  mkIgnoreConfig = import ./mkIgnoreConfig.nix { inherit pkgs lib; };
}

{ pkgs, lib }:
rec {
  default = mkConfig;

  /* Creates a .conform.yaml file for configuring conform.
  */
  mkConfig = import ./mkConfig.nix { inherit pkgs lib; };
}

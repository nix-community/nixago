{ pkgs, lib }:
{
  /* Creates a .prettierrc.json file for configuring prettier.
  */
  mkConfig = import ./mkConfig.nix { inherit pkgs lib; };
}

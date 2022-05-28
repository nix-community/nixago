{ pkgs, lib }:
{
  /* Creates a .prettierrc.json file for configuring prettier.
  */
  mkConfig = import ./make.nix { inherit pkgs lib; };
}

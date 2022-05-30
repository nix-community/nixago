{ pkgs, lib }:
{
  /* Creates a lefthook.yml file for configuring lefthook.
  */
  mkConfig = import ./mkConfig.nix { inherit pkgs lib; };
}

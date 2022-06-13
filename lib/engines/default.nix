{ pkgs, lib }:
{
  nix = import ./nix.nix { inherit pkgs lib; };
}

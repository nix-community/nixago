{ pkgs, lib }:
{
  mkConfig = import ./make.nix { inherit pkgs lib; };
}

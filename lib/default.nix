{ pkgs, lib }:
{
  mkTemplate = import ./template.nix { inherit pkgs lib; };
}

{ pkgs, lib }:
{
  mkConfig = import ./make.nix { inherit pkgs lib; };
  mkLocalConfig = import ./make_local.nix { inherit pkgs lib; };
}

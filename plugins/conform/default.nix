{ pkgs, lib }:
{
  name = "conform";
  types = {
    default = {
      output = ".conform.yaml";
      make = import ./make_default.nix { inherit pkgs lib; };
    };
  };
}

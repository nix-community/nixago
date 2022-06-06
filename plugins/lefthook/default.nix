{ pkgs, lib }:
{
  name = "lefthook";
  types = {
    default = {
      output = "lefthook.yml";
      make = import ./make_default.nix { inherit pkgs lib; };
    };
  };
}

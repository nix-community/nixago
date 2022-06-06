{ pkgs, lib }:
{
  name = "just";
  types = {
    default = {
      output = ".justfile";
      make = import ./make_default.nix { inherit pkgs lib; };
    };
  };
}

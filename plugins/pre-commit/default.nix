{ pkgs, lib }:
{
  name = "pre-commit";
  types = {
    default = {
      output = ".pre-commit-config.yaml";
      make = import ./make_default.nix { inherit pkgs lib; };
    };
    simple = {
      output = ".pre-commit-config.yaml";
      make = import ./make_simple.nix { inherit pkgs lib; };
    };
  };
}

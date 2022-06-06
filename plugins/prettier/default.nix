{ pkgs, lib }:
{
  name = "prettier";
  types = {
    default = {
      output = ".prettierrc.json";
      make = import ./make_default.nix { inherit pkgs lib; };
    };
    ignore = {
      output = ".prettierignore";
      make = import ./make_ignore.nix { inherit pkgs lib; };
    };
  };
}

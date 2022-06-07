{ pkgs, lib }:
{
  name = "ghsettings";
  types = {
    default = {
      output = ".github/settings.yml";
      make = import ./make_default.nix { inherit pkgs lib; };
    };
  };
}

{ pkgs, lib }:
{ data }:
with pkgs.lib;
let
  files = [ ./template.cue ];
  output = ".prettierrc.json";

  # Generate the module
  result = lib.mkTemplate {
    inherit data files output;
  };
in
{
  inherit (result) configFile shellHook;
}

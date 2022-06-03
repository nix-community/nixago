{ pkgs, lib }:
{ configData }:
with pkgs.lib;
let
  files = [ ./template.cue ];
  output = ".prettierrc.json";

  # Generate the module
  result = lib.mkTemplate {
    inherit configData files output;
  };
in
{
  inherit (result) configFile shellHook;
}

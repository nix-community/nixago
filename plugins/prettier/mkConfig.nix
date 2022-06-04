{ pkgs, lib }:
{ configData, mode ? "link" }:
with pkgs.lib;
let
  files = [ ./template.cue ];
  output = ".prettierrc.json";

  # Generate the module
  result = lib.mkTemplate {
    inherit configData mode files output;
  };
in
{
  inherit (result) configFile shellHook;
}

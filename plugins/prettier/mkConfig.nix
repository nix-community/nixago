{ pkgs, lib }:
{ configData, output ? ".prettierrc.json", mode ? "link" }:
with pkgs.lib;
let
  files = [ ./template.cue ];

  # Generate the module
  result = lib.mkTemplate {
    inherit configData mode files output;
  };
in
{
  inherit (result) configFile shellHook;
}

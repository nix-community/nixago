{ pkgs, lib }:
{ config }:
with pkgs.lib;
let
  # Generate the module
  result = lib.mkTemplate {
    data = config;
    files = [ ./template.cue ];
    output = ".prettierrc.json";
  };
in
{
  inherit (result) configFile shellHook;
}

{ pkgs, lib }:
{ config }:
let
  result = lib.mkTemplate {
    data = { data = config; };
    files = [ ./template.cue ];
    output = ".justfile";
    flags = {
      expression = "rendered";
      out = "text";
    };
  };
in
{
  inherit (result) configFile shellHook;
}

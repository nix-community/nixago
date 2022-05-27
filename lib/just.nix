{ pkgs, lib }:
{ config }:
let
  result = lib.common.mkModule {
    data = { data = config; };
    files = [ ../cue/just.cue ];
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

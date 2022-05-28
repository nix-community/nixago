{ pkgs, lib }:
{ config }:
let
  result = lib.mkTemplate {
    data = { data = config; };
    files = [ ./template.cue ];
    output = ".justfile";
    postBuild = ''
      cat $out
      ${pkgs.just}/bin/just --unstable --fmt -f $out
    '';
    flags = {
      expression = "rendered";
      out = "text";
    };
  };
in
{
  inherit (result) configFile shellHook;
}

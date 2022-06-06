{ pkgs, lib }:
userData:
let
  files = [ ./templates/ignore.cue ];
  flags = {
    expression = "rendered";
    out = "text";
  };
  configData = { data = userData.configData; };
in
{
  inherit configData files flags;
}

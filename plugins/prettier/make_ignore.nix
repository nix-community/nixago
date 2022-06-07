{ pkgs, lib }:
userData:
let
  flags = {
    expression = "rendered";
    out = "text";
  };
  configData = { data = userData.configData; };
in
{
  inherit configData;
  cue = {
    inherit flags;
  };
}

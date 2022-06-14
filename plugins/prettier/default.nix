{ pkgs, lib }:
configData:
{
  inherit configData;
  format = "json";
  output = ".prettierrc.json";
  engine = lib.engines.cue {
    path = ./templates;
    package = "default";
  };
}

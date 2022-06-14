{ pkgs, lib }:
configData:
{
  inherit configData;
  format = "yaml";
  output = ".github/settings.yml";
  engine = lib.engines.cue {
    path = ./templates;
  };
}

{ pkgs, lib }:
config:
with pkgs.lib;
let
  inherit (config) configData;
  files = [ ./template.cue ];
  defaultOutput = ".conform.yaml";

  # Expand out the configData
  configDataFinal = {
    policies =
      (optional
        (configData ? commit)
        { type = "commit"; spec = configData.commit; }) ++
      (optional
        (configData ? license)
        { type = "license"; spec = configData.license; });
  };
in
lib.genConfig
{
  inherit defaultOutput files;
  config = lib.overrideData config configDataFinal;
}

{ pkgs, lib }:
{ configData, mode ? "link" }:
with pkgs.lib;
let
  files = [ ./template.cue ];
  output = ".conform.yaml";

  # Expand out the configData
  test = {
    commit = { };
    license = { };
  };

  configDataFinal = {
    policies =
      (optional
        (configData ? commit)
        { type = "commit"; spec = configData.commit; }) ++
      (optional
        (configData ? license)
        { type = "license"; spec = configData.license; });
  };

  # Generate the module
  result = lib.mkTemplate {
    inherit files mode output;
    configData = configDataFinal;
  };
in
{
  inherit (result) configFile shellHook;
}

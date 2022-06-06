{ pkgs, lib }:
userData:
with pkgs.lib;
let
  inherit (userData) configData;
  files = [ ./templates/default.cue ];

  # Expand out the configData
  configDataFinal = {
    policies =
      (optional
        (configData ? commit)
        {
          type = "commit";
          spec = configData.commit;
        }) ++
      (optional
        (configData ? license)
        {
          type = "license";
          spec = configData.license;
        });
  };
in
{
  inherit files;
  configData = configDataFinal;
}

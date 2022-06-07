{ pkgs, lib }:
userData:
with pkgs.lib;
let
  inherit (userData) configData;

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
  configData = configDataFinal;
}

{ pkgs, lib }:
data:
with pkgs.lib;
let
  files = [ ./template.cue ];
  output = ".conform.yaml";

  # Expand out the data
  test = {
    commit = { };
    license = { };
  };

  dataFinal = {
    policies =
      (optional (data ? commit) { type = "commit"; spec = data.commit; }) ++
      (optional (data ? license) { type = "license"; spec = data.license; });
  };

  # Generate the module
  result = lib.mkTemplate {
    inherit files output;
    data = dataFinal;
  };
in
{
  inherit (result) configFile shellHook;
}

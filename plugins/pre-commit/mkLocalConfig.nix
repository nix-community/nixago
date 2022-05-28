{ pkgs, lib }:
data:
with pkgs.lib;
let
  files = [ ./template.cue ];
  output = ".pre-commit-config.yaml";
  pre-commit = pkgs.pre-commit;

  # Add an extra hook for reinstalling required stages whenever the file changes
  stages = unique (flatten (builtins.map (hook: optionals (hook ? stages) hook.stages) (attrValues data)));
  stagesStr = builtins.concatStringsSep " " stages;
  shellHookExtra = (import ./common.nix { inherit pre-commit stagesStr; }).shellHookExtra;

  # Add structure to data
  hooks = attrValues (pkgs.lib.mapAttrs
    (id: hook: (
      { inherit id; name = if (hook ? name) then hook.name else id; } // hook
    ))
    data);
  finalData = {
    repos = [
      {
        inherit hooks;
        repo = "local";
      }
    ];
  };

  # Generate the module
  result = lib.mkTemplate {
    inherit files output shellHookExtra;
    data = finalData;
  };
in
{
  inherit (result) configFile shellHook;
}

{ pkgs, lib }:
{ configData, output ? ".pre-commit-config.yaml", mode ? "link" }:
with pkgs.lib;
let
  files = [ ./template.cue ];
  pre-commit = pkgs.pre-commit;

  # Add an extra hook for reinstalling required stages whenever the file changes
  stages = unique (flatten
    (builtins.map
      (hook: optionals (hook ? stages) hook.stages)
      (attrValues configData)));
  stagesStr = builtins.concatStringsSep " " stages;
  shellHookExtra =
    (import ./common.nix { inherit pre-commit stagesStr; }).shellHookExtra;

  # Add structure to configData
  hooks = attrValues (pkgs.lib.mapAttrs
    (id: hook: (
      { inherit id; name = if (hook ? name) then hook.name else id; } // hook
    ))
    configData);
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
    inherit files mode output shellHookExtra;
    data = finalData;
  };
in
{
  inherit (result) configFile shellHook;
}

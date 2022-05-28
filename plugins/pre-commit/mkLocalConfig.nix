{ pkgs, lib }:
{ config, pre-commit ? pkgs.pre-commit, jq ? pkgs.jq, yq ? pkgs.yq-go }:
with pkgs.lib;
let
  # Find all stages that require installation
  stages = unique (flatten (builtins.map (hook: optionals (hook ? stages) hook.stages) (attrValues config)));
  stagesStr = builtins.concatStringsSep " " stages;

  # Add an extra hook for reinstalling required stages whenever the file changes
  shellHookExtra = (import ./common.nix { inherit pre-commit stagesStr; }).shellHookExtra;

  # Add structure to config
  hooks = attrValues (pkgs.lib.mapAttrs
    (id: hook: (
      { inherit id; name = if (hook ? name) then hook.name else id; } // hook
    ))
    config);
  data = {
    repos = [
      {
        inherit hooks;
        repo = "local";
      }
    ];
  };

  # Generate the module
  result = lib.mkTemplate {
    inherit data shellHookExtra;
    files = [ ./template.cue ];
    output = ".pre-commit-config.yaml";
  };
in
{
  inherit (result) configFile shellHook;
}

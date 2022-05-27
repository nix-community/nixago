{ pkgs, lib }:
{ config, pre-commit ? pkgs.pre-commit, jq ? pkgs.jq, yq ? pkgs.yq-go }:
with pkgs.lib;
let
  # Find all stages that require installation
  stages = unique (flatten (builtins.map (repo: builtins.map (hook: optionals (hook ? stages) hook.stages) repo.hooks) config.repos) ++ [ "pre-commit" ]);
  stagesStr = builtins.concatStringsSep " " stages;

  # Add an extra hook for reinstalling required stages whenever the file changes
  shellHookExtra = (import ./common.nix { inherit pre-commit stagesStr; }).shellHookExtra;

  # Generate the module
  result = lib.mkTemplate {
    inherit shellHookExtra;
    data = config;
    files = [ ./template.cue ];
    output = ".pre-commit-config.yaml";
  };
in
{
  inherit (result) configFile shellHook;
}

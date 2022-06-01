{ pkgs, lib }:
data:
with pkgs.lib;
let
  files = [ ./template.cue ];
  output = ".pre-commit-config.yaml";
  pre-commit = pkgs.pre-commit;

  # Add an extra hook for reinstalling required stages whenever the file changes
  stages = unique (flatten
    (builtins.map
      (repo: builtins.map
        (hook: optionals (hook ? stages) hook.stages)
        repo.hooks)
      data.repos) ++ [ "pre-commit" ]);
  stagesStr = builtins.concatStringsSep " " stages;
  shellHookExtra =
    (import ./common.nix { inherit pre-commit stagesStr; }).shellHookExtra;

  # Generate the module
  result = lib.mkTemplate {
    inherit data files output shellHookExtra;
  };
in
{
  inherit (result) configFile shellHook;
}

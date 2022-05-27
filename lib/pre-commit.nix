{ pkgs, lib }:
{ config, pre-commit ? pkgs.pre-commit, jq ? pkgs.jq, yq ? pkgs.yq-go }:
with pkgs.lib;
let
  # Find all stages that require installation
  stages = unique (flatten (builtins.map (repo: builtins.map (hook: optionals (hook ? stages) hook.stages) repo.hooks) config.repos) ++ [ "pre-commit" ]);
  stagesStr = builtins.concatStringsSep " " stages;

  # Add an extra hook for reinstalling required stages whenever the file changes
  shellHookExtra = ''
    # Uninstall all existing hooks
    hooks="pre-commit pre-merge-commit pre-push prepare-commit-msg commit-msg post-checkout post-commit"
    for hook in $hooks; do
      ${pre-commit}/bin/pre-commit uninstall -t $hook
    done

    # Install configured hooks
    for stage in ${stagesStr}; do
      if [[ "$stage" == "manual" ]]; then
        continue
      fi

      ${pre-commit}/bin/pre-commit install -t "$stage"
    done
  '';

  # Generate the module
  result = lib.common.mkModule {
    inherit shellHookExtra;
    data = config;
    files = [ ../cue/pre-commit.cue ];
    output = ".pre-commit-config.yaml";
  };
in
{
  inherit (result) configFile shellHook;
}

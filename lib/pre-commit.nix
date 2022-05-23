{ pkgs, config, pre-commit ? pkgs.pre-commit, jq ? pkgs.jq, yq ? pkgs.yq-go }:
with pkgs.lib;
let
  # Load module and evaluate against passed configuration
  mod = evalModules {
    modules = [
      ../modules/hook.nix
      {
        inherit config;
      }
    ];
  };

  # Find all stages to install
  stages = unique (flatten (builtins.map (repo: builtins.map (hook: hook.stages) repo.hooks) mod.config.repos) ++ [ "pre-commit" ]);
  installStages = builtins.concatStringsSep " " (builtins.filter (stage: stage != null) stages);

  # Create a YAML variant of the generated configuration. Most default values
  # are null, so we use `jq` to strip the associated keys from the final
  # configuration. This keeps it small and prevents drift by enforcing default
  # values provided by `pre-commit`.
  configFile = pkgs.runCommand "pre-commit-config.yaml"
    {
      buildInputs = [ yq jq ];
      json = builtins.toJSON (filterAttrsRecursive (name: value: value != null) mod.config);
      passAsFile = [ "json" ];
    }
    ''
      jq 'del(.repos[].hooks[][] | nulls)' "$jsonPath" | jq 'del(.repos[][] | nulls)' | jq 'del(.[][] | nulls)' | yq -P > $out
    '';

  # Provides a shell hook for linking the generated configuration and installing
  # the required git hook scripts. Changes are only applied when the
  # configuration changes.
  shellHook = ''
    # Check if the link is pointing to the existing derivation result
    if readlink .pre-commit-config.yaml >/dev/null \
      && [[ $(readlink .pre-commit-config.yaml) == ${configFile} ]]; then
      echo 1>&2 "nix-pre-commit: .pre-commit-config.yaml is up to date"
    elif [[ -L .pre-commit-config.yaml || ! -f .pre-commit-config.yaml ]]; then # otherwise we need to update
      echo 1>&2 "nix-pre-commit: updating .pre-commit-config.yaml"

      # Relink to the new result
      unlink .pre-commit-config.yaml
      ln -s ${configFile} .pre-commit-config.yaml

      # Uninstall all existing hooks
      hooks="pre-commit pre-merge-commit pre-push prepare-commit-msg commit-msg post-checkout post-commit"
      for hook in $hooks; do
        ${pre-commit}/bin/pre-commit uninstall -t $hook
      done

      # Install configured hooks
      for stage in ${installStages}; do
        if [[ "$stage" == "manual" ]]; then
          continue
        fi

        ${pre-commit}/bin/pre-commit install -t "$stage"
      done
    else # this was an existing file
      echo 1>&2 "nix-pre-commit: ERROR refusing to overwrite existing .pre-commit-config.yaml"
    fi
  '';
in
{
  inherit configFile shellHook;
  config = mod.config;
}

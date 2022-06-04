{ pkgs, pre-commit, data, type }:
with pkgs.lib;
let
  # A list of all valid pre-commit stages
  hooksStr = builtins.concatStringsSep " " [
    "pre-commit"
    "pre-merge-commit"
    "pre-push"
    "prepare-commit-msg"
    "commit-msg"
    "post-checkout"
    "post-commit"
  ];

  # Builds stages list from default data format
  getDefaultStages = data:
    unique (flatten
      (builtins.map
        (repo: builtins.map
          (hook: optionals (hook ? stages) hook.stages)
          repo.hooks)
        data.repos) ++ [ "pre-commit" ]);

  # Builds stages list from simple data format
  getSimpleStages = data:
    unique (flatten
      (builtins.map
        (hook: optionals (hook ? stages) hook.stages)
        (attrValues data)));

  # Builds up simplified data to the expected format
  buildSimpleData = data:
    let
      hooks = attrValues (pkgs.lib.mapAttrs
        (id: hook: (
          { inherit id; name = if (hook ? name) then hook.name else id; } // hook
        ))
        data);
    in
    {
      repos = [
        {
          inherit hooks;
          repo = "local";
        }
      ];
    };

  # Build list of stages to install
  stages =
    if type == "simple" then
      (getSimpleStages data) else (getDefaultStages data);
  stagesStr = builtins.concatStringsSep " " stages;

  # Add optional structure to configData
  configData = if type == "simple" then (buildSimpleData data) else data;
in
{
  inherit configData;
  shellHookExtra = ''
    # Uninstall all existing hooks
    for hook in ${hooksStr}; do
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
}

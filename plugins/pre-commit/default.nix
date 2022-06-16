{ pkgs, lib, engines }:
configData:
with pkgs.lib;
let
  pre-commit = pkgs.pre-commit;

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

  # Builds stages list from data
  getStages = data:
    unique (flatten
      (builtins.map
        (hook: optionals (hook ? stages) hook.stages)
        (attrValues data)));

  # Builds up simplified config format to the expected format
  buildData = data:
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
  stages = getStages configData;
  stagesStr = builtins.concatStringsSep " " stages;

in
{
  configData = buildData configData;
  format = "yaml";
  output = ".pre-commit-config.yaml";
  hook = {
    extra = ''
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
  };
  engine = engines.cue {
    files = [ ./templates/default.cue ];
  };
}

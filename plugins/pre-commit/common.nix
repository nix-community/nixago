{ pre-commit, stagesStr }:
let
  hooksStr = builtins.concatStringsSep " " [
    "pre-commit"
    "pre-merge-commit"
    "pre-push"
    "prepare-commit-msg"
    "commit-msg"
    "post-checkout"
    "post-commit"
  ];
in
{
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

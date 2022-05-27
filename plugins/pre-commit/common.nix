{ pre-commit, stagesStr }:
{
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
}

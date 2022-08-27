{ configFile, hookConfig }:
let
  inherit (hookConfig) output extra;

  gitignore-sentinel = "ignore-linked-files";

  ansi = import ./ansi.nix;
in
''
  extra_hook() (
  true
  ${extra}
  )
  # Check if the link is pointing to the existing derivation result
  if readlink ${output} >/dev/null \
    && [[ $(readlink ${output}) == ${configFile} ]]; then
    log "'${output}' link is up to date"
  elif [[ -L ${output} || ! -f ${output} ]]; then
    # otherwise we need to update
    log "${ansi.bold}${ansi."10"}'${output}' link updated${ansi.reset}"

    # Relink to the new result
    if [[ -L ${output} ]]; then
      unlink ${output}
    fi

    try_make_path ${output}
    ln -s ${configFile} ${output}

    # Run extra shell hook
    extra_hook
  else
    # this was an existing file
    error "refusing to overwrite '${output}'"
  fi
  # Add this output to gitignore if not already
  if ! test -f .gitignore
  then
    touch .gitignore
  fi
  if ! grep -qF "${output}" .gitignore
  then
    if ! grep -qF "${gitignore-sentinel}" .gitignore
    then
      echo -e "\n# nixago: ${gitignore-sentinel}" >> .gitignore
    fi
    newgitignore="$(awk '1;/${gitignore-sentinel}/{ print "${output}"; }' .gitignore)"
    echo -e -n "$newgitignore" > .gitignore
    git add .gitignore
    log "${ansi.bold}${ansi."11"}'${output}' added to .gitignore${ansi.reset}"
  fi
''

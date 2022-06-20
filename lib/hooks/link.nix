{ configFile, hookConfig }:
let
  inherit (hookConfig) output extra;
in
''
  # Check if the link is pointing to the existing derivation result
  if readlink ${output} >/dev/null \
    && [[ $(readlink ${output}) == ${configFile} ]]; then
    log "${output} link is up to date"
  elif [[ -L ${output} || ! -f ${output} ]]; then
    # otherwise we need to update
    log "${output} link updated"

    # Relink to the new result
    if [[ -L ${output} ]]; then
      unlink ${output}
    fi

    try_make_path ${output}
    ln -s ${configFile} ${output}

    # Run extra shell hook
    ${extra}
  else
    # this was an existing file
    error "refusing to overwrite ${output}"
  fi
''

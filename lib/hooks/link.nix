{ configFile, output, shellHookExtra }:
''
  # Check if the link is pointing to the existing derivation result
  if readlink ${output} >/dev/null \
    && [[ $(readlink ${output}) == ${configFile} ]]; then
    echo 1>&2 "nixago: ${output} link is up to date"
  elif [[ -L ${output} || ! -f ${output} ]]; then
    # otherwise we need to update
    echo 1>&2 "nixago: ${output} link updated"

    # Relink to the new result
    unlink ${output} &>/dev/null
    ln -s ${configFile} ${output}

    # Run extra shell hook
    ${shellHookExtra}
  else # this was an existing file
    echo 1>&2 "nixago: ERROR refusing to overwrite ${output}"
  fi
''

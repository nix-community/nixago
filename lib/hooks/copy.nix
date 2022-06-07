{ configFile, output, shellHookExtra }:
''
  # Check if the file exists
  if [[ -f ${output} ]]; then
    # Check if we need to update the local copy
    cmp ${configFile} ${output} >/dev/null
    if [[ $? -gt 0 ]]; then
      # We need to update the local copy
      echo "nixago: ${output} copy updated"
      install -m 644 ${configFile} ${output}

      # Run extra shell hook
      ${shellHookExtra}
    else
      echo "nixago: ${output} copy is up to date"
    fi
  else
    # We need to create the first iteration of the file
    echo "nixago: ${output} copy created"
    install -m 644 ${configFile} ${output}

    # Run extra shell hook
    ${shellHookExtra}
  fi
''

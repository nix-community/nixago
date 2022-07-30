{ configFile, hookConfig }:
let
  inherit (hookConfig) output extra;
in
''
  extra_hook() (
  true
  ${extra}
  )
  # Check if the file exists
  if [[ -f ${output} ]]; then
    # Check if we need to update the local copy
    if ! cmp ${configFile} ${output} >/dev/null; then
      # We need to update the local copy
      log "${output} copy updated"
      install -m 644 ${configFile} ${output}

      # Run extra shell hook
      extra_hook
    else
      log "${output} copy is up to date"
    fi
  else
    # We need to create the first iteration of the file
    try_make_path ${output}
    install -m 644 ${configFile} ${output}
    log "${output} copy created"

    # Run extra shell hook
    extra_hook
  fi
''

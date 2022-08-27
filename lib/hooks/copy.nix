{ configFile, hookConfig }:
let
  inherit (hookConfig) output extra;

  ansi = import ./ansi.nix;
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
      log "${ansi.bold}${output} copy ${ansi."10"}updated${ansi.reset}"
      install -m 644 ${configFile} ${output}

      # Run extra shell hook
      extra_hook
    else
      log "${ansi."8"}${output} copy is up to date${ansi.reset}"
    fi
  else
    # We need to create the first iteration of the file
    try_make_path ${output}
    install -m 644 ${configFile} ${output}
    log "${ansi.bold}${output} ${ansi."11"}copy created${ansi.reset}"

    # Run extra shell hook
    extra_hook
  fi
''

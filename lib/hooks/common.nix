''
  debug() {
    if [[ ''${NIXAGO_DEBUG-0} -gt 0 ]]; then
      printf "(DEBUG) nixago: %s\n" "''${*}"
    fi
  }

  error() {
    printf "!!! nixago: ERROR %s\n" "''${*}"
  }

  log() {
    printf "nixago: %s\n" "''${*}"
  }

  run_if_trace() {
    if [[ ''${NIXAGO_TRACE-0} -gt 0 ]]; then
      eval ''${*}
    fi
  }

  PS4='+ Line $(expr $LINENO + 4): '
''

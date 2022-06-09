{ pkgs, lib, plugins }:
{ name, configFile, hookConfig }:
let
  # Header contains shared code across hooks
  header = import ./header.nix;

  # Load hook file based on mode passed
  hookFile = ./. + "/${hookConfig.mode}.nix";
  hook = import hookFile { inherit configFile hookConfig; };

  # Use writeShellScript for integrated error checking
  shellScript = pkgs.writeShellScript "nixago_${name}_hook" hook;
in
''
  ${header}
  run_if_trace set -x
  source ${shellScript}
  run_if_trace set +x
''

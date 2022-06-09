{ pkgs, lib, plugins }:
{ configFile, hookConfig }:
let
  # Header contains shared code across hooks
  header = import ./header.nix;

  # Load hook file based on mode passed
  hookFile = ./. + "/${hookConfig.mode}.nix";
  hook = import hookFile { inherit configFile hookConfig; };

  # Use writeShellScriptBin for integrated error checking
  shellScript = pkgs.writeShellScriptBin "nixago" hook;
in
''
  ${header}
  run_if_trace set -x
  source ${pkgs.lib.getExe shellScript}
  run_if_trace set +x
''

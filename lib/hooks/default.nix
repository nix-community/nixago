{ pkgs, lib }:
{ name, configFile, hookConfig }:
with pkgs.lib;
let
  # Common contains shared code across hooks
  common = import ./common.nix;

  # Load hook file based on mode passed
  hookFile = ./. + "/${hookConfig.mode}.nix";
  hook = import hookFile { inherit configFile hookConfig; };

  # Use writeShellScript for integrated error checking
  shellScript = pkgs.writeShellScript "nixago_${name}_hook" hook;

  prefixStringLines = prefix: str:
    concatMapStringsSep "\n" (line: prefix + line) (splitString "\n" str);
  indent = prefixStringLines "  ";
in
{
  inherit shellScript;
  shellHook = ''
    nixago() (
      # Common shell code
    ${indent common}
  
      # Enable tracing if NIXAGO_TRACE==1
      run_if_trace set -x
      source ${shellScript}
      run_if_trace set +x
    )
    nixago
    unset -f nixago
  '';
}

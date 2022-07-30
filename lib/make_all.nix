/** Concatenates a list of configurations together
*/
{ pkgs, lib }:
all:
with pkgs.lib;
let
  result = builtins.map lib.make all;

  prefixStringLines = prefix: str:
    concatMapStringsSep "\n" (line: prefix + line) (splitString "\n" str);
  indent = prefixStringLines "  ";

  # Only include common shell code once
  common = (import ./hooks/common.nix);
  shellHook = ''
    nixago() (
      # Common shell code
    ${indent common}

      # Enable tracing if NIXAGO_TRACE==1
      run_if_trace set -x
      source ${concatStringsSep "\n  source " (catAttrs "shellScript" result)}
      run_if_trace set +x
    )
    nixago
    unset -f nixago
  '';
in
{
  inherit shellHook;
  scripts = catAttrs "shellScript" result;
  configs = catAttrs "configFile" result;
}

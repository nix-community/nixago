/** Concatenates a list of configurations together
*/
{ pkgs, lib }:
all:
with pkgs.lib;
let
  result = builtins.map lib.make all;

  # Only include common shell code once
  common = (import ./hooks/common.nix);
  shellHook = common + "\nsource " +
    (concatStringsSep "\nsource " (catAttrs "shellScript" result));
in
{
  inherit shellHook;
  scripts = catAttrs "shellScript" result;
  configs = catAttrs "configFile" result;
}

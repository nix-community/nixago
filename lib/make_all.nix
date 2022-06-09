/** Concatenates a list of configurations together
*/
{ pkgs, lib, plugins }:
all:
with pkgs.lib;
let
  result = builtins.map lib.make all;
in
{
  configs = catAttrs "configFile" result;
  shellHook = concatStringsSep "\n" (pkgs.lib.catAttrs "shellHook" result);
}

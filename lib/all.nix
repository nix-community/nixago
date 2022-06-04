/* Creates templates from a set of configuration data.

  Accepts an attribute set where the name is the relative path to a function which
  creates a template and the key is the configuration data that will be passed to
  that function. Returns a set with two fields: configs is a list of all
  configuration derivations and shellHook is a concatenated version of all
  configuration shellHooks.
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

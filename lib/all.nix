/* Creates templates from a set of configuration data.

  Accepts an attribute set where the name is the relative path to a function which
  creates a template and the key is the configuration data that will be passed to
  that function. Returns a set with two fields: configs is a list of all
  configuration derivations and shellHook is a concatenated version of all
  configuration shellHooks.
*/
{ pkgs, lib }:
all:
let
  plugins = import ../plugins { inherit pkgs lib; };
  makeAll = name: data: (
    let
      path = pkgs.lib.splitString "." name;
      make = pkgs.lib.getAttrFromPath path plugins;
    in
    make data
  );

  result = pkgs.lib.mapAttrsToList makeAll all;
in
{
  configs = pkgs.lib.catAttrs "configFile" result;
  shellHook = pkgs.lib.concatStringsSep "\n" (pkgs.lib.catAttrs "shellHook" result);
}

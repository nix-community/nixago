/* Creates templates from a set of configuration data.

  Accepts an attribute set where the name is the relative path to a function which
  creates a template and the key is the configuration data that will be passed to
  that function. Returns a set with two fields: configs is a list of all
  configuration derivations and shellHook is a concatenated version of all
  configuration shellHooks.
*/
{ pkgs, lib }:
all:
with pkgs.lib;
let
  plugins = import ../plugins { inherit pkgs lib; };
  makeAll = name: data: (
    let
      # If the input is not in the `plugin.function` format, assume we want
      # `plugin.default`
      path =
        let s = splitString "." name;
        in
        if (builtins.length (s) > 1) then s else [ name "default" ];

      make = getAttrFromPath path plugins;
    in
    make data
  );

  result = mapAttrsToList makeAll all;
in
{
  configs = catAttrs "configFile" result;
  shellHook = concatStringsSep "\n" (pkgs.lib.catAttrs "shellHook" result);
}

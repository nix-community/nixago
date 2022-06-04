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

  # Create separate sets of plugin calls and plugin options
  filteredOpts = filterAttrs
    (path: data: (
      let
        parts = splitString "." path;
        partsLength = builtins.length parts;
      in
      if partsLength > 1 then (builtins.elemAt parts 1) == "opts" else false
    ))
    all;
  filteredFuncs = filterAttrs
    (path: data: (
      let
        parts = splitString "." path;
        partsLength = builtins.length parts;
      in
      if partsLength > 1 then (builtins.elemAt parts 1) != "opts" else true
    ))
    all;

  # Convert option keys to `pluginName` instead of `pluginName.opts`
  opts = mapAttrs'
    (name: data: (
      let
        parts = splitString "." name;
        pluginName = builtins.elemAt parts 0;
      in
      nameValuePair pluginName data
    ))
    filteredOpts;

  # Convert function keys to `pluginName.default` if name was omitted
  funcs = mapAttrs'
    (path: data: (
      let
        parts = splitString "." path;
        partsLength = builtins.length parts;
      in
      nameValuePair (if partsLength > 1 then path else "${path}.default") data
    ))
    filteredFuncs;

  makeAll = path: configData: (
    let
      parts = splitString "." path;
      make = getAttrFromPath parts plugins;
      pluginName = builtins.elemAt parts 0;
    in
    make ({ inherit configData; }
      // (optionalAttrs (opts ? "${pluginName}") opts.${pluginName}))
  );

  result = mapAttrsToList makeAll funcs;
in
{
  configs = catAttrs "configFile" result;
  shellHook = concatStringsSep "\n" (pkgs.lib.catAttrs "shellHook" result);
}

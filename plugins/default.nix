{ pkgs, lib, engines }:
with pkgs.lib;
let
  # Build a list of all local directory names (same as plugin name)
  plugins = builtins.attrNames
    (filterAttrs (n: v: v == "directory") (builtins.readDir ./.));

  # Create a list of pluginName => import for each plugin
  pluginsList = builtins.map
    (p: {
      "${p}" = import
        (builtins.toPath ./. + "/${p}")
        { inherit pkgs lib engines; };
    })
    plugins;

  # Fold the list back into a single set
  pluginsAttrs = fold (x: y: pkgs.lib.recursiveUpdate x y) { } pluginsList;
in
pluginsAttrs

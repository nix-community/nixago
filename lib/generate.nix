/* Generates a configuration file, returning a derivation to build it and a
  shell hook to manage it.
*/
{ pkgs, lib, plugins }:
request:
with pkgs.lib;
let
  output = request.hook.output;
  shellHookExtra = request.hook.extra;

  # If we're using a plugin, set the cue path to the templates directory
  path =
    if request.plugin.name != ""
    then ../plugins/${request.plugin.name}/templates else request.cue.path;

  # Build the configuration file derivation
  configFile = lib.eval
    {
      inherit output path;
      inherit (request) configData;
      inherit (request.cue) flags format package postBuild;
    };

  # Build shell hook
  name = if request.plugin.name == "" then "custom" else request.plugin.name;
  shellHook =
    lib.makeHook { inherit configFile name; hookConfig = request.hook; };
in
{
  inherit configFile shellHook;
}


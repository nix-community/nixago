/* Generates a configuration file, returning a derivation to build it and a
  shell hook to manage it.
*/
{ pkgs, lib, plugins }:
request:
with pkgs.lib;
let
  output = request.hook.output;
  shellHookExtra = request.hook.extra;

  # If we're using a plugin, set the base path to the templates directory
  path =
    if request.plugin ? name
    then ../plugins/${request.plugin.name}/templates else request.cue.path;

  # Build the configuration file derivation
  configFile = lib.eval
    {
      inherit output path;
      inherit (request) configData;
      inherit (request.cue) flags package postBuild;
    };

  # Build shell hook
  shellHook =
    if request.hook.mode == "copy" then
      (import ./hooks/copy.nix { inherit configFile output shellHookExtra; })
    else
      (import ./hooks/link.nix { inherit configFile output shellHookExtra; });
in
{
  inherit configFile shellHook;
}


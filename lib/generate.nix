/* Generates a configuration file, returning a derivation to build it and a
  shell hook to manage it.
*/
{ pkgs, lib, plugins }:
request:
with pkgs.lib;
let
  output = request.output;
  shellHookExtra = request.shellHookExtra;
  path = ../plugins/${request.name}/templates;

  # Build the configuration file derivation
  configFile = lib.eval
    {
      inherit path;
      inherit (request) configData flags output package postBuild;
    };

  # Build shell hook
  shellHook =
    if request.mode == "copy" then
      (import ./hooks/copy.nix { inherit configFile output shellHookExtra; })
    else
      (import ./hooks/link.nix { inherit configFile output shellHookExtra; });
in
{
  inherit configFile shellHook;
}


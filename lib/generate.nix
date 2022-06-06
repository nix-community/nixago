/* Generates a configuration file, returning a derivation to build it and a
  shell hook to manage it.
*/
{ pkgs, lib, plugins }:
request:
with pkgs.lib;
let
  output = request.output;
  shellHookExtra = request.shellHookExtra;

  # Build the configuration file derivation
  configFile = lib.eval
    {
      inherit (request) configData files flags output postBuild;
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


{ pkgs, lib }:
with pkgs.lib;
{
  mkRequest = modules:
    (evalModules {
      modules = [ ./request.nix ] ++ modules;
    }).config;
}

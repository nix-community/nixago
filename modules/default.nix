{ pkgs, lib }:
with pkgs.lib;
{
  mkGenRequest = modules:
    (evalModules {
      modules = [ ./gen_request.nix ] ++ modules;
    }).config;
}

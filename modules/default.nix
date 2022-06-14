{ pkgs, lib }:
with pkgs.lib;
{
  mkRequest = modules:
    (evalModules {
      modules = [ ./request.nix ]
        ++ modules
        ++ [{ _module.args = { inherit (lib) engines; }; }];
    }).config;
}

{ pkgs, lib, engines }:
with pkgs.lib;
{
  mkRequest = modules:
    (evalModules {
      modules = [ ./request.nix ]
        ++ modules
        ++ [{ _module.args = { inherit engines; }; }];
    }).config;
}

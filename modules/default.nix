{ pkgs, lib }:
with pkgs.lib;
{
  mkRequest = modules:
    (evalModules {
      modules = [ ./request.nix ] ++ modules;
    }).config;
  # TODO: Rename this once we convert everything over to the new framework
  mkRequestv2 = modules:
    (evalModules {
      modules = [ ./requestv2.nix ]
        ++ modules
        ++ [{ _module.args = { inherit (lib) engines; }; }];
    }).config;
}

{ pkgs, lib }:
{
  mkModule = { data, files, output, shellHookExtra ? "", flags ? { } }:
    with pkgs.lib;
    (evalModules {
      modules = [
        ../modules/generator.nix
        {
          inherit data files output shellHookExtra;
        }
      ];
      specialArgs = ({ inherit (lib) nix-cue; inherit pkgs; } // flags);
    }).config;
}

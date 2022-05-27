{ pkgs, lib }:
{
  mkTemplate = { data, files, output, shellHookExtra ? "", flags ? { } }:
    with pkgs.lib;
    (evalModules {
      modules = [
        ../modules/template.nix
        {
          inherit data files output shellHookExtra;
        }
      ];
      specialArgs = ({ inherit (lib) nix-cue; inherit pkgs; } // flags);
    }).config;
}

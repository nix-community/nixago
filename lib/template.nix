{ pkgs, lib }:
{ data, files, output, shellHookExtra ? "", flags ? { } }:
with pkgs.lib;
let
  result = evalModules {
    modules = [
      ../modules/template.nix
      {
        inherit data files output shellHookExtra;
      }
    ];
    specialArgs = ({ inherit (lib) nix-cue; inherit pkgs; } // flags);
  };
in
result.config


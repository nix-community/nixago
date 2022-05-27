{ pkgs, lib }:
{
  mkShellHook = configs: builtins.concatStringsSep "\n" (pkgs.lib.catAttrs "shellHook" configs);
  mkTemplate = import ./template.nix { inherit pkgs lib; };
}

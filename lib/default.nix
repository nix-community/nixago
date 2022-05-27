{ pkgs, lib }:
{
  /* Combines the shellHook from multiple configurations into one.
  */
  mkShellHook = configs: builtins.concatStringsSep "\n" (pkgs.lib.catAttrs "shellHook" configs);

  mkTemplate = import ./template.nix { inherit pkgs lib; };
}

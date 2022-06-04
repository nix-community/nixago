{ pkgs, lib, plugins }:
{
  eval = import ./eval.nix { inherit pkgs lib plugins; };

  make = import ./make.nix { inherit pkgs lib plugins; };

  mkAll = import ./all.nix { inherit pkgs lib plugins; };

  /* Combines the shellHook from multiple configurations into one.
  */
  mkShellHook = configs:
    builtins.concatStringsSep "\n" (pkgs.lib.catAttrs "shellHook" configs);

  mkTemplate = import ./template.nix { inherit pkgs lib plugins; };
}

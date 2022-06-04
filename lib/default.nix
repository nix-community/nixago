{ pkgs, lib, plugins }:
{
  eval = import ./eval.nix { inherit pkgs lib plugins; };

  genConfig = import ./generate.nix { inherit pkgs lib plugins; };

  make = import ./make.nix { inherit pkgs lib plugins; };

  mkAll = import ./all.nix { inherit pkgs lib plugins; };

  /* Combines the shellHook from multiple configurations into one.
  */
  mkShellHook = configs:
    builtins.concatStringsSep "\n" (pkgs.lib.catAttrs "shellHook" configs);

  overrideData = config: newData:
    pkgs.lib.recursiveUpdateUntil
      (p: l: r: p == [ "configData" ])
      config
      { configData = newData; };
}

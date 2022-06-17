{ pkgs, lib, engines, runTests }:
with pkgs.lib;
let
  tests = fold (x: y: recursiveUpdate x y) { } [
    (import ./nix { inherit runTests; })
    (import ./cue { inherit runTests; })
    ({
      hook = import ./hook { inherit pkgs lib engines; };
    })
  ];
in
tests

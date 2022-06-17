{ pkgs, runTests }:
with pkgs.lib;
let
  tests = fold (x: y: recursiveUpdate x y) { } [
    (import ./nix { inherit runTests; })
  ];
in
tests

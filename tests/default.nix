{ pkgs, runTests }:
with pkgs.lib;
let
  tests = fold (x: y: recursiveUpdate x y) { } [
    (import ./nix { inherit runTests; })
    (import ./cue { inherit runTests; })
  ];
in
tests

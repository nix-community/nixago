{ pkgs, runTest }:
with pkgs.lib;
let
  # Build a list of all local directory names (test names)
  tests = builtins.attrNames
    (filterAttrs (n: v: v == "directory") (builtins.readDir ./.));

  # Create a list of testName => import for each test
  testsList = builtins.map
    (p: {
      "${p}" = import (builtins.toPath ./. + "/${p}") { inherit runTest; };
    })
    tests;

  # Fold the list back into a single set
  testsAttrs = fold (x: y: recursiveUpdate x y) { } testsList;
in
testsAttrs

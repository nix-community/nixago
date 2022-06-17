/* Common test runner used across all tests
*/
{ pkgs, engines }:
{ name, tests }:
with pkgs.lib;
let
  ders = builtins.map
    (test:
      let
        result = engines.${name} test.args test.request;
      in
      {
        "${name}.${test.name}" = pkgs.runCommand "test.${name}.${test.name}"
          { }
          ''
            cmp "${test.expected}" "${result}"
            touch $out
          '';
      }
    )
    tests;
in
fold (x: y: recursiveUpdate x y) { } ders

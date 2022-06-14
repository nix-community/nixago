/* Common test runner used across all tests
*/
{ pkgs, lib, plugins }:
{ name, input, expected }:
let
  # Call make
  result = lib.make (plugins.${name} input);

  # Compare the result from make with the expected result
  der = pkgs.runCommand "test.${name}"
    { }
    ''
      cmp "${expected}" "${result.configFile}"
      touch $out
    '';
in
der

/* Common test runner used across all tests
*/
{ pkgs, lib, plugins }:
{ name, configData, expected, type ? "", output ? "", mode ? "" }:
let
  # Call make
  result = lib.make {
    inherit configData mode name output type;
  };

  # Compare the result from make with the expected result
  der = pkgs.runCommand "test.${name}"
    { }
    ''
      cmp "${expected}" "${result.configFile}"
      touch $out
    '';
in
der

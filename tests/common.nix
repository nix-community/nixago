{ pkgs, lib, plugins }:
{ name, configData, expected, type ? "", output ? "", mode ? "" }:
let
  result = lib.make {
    inherit configData mode name output type;
  };
  der = pkgs.runCommand "test.${name}"
    { }
    ''
      cmp "${expected}" "${result.configFile}"
      touch $out
    '';
in
der

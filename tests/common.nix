{ pkgs, plugins }:
path: expected: configData: opts:
let
  parts = pkgs.lib.splitString "." path;
  plugin = builtins.elemAt parts 0;
  make = pkgs.lib.getAttrFromPath parts plugins;
  output = make ({ inherit configData; } // opts);

  result = pkgs.runCommand "test.${plugin}"
    { }
    ''
      cmp "${expected}" "${output.configFile}"
      touch $out
    '';
in
result

{ pkgs, lib, engines }:
let
  linkRequest = {
    format = "json";
    output = "test.json";
    configData = {
      field1 = "value1";
      field2 = 42;
      field3 = false;
    };
  };

  copyRequest = linkRequest // {
    hook =
      { mode = "copy"; extra = "touch test.txt"; };
  };

  linkHook = pkgs.writeShellScript "link" (lib.make linkRequest).shellHook;
  copyHook = pkgs.writeShellScript "copy" (lib.make copyRequest).shellHook;
in
pkgs.runCommand "test.hook" { }
  ''
    echo "Testing link hook"
    source ${linkHook}
    stat test.json
    rm test.json

    echo "Testing copy hook"
    source ${copyHook}
    stat test.json
    stat test.txt

    touch $out
  ''

{ pkgs, plugins }:
let
  output = plugins.just.mkConfig {
    config = {
      tasks = {
        task1 = [
          ''echo "Doing the thing"''
          "@doThing"
        ];
      };
    };
  };

  result = pkgs.runCommand "test.just"
    { }
    ''
      cmp "${./expected.txt}" "${output.configFile}"
      touch $out
    '';
in
result

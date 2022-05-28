{ pkgs, plugins }:
let
  output = plugins.prettier.mkConfig {
    arrowParens = "always";
    bracketSpacing = true;
    tabWidth = 80;
    overrides = [
      {
        files = "*.js";
        options = {
          semi = true;
        };
      }
    ];
  };

  result = pkgs.runCommand "test.prettier"
    { }
    ''
      cmp "${./expected.json}" "${output.configFile}"
      touch $out
    '';
in
result

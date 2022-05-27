{ pkgs, lib }:
let
  output = lib.mkPreCommit {
    config = {
      repos = [
        {
          repo = "https://github.com/my/repo";
          rev = "1.0";
          hooks = [
            {
              id = "my-hook";
            }
          ];
        }
      ];
    };
  };

  result = pkgs.runCommand "test.pre-commit"
    { }
    ''
      cmp "${./expected.yml}" "${output.configFile}"
      touch $out
    '';
in
result

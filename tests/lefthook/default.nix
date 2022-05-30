{ pkgs, plugins }:
let
  output = plugins.lefthook.mkConfig {
    commit-msg = {
      scripts = {
        template_checker = { runner = "bash"; };
      };
    };
    pre-commit = {
      commands = {
        stylelint = {
          tags = "frontend style";
          glob = "*.js";
          run = "yarn stylelint {staged_files}";
        };
        rubocop = {
          tags = "backend style";
          glob = "*.rb";
          exclude = "application.rb|routes.rb";
          run = "bundle exec rubocop --force-exclusion {all_files}";
        };
      };
      scripts = {
        "good_job.js" = { runner = "node"; };
      };
    };
  };

  result = pkgs.runCommand "test.lefthook"
    { }
    ''
      cmp "${./expected.yml}" "${output.configFile}"
      touch $out
    '';
in
result

{ plugins, tools }:
let
  colors = {
    black = "#000000";
    blue = "#1565C0";
    lightBlue = "#64B5F6";
    green = "#4CAF50";
    grey = "#A6A6A6";
    lightGreen = "#81C784";
    gold = "#FDD835";
    orange = "#FB8C00";
    purple = "#AB47BC";
    red = "#F44336";
    yellow = "#FFEE58";
  };

  # Configs

  # Github
  github = {
    repository = {
      name = "nixago";
      description = "Generate configuration files using Nix";
      homepage = "https://nix-community.github.io/nixago/";
      topics = "nix, cuelang, development, developer-tools, development-environment";
      default_branch = "master";
    };
    labels = [
      # Statuses
      {
        name = "Status: Abdandoned";
        description = "This issue has been abdandoned";
        color = colors.black;
      }
      {
        name = "Status: Accepted";
        description = "This issue has been accepted";
        color = colors.green;
      }
      {
        name = "Status: Available";
        description = "This issue is available for assignment";
        color = colors.lightGreen;
      }
      {
        name = "Status: Blocked";
        description = "This issue is in a blocking state";
        color = colors.red;
      }
      {
        name = "Status: In Progress";
        description = "This issue is actively being worked on";
        color = colors.grey;
      }
      {
        name = "Status: On Hold";
        description = "This issue is not currently being worked on";
        color = colors.red;
      }
      {
        name = "Status: Pending";
        description = "This issue is in a pending state";
        color = colors.yellow;
      }
      {
        name = "Status: Review Needed";
        description = "This issue is pending a review";
        color = colors.gold;
      }

      # Types
      {
        name = "Type: Bug";
        description = "This issue targets a bug";
        color = colors.red;
      }
      {
        name = "Type: Feature";
        description = "This issue targets a new feature";
        color = colors.lightBlue;
      }
      {
        name = "Type: Maintenance";
        description = "This issue targets general maintenance";
        color = colors.orange;
      }
      {
        name = "Type: Question";
        description = "This issue contains a question";
        color = colors.purple;
      }
      {
        name = "Type: Security";
        description = "This issue targets a security vulnerability";
        color = colors.red;
      }

      # Priorities
      {
        name = "Priority: Critical";
        description = "This issue is prioritized as critical";
        color = colors.red;
      }
      {
        name = "Priority: High";
        description = "This issue is prioritized as high";
        color = colors.orange;
      }
      {
        name = "Priority: Medium";
        description = "This issue is prioritized as medium";
        color = colors.yellow;
      }
      {
        name = "Priority: Low";
        description = "This issue is prioritized as low";
        color = colors.green;
      }

      # Effort
      {
        name = "Effort: 1";
        color = colors.green;
      }
      {
        name = "Effort: 2";
        color = colors.lightGreen;
      }
      {
        name = "Effort: 3";
        color = colors.yellow;
      }
      {
        name = "Effort: 4";
        color = colors.orange;
      }
      {
        name = "Effort: 5";
        color = colors.red;
      }
    ];
  };

  # Conform
  conform = {
    commit = {
      header = { length = 89; };
      conventional = {
        types = [
          "build"
          "chore"
          "ci"
          "docs"
          "feat"
          "fix"
          "perf"
          "refactor"
          "style"
          "test"
        ];
        scopes = [
          "conform"
          "ghsettings"
          "just"
          "lefthook"
          "pre-commit"
          "prettier"
          "core"
          "flake"
        ];
      };
    };
  };

  # Just
  just = {
    tasks = {
      check = [
        "@${tools.nixpkgs-fmt.exe} --check flake.nix $(git ls-files '**/*.nix')"
        "@${tools.prettier.exe} --check ."
        "@${tools.typos.exe}"
        "@nix flake check"
      ];
      check-docs = [
        "@${tools.typos.exe}"
      ];
      make-docs = [
        "@rm -rf docs/book"
        "@rm -rf docs/*.js"
        "@cd docs && mdbook-mermaid install"
        "@cd docs && mdbook build"
      ];
      fmt = [
        "@${tools.nixpkgs-fmt.exe} flake.nix $(git ls-files '**/*.nix')"
        "@${tools.prettier.exe} -w ."
      ];
    };
  };

  # Lefthook
  lefthook = {
    commit-msg = {
      commands = {
        conform = {
          run = "${tools.conform.exe} enforce --commit-msg-file {1}";
        };
      };
    };
    pre-commit = {
      commands = {
        nixpkgs-fmt = {
          run = "${tools.nixpkgs-fmt.exe} --check {staged_files}";
          glob = "*.nix";
        };
        prettier = {
          run = "${tools.prettier.exe} --check {staged_files}";
          glob = "*.{yaml,yml,md}";
        };
        typos = {
          run = "${tools.typos.exe} {staged_files}";
        };
      };
    };
  };

  # Prettier
  prettier = {
    configData = {
      proseWrap = "always";
    };
  };
  prettier-ignore = {
    configData = [
      "docs/book"
      "docs/*.js"
      ".github/settings.yml"
      ".direnv"
      ".conform.yaml"
      ".prettierrc.json"
      "tests"
      "CHANGELOG.md"
      "lefthook.yml"
    ];
    type = "ignore";
  };

in
[
  (plugins.ghsettings github)
  (plugins.conform conform)
  (plugins.just just)
  (plugins.lefthook lefthook)
  (plugins.prettier prettier)
  (plugins.prettier prettier-ignore)
]


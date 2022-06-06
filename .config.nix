{ tools }:
[
  # Conform
  {
    name = "conform";
    configData = {
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
  }
  # Just
  {
    name = "just";
    configData = {
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
          "@cd docs && mdbook build"
        ];
        fmt = [
          "@${tools.nixpkgs-fmt.exe} flake.nix $(git ls-files '**/*.nix')"
          "@${tools.prettier.exe} -w ."
        ];
      };
    };
  }
  # Lefthook
  {
    name = "lefthook";
    configData = {
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
  }
  # Prettier
  {
    name = "prettier";
    configData = {
      proseWrap = "always";
    };
  }
  {
    name = "prettier";
    type = "ignore";
    configData = [
      ".direnv"
      ".conform.yaml"
      ".prettierrc.json"
      "tests"
      "CHANGELOG.md"
      "lefthook.yml"
    ];
  }
]


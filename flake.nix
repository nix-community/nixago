{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        version = "1.0.0"; # x-release-please-version

        # Setup pkgs
        pkgs = import nixpkgs {
          inherit system;
        };

        # Internal attributes
        lib = self.lib.${system};
        plugins = self.plugins.${system};

        # Test runner
        runTest = import ./tests/common.nix { inherit pkgs plugins; };

        # Helper for aggregating development tools
        mkTools = tools: (builtins.listToAttrs
          (
            builtins.map
              (tool:
                pkgs.lib.nameValuePair (pkgs.lib.getName tool) { pkg = tool; exe = pkgs.lib.getExe tool; })
              tools
          ) // { all = tools; });

        # TODO: Remove when https://github.com/NixOS/nixpkgs/pull/175771 is merged
        conform = pkgs.buildGoModule rec {
          pname = "conform";
          version = "0.1.0-alpha.25";

          src = pkgs.fetchFromGitHub {
            rev = "v${version}";
            owner = "siderolabs";
            repo = "conform";
            sha256 = "sha256-WgWgigpqPoEBY4tLjbzK02WFwrCWPGQWJ5eakLv5IWw=";
          };

          vendorSha256 = "sha256-Oigt7tAK4jhBQtfG1wdLHqi11NWu6uJn5fmuqTmR76E=";

          doCheck = false;
        };

        # Define development tools
        tools = mkTools [
          conform
          pkgs.cue
          pkgs.just
          pkgs.lefthook
          pkgs.mdbook
          pkgs.nixpkgs-fmt
          pkgs.nodePackages.prettier
          pkgs.typos
        ];

        # Define development tool configuration
        configurations = {
          # Conform configuration
          "conform" = {
            commit = {
              header = { length = 89; };
              conventional = {
                types = [
                  "build"
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
          # Just configuration
          "just" = {
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
          # Lefthook configuration
          "lefthook" = {
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
          "prettier" = {
            proseWrap = "always";
          };
          "prettier.mkIgnoreConfig" = [
            ".direnv"
            ".conform.yaml"
            ".prettierrc.json"
            "tests"
            "CHANGELOG.md"
            "lefthook.yml"
          ];
        };
      in
      {
        # Load lib functions
        lib = (import ./lib { inherit pkgs lib; });

        # Load plugins
        plugins = import ./plugins { inherit pkgs lib; };

        # Local tests
        checks = import ./tests { inherit pkgs runTest; };

        # Local development shell
        devShells = {
          default = pkgs.mkShell {
            shellHook = (lib.mkAll configurations).shellHook;
            packages = tools.all;
          };
        };
      }
    );
}

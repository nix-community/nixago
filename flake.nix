{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        lib = self.lib.${system};
        plugins = self.plugins.${system};

        mkTools = tools: (builtins.listToAttrs
          (
            builtins.map
              (tool:
                pkgs.lib.nameValuePair (pkgs.lib.getName tool) { pkg = tool; exe = pkgs.lib.getExe tool; })
              tools
          ) // { all = tools; });

        # Define development tools
        tools = mkTools [
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
          "prettier.mkIgnoreConfig" = [
            ".direnv"
            "tests"
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
        checks = {
          just = pkgs.callPackage ./tests/just { inherit pkgs plugins; };
          lefthook = pkgs.callPackage ./tests/lefthook { inherit pkgs plugins; };
          pre-commit = pkgs.callPackage ./tests/pre-commit { inherit pkgs plugins; };
          prettier = pkgs.callPackage ./tests/prettier { inherit pkgs plugins; };
        };

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

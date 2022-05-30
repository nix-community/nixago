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
          # Temp fix for: https://github.com/NixOS/nixpkgs/issues/175032
          overlays = [
            (
              self: super: {
                python39 = super.python39.override {
                  packageOverrides = python-self: python-super: {
                    watchdog = python-super.watchdog.overrideAttrs (oldAttrs: {
                      disabledTestPaths = [
                        "tests/test_inotify_buffer.py"
                        "tests/test_emitter.py"
                        "tests/test_0_watchmedo.py"
                        "tests/test_fsevents.py"
                      ];
                    });
                  };
                };
              }
            )
          ];
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
          pkgs.mkdocs
          pkgs.nixpkgs-fmt
          pkgs.nodePackages.prettier
        ];

        # Define development dependencies
        deps = [
          pkgs.python39Packages.mkdocs-material
          pkgs.python39Packages.pygments
          pkgs.python39Packages.pymdown-extensions
        ];

        # Define development tool configuration
        configurations = {
          # Just configuration
          "just.mkConfig" = {
            tasks = {
              check = [
                "@${tools.nixpkgs-fmt.exe} --check flake.nix $(git ls-files '**/*.nix')"
                "@${tools.prettier.exe} --check ."
                "@nix flake check"
                "@mkdocs build --strict && rm -rf site"
              ];
              deploy = [
                "@mkdocs gh-deploy --force"
              ];
              fmt = [
                "@${tools.nixpkgs-fmt.exe} flake.nix $(git ls-files '**/*.nix')"
                "@${tools.prettier.exe} -w ."
              ];
            };
          };
          # Lefthook configuration
          "lefthook.mkConfig" = {
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

        # The shell does not currently work on x86_64-darwin due to a
        # downstream dependency of mkdocs.
        # See: https://github.com/NixOS/nixpkgs/pull/171388
        devShells = nixpkgs.lib.optionalAttrs (!builtins.elem system [ "x86_64-darwin" ]) {
          default = pkgs.mkShell {
            shellHook = (lib.mkAll configurations).shellHook;
            packages = tools.all ++ deps;
          };
        };
      }
    );
}

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
          pkgs.mkdocs
          pkgs.nixpkgs-fmt
          pkgs.pre-commit
        ];

        # Define development dependencies
        deps = [
          pkgs.python39Packages.mkdocs-material
          pkgs.python39Packages.pygments
          pkgs.python39Packages.pymdown-extensions
        ];

        # Create pre-commit configuration
        preCommitConfig = {
          nixpkgs-fmt = {
            entry = tools.nixpkgs-fmt.exe;
            language = "system";
            files = "\\.nix";
          };
        };
        preCommit = plugins.pre-commit.mkLocalConfig { config = preCommitConfig; };

        # Create justfile
        justConfig = {
          tasks = {
            check = [
              "@${tools.nixpkgs-fmt.exe} --check flake.nix $(git ls-files '**/*.nix')"
              "@nix flake check"
              "@mkdocs build --strict && rm -rf site"
            ];
            deploy = [
              "@mkdocs gh-deploy --force"
            ];
            fmt = [
              "@${tools.nixpkgs-fmt.exe} flake.nix $(git ls-files '**/*.nix')"
            ];
          };
        };
        just = plugins.just.mkConfig { config = justConfig; };
      in
      {
        # Load lib functions
        lib = (import ./lib { inherit pkgs lib; });

        # Load plugins
        plugins = import ./plugins { inherit pkgs lib; };

        # Local tests
        checks = {
          just = pkgs.callPackage ./tests/just { inherit pkgs plugins; };
          pre-commit = pkgs.callPackage ./tests/pre-commit { inherit pkgs plugins; };
        };

        # Local shell for development.
        # The shell does not currently build on i686-linux machines due to a
        # downstream dependency of pkgs.pre-commit.
        # See: https://github.com/NixOS/nixpkgs/issues/174847
        # The shell also does not currently work on x86_64-darwin due to a
        # downstream dependency of mkdocs.
        # See: https://github.com/NixOS/nixpkgs/pull/171388
        devShells = nixpkgs.lib.optionalAttrs (!builtins.elem system [ "i686-linux" "x86_64-darwin" ]) {
          default = pkgs.mkShell {
            shellHook = lib.mkShellHook [ preCommit just ];
            packages = tools.all ++ deps;
          };
        };
      }
    );
}

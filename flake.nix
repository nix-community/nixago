{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    nix-cue.url = "github:jmgilman/nix-cue";
    nix-cue.inputs.nixpkgs.follows = "nixpkgs";
    nix-cue.inputs.flake-utils.follows = "flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, nix-cue }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
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
          pkgs.nixpkgs-fmt
          pkgs.pre-commit
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
            fmt = [
              "@${tools.nixpkgs-fmt.exe} $(git ls-files **/*.nix)"
            ];
          };
        };
        just = plugins.just.mkConfig { config = justConfig; };
      in
      {
        # Load lib functions
        lib = (import ./lib { inherit pkgs lib; }) // { nix-cue = nix-cue.lib.${system}; };

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
        devShells = nixpkgs.lib.optionalAttrs (system != "i686-linux") {
          default = pkgs.mkShell {
            shellHook = lib.mkShellHook [ preCommit just ];
            packages = tools.all;
          };
        };
      }
    );
}

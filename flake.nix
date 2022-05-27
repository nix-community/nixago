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

        preCommitConfig = {
          repos = [
            {
              repo = "local";
              hooks = [
                {
                  id = "nixpkgs-fmt";
                  name = "nixpkgs-fmt";
                  entry = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
                  language = "system";
                  files = "\\.nix";
                }
              ];
            }
          ];
        };
        preCommit = plugins.pre-commit.mkConfig { config = preCommitConfig; };

        justConfig = {
          tasks = {
            fmt = [
              "@${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt $(git ls-files **/*.nix)"
            ];
          };
        };
        just = plugins.just.mkConfig { config = justConfig; };
      in
      {
        checks = {
          pre-commit = pkgs.callPackage ./tests/pre-commit { inherit pkgs plugins; };
        };

        lib = {
          nix-cue = nix-cue.lib.${system};
          common = import ./lib/common.nix { inherit pkgs lib; };
          mkJust = import ./lib/just.nix { inherit pkgs lib; };
          mkPreCommit = import ./lib/pre-commit.nix { inherit pkgs lib; };
        };

        plugins = import ./plugins { inherit pkgs lib; };

        devShell = pkgs.mkShell {
          shellHook = preCommit.shellHook + "\n" + just.shellHook;
          packages = [
            pkgs.cue
            pkgs.just
            pkgs.pre-commit
          ];
        };
      }
    );
}

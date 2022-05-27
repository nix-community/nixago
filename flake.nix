{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    nix-cue.url = "github:jmgilman/nix-cue";
  };

  outputs = { self, nixpkgs, flake-utils, nix-cue }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        lib = self.lib.${system};

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
        preCommit = lib.mkPreCommit { config = preCommitConfig; };

        justConfig = {
          tasks = {
            fmt = [
              "@${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt $(git ls-files **/*.nix)"
            ];
          };
        };
        just = lib.mkJust { config = justConfig; };
      in
      {
        lib = {
          nix-cue = nix-cue.lib.${system};
          common = import ./lib/common.nix { inherit pkgs lib; };
          mkJust = import ./lib/just.nix { inherit pkgs lib; };
          mkPreCommit = import ./lib/pre-commit.nix { inherit pkgs lib; };
        };

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

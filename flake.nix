{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        config = {
          repos = [
            {
              repo = "local";
              hooks = [
                {
                  id = "nixpkgs-fmt";
                  entry = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
                  language = "system";
                  files = "\\.nix";
                }
              ];
            }
          ];
        };
      in
      {
        lib = {
          mkConfig = import ./lib/pre-commit.nix;
        };

        devShell = pkgs.mkShell {
          shellHook = (import ./lib/pre-commit.nix {
            inherit pkgs config;
            pre-commit = pkgs.pre-commit;
          }).shellHook;
          packages = [
            pkgs.pre-commit
          ];
        };
      }
    );
}

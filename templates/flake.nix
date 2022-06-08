{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nixago.url = "github:jmgilman/nixago";
    nixago.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixago, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Setup nixpkgs
        pkgs = import nixpkgs {
          inherit system;
        };

        # Define development tool configuration
        configs = [ ];
      in
      rec {
        # Configure local development shell
        devShells = {
          default = pkgs.mkShell {
            shellHook = (nixago.lib.${system}.makeAll configs).shellHook;
          };
        };
      }
    );
}

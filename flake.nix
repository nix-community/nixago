{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        version = "2.1.0"; # x-release-please-version

        lib = (import ./lib { inherit pkgs lib plugins; });
        plugins = import ./plugins { inherit pkgs lib; };

        # Setup pkgs
        pkgs = import nixpkgs {
          inherit system;
        };

        # Import test runner
        runTest = import ./tests/common.nix { inherit pkgs lib plugins; };

        # Helper function for aggregating development tools
        mkTools = tools: (builtins.listToAttrs
          (
            builtins.map
              (tool:
                pkgs.lib.nameValuePair (pkgs.lib.getName tool) { pkg = tool; exe = pkgs.lib.getExe tool; })
              tools
          ) // { all = tools; });

        # Define development tools
        tools = mkTools [
          pkgs.conform
          pkgs.cue
          pkgs.just
          pkgs.lefthook
          pkgs.mdbook
          pkgs.mdbook-mermaid
          pkgs.nixpkgs-fmt
          pkgs.nodePackages.prettier
          pkgs.typos
        ];

        # Define development tool configuration (with Nixago!)
        configs = import ./.config.nix { inherit tools; };
      in
      rec {
        # Expose external API
        inherit lib;

        # Add local tests
        checks = import ./tests { inherit pkgs runTest; };

        # Configure local development shell
        devShells = {
          default = pkgs.mkShell {
            shellHook = (lib.makeAll configs).shellHook;
            packages = tools.all;
          };
        };
      }
    );
}

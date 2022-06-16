{ runTest }:
let
  name = "pre-commit";
  expected = ./expected.yml;
  input = {
    nixpkgs-fmt = {
      entry = "nixpkgs-fmt";
      language = "system";
      files = "\\.nix";
    };
  };
in
runTest {
  inherit input expected name;
}

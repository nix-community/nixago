{ runTest }:
let
  name = "prettier";
  expected = ./expected.json;
  input = {
    arrowParens = "always";
    bracketSpacing = true;
    tabWidth = 80;
    overrides = [
      {
        files = "*.js";
        options = {
          semi = true;
        };
      }
    ];
  };
in
runTest {
  inherit input expected name;
}

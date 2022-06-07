{ runTest }:
let
  name = "prettier";
  expected = ./expected.json;
  configData = {
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
  inherit configData expected name;
}

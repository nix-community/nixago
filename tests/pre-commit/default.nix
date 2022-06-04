{ runTest }:
let
  name = "pre-commit";
  expected = ./expected.yml;
  configData = {
    repos = [
      {
        repo = "https://github.com/my/repo";
        rev = "1.0";
        hooks = [
          {
            id = "my-hook";
          }
        ];
      }
    ];
  };
in
runTest {
  inherit configData expected name;
}

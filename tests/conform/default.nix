{ runTest }:
let
  name = "conform";
  expected = ./expected.yml;
  input = {
    commit = {
      header = {
        length = 89;
        imperative = true;
        case = "lower";
        invalidLastCharacters = ".";
      };
      gpg = {
        required = false;
        identity = {
          gitHubOrganization = "some-organization";
        };
      };
      conventional = {
        types = [
          "type"
        ];
        scopes = [
          "scope"
        ];
      };
    };
    license = {
      skipPaths = [
        ".git/"
        "build*/"
      ];
      allowPrecedingComments = false;
    };
  };
in
runTest {
  inherit input expected name;
}

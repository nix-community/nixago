{ runTest }:
let
  name = "conform";
  expected = ./expected.yml;
  configData = {
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
  inherit configData expected name;
}

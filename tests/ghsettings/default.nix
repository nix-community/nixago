{ runTest }:
let
  name = "ghsettings";
  expected = ./expected.yml;
  configData = {
    repository = {
      name = "repo-name";
      description = "description of repo";
      homepage = "https://example.github.io/";
      private = false;
    };
    labels = [
      {
        name = "bug";
        color = "CC0000";
        description = "An issue with the system";
      }
      {
        name = "feature";
        color = "#336699";
        description = "New functionality";
      }
    ];
    milestones = [
      {
        title = "milestone-title";
        description = "milestone-description";
        state = "open";
      }
    ];
  };
in
runTest {
  inherit configData expected name;
}

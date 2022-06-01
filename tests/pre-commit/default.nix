{ runTest }:
runTest "pre-commit.mkConfig" ./expected.yml {
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
}

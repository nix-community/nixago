{ runTest }:
runTest "prettier.mkConfig" ./expected.json
{
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
}
{ }

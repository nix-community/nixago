{ runTests }:
runTests {
  name = "nix";
  tests = [
    (import ./json)
    (import ./ini)
    (import ./toml)
    (import ./yaml)
  ];
}

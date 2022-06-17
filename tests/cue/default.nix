{ runTests }:
runTests {
  name = "cue";
  tests = [
    (import ./basic)
    (import ./advanced)
  ];
}

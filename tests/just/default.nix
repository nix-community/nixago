{ runTest }:
let
  name = "just";
  expected = ./expected.txt;
  input = {
    head = ''
      var := "value"
    '';
    tasks = {
      task1 = [
        ''echo "Doing the thing"''
        "@doThing"
      ];
    };
  };
in
runTest {
  inherit input expected name;
}

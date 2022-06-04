{ runTest }:
let
  name = "just";
  expected = ./expected.txt;
  configData = {
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
  inherit configData expected name;
}

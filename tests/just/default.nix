{ runTest }:
runTest "just.mkConfig" ./expected.txt {
  head = ''
    var := "value"
  '';
  tasks = {
    task1 = [
      ''echo "Doing the thing"''
      "@doThing"
    ];
  };
}

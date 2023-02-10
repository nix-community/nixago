{
  name = "advanced";
  expected = ./expected.txt;
  args = {
    files = [./template.cue];
    flags = {
      expression = "rendered";
    };
    preHook = ''
      echo "hook" > pre.txt
    '';
    postHook = ''
      cat pre.txt >> $out
    '';
  };
  request = {
    format = "text";
    output = "test.txt";
    data = {
      first_name = "john";
      last_name = "doe";
      address = "123 Lane";
    };
  };
}

{
  name = "basic";
  expected = ./expected.yml;
  args = {
    files = [./template.cue];
  };
  request = {
    format = "yaml";
    output = "test.yml";
    data = {
      field1 = "value1";
      field2 = 42;
      field3 = false;
    };
  };
}

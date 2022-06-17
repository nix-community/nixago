{
  name = "basic";
  expected = ./expected.yml;
  args = {
    files = [ ./template.cue ];
  };
  request = {
    format = "yaml";
    output = "test.yml";
    configData = {
      field1 = "value1";
      field2 = 42;
      field3 = false;
    };
  };
}

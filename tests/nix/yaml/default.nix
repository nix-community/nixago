{
  name = "yaml";
  expected = ./expected.yml;
  args = {};
  request = {
    format = "yaml";
    output = "test.yaml";
    data = {
      field1 = "value1";
      field2 = 42;
      field3 = false;
    };
  };
}

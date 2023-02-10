{
  name = "toml";
  expected = ./expected.toml;
  args = {};
  request = {
    format = "toml";
    output = "test.toml";
    data = {
      field1 = "value1";
      field2 = 42;
      field3 = false;
    };
  };
}

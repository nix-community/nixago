{
  name = "ini";
  expected = ./expected.ini;
  args = {};
  request = {
    format = "ini";
    output = "test.ini";
    data = {
      config = {
        field1 = "value1";
        field2 = 42;
        field3 = false;
      };
    };
  };
}

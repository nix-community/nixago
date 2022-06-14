{ pkgs, lib }:
{ configData, type ? "default" }:
with pkgs.lib;
{
  inherit configData;
  format = "json";
  output = ".prettierrc.json";
  engine = lib.engines.cue {
    path = ./templates;
    package = type;
  };
} // optionalAttrs (type == "ignore") {
  configData = { data = configData; };
  format = "text";
  output = ".prettierignore";
  engine = lib.engines.cue {
    path = ./templates;
    package = "ignore";
    flags = {
      expression = "rendered";
    };
  };
}

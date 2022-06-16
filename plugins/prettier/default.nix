{ pkgs, lib, engines }:
{ configData, type ? "default" }:
with pkgs.lib;
{
  inherit configData;
  format = "json";
  output = ".prettierrc.json";
  engine = engines.cue {
    files = [ ./templates/default.cue ];
  };
} // optionalAttrs (type == "ignore") {
  configData = { data = configData; };
  format = "text";
  output = ".prettierignore";
  engine = engines.cue {
    files = [ ./templates/ignore.cue ];
    flags = {
      expression = "rendered";
    };
  };
}

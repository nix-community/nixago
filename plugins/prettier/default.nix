{ pkgs, lib }:
{ configData, type ? "default" }:
with pkgs.lib;
{
  inherit configData;
  format = "json";
  output = ".prettierrc.json";
  engine = lib.engines.cue {
    files = [ ./templates/default.cue ];
  };
} // optionalAttrs (type == "ignore") {
  configData = { data = configData; };
  format = "text";
  output = ".prettierignore";
  engine = lib.engines.cue {
    files = [ ./templates/ignore.cue ];
    flags = {
      expression = "rendered";
    };
  };
}

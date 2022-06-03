{ pkgs, lib }:
{ configData }:
with pkgs.lib;
let
  files = [ ./template_ignore.cue ];
  output = ".prettierignore";
  flags = {
    expression = "rendered";
    out = "text";
  };

  # Generate the module
  result = lib.mkTemplate {
    inherit files output flags;
    configData = { data = configData; };
  };
in
{
  inherit (result) configFile shellHook;
}

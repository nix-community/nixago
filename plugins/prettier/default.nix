{ pkgs, lib }:
config:
let
  files =
    if config.type == "ignore" then
      [ ./template_ignore.cue ] else [ ./template.cue ];
  defaultOutput =
    if config.type == "ignore" then ".prettierignore" else ".prettierrc.json";
  flags =
    if config.type == "ignore" then {
      expression = "rendered";
      out = "text";
    } else { };
  configDataFinal =
    if config.type == "ignore" then
      { data = config.configData; } else config.configData;
in
lib.genConfig {
  inherit defaultOutput files flags;
  config = lib.overrideData config configDataFinal;
}

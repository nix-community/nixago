{ pkgs, lib }:
config:
let
  inherit (config) configData;
  files = [ ./template.cue ];
  defaultOutput = ".justfile";

  # Run the formatter since the output from the Go template engine is ugly
  postBuild = ''
    cat $out
    ${pkgs.just}/bin/just --unstable --fmt -f $out
  '';

  # Need to explicitly tell cue what expression to render as text output
  flags = {
    expression = "rendered";
    out = "text";
  };

  # Wrap data for cue to pick it up
  configDataFinal = { data = config.configData; };
in
lib.genConfig {
  inherit defaultOutput files postBuild flags;
  config = lib.overrideData config configDataFinal;
}

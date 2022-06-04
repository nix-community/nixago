{ pkgs, lib }:
{ configData, mode ? "link" }:
let
  files = [ ./template.cue ];
  output = ".justfile";

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

  result = lib.mkTemplate {
    inherit files mode output postBuild flags;
    configData = { data = configData; };
  };
in
{
  inherit (result) configFile shellHook;
}

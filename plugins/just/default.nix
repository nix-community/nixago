{ pkgs, lib }:
{ head ? "", tasks }:
let
  # Expand configuration data
  configData = {
    data = {
      inherit head tasks;
    };
  };

  # Run the formatter since the output from the Go template engine is ugly
  postHook = ''
    cat $out
    ${pkgs.just}/bin/just --unstable --fmt -f $out
  '';

  # Need to explicitly tell cue what expression to render as text output
  flags = {
    expression = "rendered";
    out = "text";
  };
in
{
  inherit configData;
  format = "text";
  output = ".justfile";
  engine = lib.engines.cue {
    inherit flags postHook;
    files = [ ./templates/default.cue ];
  };
}

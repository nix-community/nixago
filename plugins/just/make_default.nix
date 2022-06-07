{ pkgs, lib }:
userData:
let
  inherit (userData) configData;

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
  configDataFinal = { data = configData; };
in
{
  inherit postBuild flags;
  configData = configDataFinal;
}

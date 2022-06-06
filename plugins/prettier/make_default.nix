{ pkgs, lib }:
userData:
let
  files = [ ./templates/default.cue ];
in
{
  inherit files;
}

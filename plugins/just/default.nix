{ pkgs, lib }:
{
  /* Creates a .justfile for configuring the just task runner.

    See template.cue for the expected format of incoming data.
  */
  mkConfig = import ./make.nix { inherit pkgs lib; };
}

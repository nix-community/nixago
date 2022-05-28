{ pkgs, lib }:
{
  /* Creates a .justfile for configuring the just task runner.

    See template.cue for the expected format of incoming data.
  */
  mkConfig = import ./mkConfig.nix { inherit pkgs lib; };
}

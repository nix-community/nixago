{ pkgs, lib }:
{
  cue = import ./cue.nix { inherit pkgs lib; };
  nix = import ./nix.nix { inherit pkgs lib; };
}

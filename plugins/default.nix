{ pkgs, lib }:
{
  just = import ./just { inherit pkgs lib; };
  pre-commit = import ./pre-commit { inherit pkgs lib; };
}

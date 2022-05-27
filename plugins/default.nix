{ pkgs, lib }:
{
  /* https://github.com/casey/just
  */
  just = import ./just { inherit pkgs lib; };

  /* https://github.com/pre-commit/pre-commit
  */
  pre-commit = import ./pre-commit { inherit pkgs lib; };
}

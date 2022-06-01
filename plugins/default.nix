{ pkgs, lib }:
{
  /* https://github.com/siderolabs/conform
  */
  conform = import ./conform { inherit pkgs lib; };

  /* https://github.com/casey/just
  */
  just = import ./just { inherit pkgs lib; };

  /* https://github.com/evilmartians/lefthook
  */
  lefthook = import ./lefthook { inherit pkgs lib; };

  /* https://github.com/pre-commit/pre-commit
  */
  pre-commit = import ./pre-commit { inherit pkgs lib; };

  /* https://github.com/prettier/prettier
  */
  prettier = import ./prettier { inherit pkgs lib; };
}

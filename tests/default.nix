{ pkgs, runTest }:
{
  just = pkgs.callPackage ./just { inherit runTest; };
  lefthook = pkgs.callPackage ./lefthook { inherit runTest; };
  pre-commit = pkgs.callPackage ./pre-commit { inherit runTest; };
  prettier = pkgs.callPackage ./prettier { inherit runTest; };
}

{ pkgs, lib }:
userData:
with pkgs.lib;
let
  inherit (userData) configData;
  lefthook = pkgs.lefthook;

  # Add an extra hook for adding required stages whenever the file changes
  skip_attrs = [
    "colors"
    "extends"
    "skip_output"
    "source_dir"
    "source_dir_local"
  ];
  stages = builtins.attrNames (builtins.removeAttrs configData skip_attrs);
  stagesStr = builtins.concatStringsSep " " stages;
  extra = ''
    # Install configured hooks
    for stage in ${stagesStr}; do
      ${lefthook}/bin/lefthook add -a "$stage"
    done
  '';
in
{
  hook = {
    inherit extra;
  };
}

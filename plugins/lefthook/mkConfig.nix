{ pkgs, lib }:
{ configData }:
with pkgs.lib;
let
  files = [ ./template.cue ];
  output = "lefthook.yml";
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
  shellHookExtra = ''
    # Install configured hooks
    for stage in ${stagesStr}; do
      ${lefthook}/bin/lefthook add -a "$stage"
    done
  '';

  # Generate the module
  result = lib.mkTemplate {
    inherit configData files output shellHookExtra;
  };
in
{
  inherit (result) configFile shellHook;
}

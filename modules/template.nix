{ config, lib, nix-cue, pkgs, ... }@args:
with pkgs.lib;
let
  inherit (lib) mkOption types;
  flags = removeAttrs args [ "config" "lib" "nix-cue" "pkgs" "options" "specialArgs" ];
  hook = ''
    # Check if the link is pointing to the existing derivation result
      if readlink ${config.output} >/dev/null \
        && [[ $(readlink ${config.output}) == ${config.configFile} ]]; then
        echo 1>&2 "nixago: ${config.output} is up to date"
      elif [[ -L ${config.output} || ! -f ${config.output} ]]; then # otherwise we need to update
        echo 1>&2 "nixago: updating ${config.output}"

        # Relink to the new result
        unlink ${config.output}
        ln -s ${config.configFile} ${config.output}

        # Run extra shell hook
        ${config.shellHookExtra}
      else # this was an existing file
        echo 1>&2 "nixago: ERROR refusing to overwrite existing ${config.output}"
      fi
  '';
in
{
  options = {
    configFile = mkOption {
      type = types.package;
      description = "The generated configuration file";
      default = nix-cue.eval
        ({
          inherit pkgs;
          inputFiles = config.files;
          outputFile = config.output;
          data = config.data;
        } // flags);
    };
    data = mkOption {
      type = types.attrs;
      description = "The configuration data";
    };
    files = mkOption {
      type = types.listOf types.path;
      description = "The CUE files";
    };
    output = mkOption {
      type = types.str;
      description = "The name of the file to generate";
    };
    shellHook = mkOption {
      type = types.str;
      description = "Shell hook for linking generated configuration file";
      default = hook;
    };
    shellHookExtra = mkOption {
      type = types.str;
      description = "Extra shell hook which is run when the generated configuration file changes";
      default = "";
    };
  };
}

/* A module for generating configuration files.

  This module does the actual work of generating a configuration file from its
  option values. Underneath the hood, it calls out to `cue-eval` via the
  `nix-cue` pkg (see the default value for the `configFile` option). The `files`
  option should contain a list of files to evaluate, `output` should be the name
  of the file to output, and the `data` option should be set to a nix expression
  which will provide concrete data to evaluate with. The `configFile` option
  will be a derivation that builds the configuration file and `shellHook` will
  contain a small shellHook for automatically linking (and updating) the
  configuration file to the current working directory. The `shellHookExtra`
  option can be set to define extra shell commands to run when the configuration
  file is regenerated due to the underlying data changing.
*/
{ config, lib, flakeLib, pkgs, ... }@args:
with pkgs.lib;
let
  inherit (lib) mkOption types;
  flags = removeAttrs args [
    "config"
    "lib"
    "flakeLib"
    "pkgs"
    "options"
    "specialArgs"
  ];
  hook = ''
    # Check if the link is pointing to the existing derivation result
      if readlink ${config.output} >/dev/null \
        && [[ $(readlink ${config.output}) == ${config.configFile} ]]; then
        echo 1>&2 "nixago: ${config.output} is up to date"
      elif [[ -L ${config.output} || ! -f ${config.output} ]]; then
        # otherwise we need to update
        echo 1>&2 "nixago: updating ${config.output}"

        # Relink to the new result
        unlink ${config.output}
        ln -s ${config.configFile} ${config.output}

        # Run extra shell hook
        ${config.shellHookExtra}
      else # this was an existing file
        echo 1>&2 "nixago: ERROR refusing to overwrite ${config.output}"
      fi
  '';
in
{
  options = {
    configFile = mkOption {
      type = types.package;
      description = "The generated configuration file";
      default = flakeLib.eval
        ({
          inherit (config) configData;
          inputFiles = config.files;
          outputFile = config.output;
          postBuild = config.postBuild;
        } // flags);
    };
    configData = mkOption {
      type = types.attrs;
      description = "The raw configuration data";
    };
    files = mkOption {
      type = types.listOf types.path;
      description = "The CUE files";
    };
    output = mkOption {
      type = types.str;
      description = "The name of the file to generate";
    };
    postBuild = mkOption {
      type = types.str;
      description = "Commands to run after the configuration is built";
      default = "";
    };
    shellHook = mkOption {
      type = types.str;
      description = "Shell hook for linking generated configuration file";
      default = hook;
    };
    shellHookExtra = mkOption {
      type = types.str;
      description = "Extra shell hook executed when the config file changes";
      default = "";
    };
  };
}

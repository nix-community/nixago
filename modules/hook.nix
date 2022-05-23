{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption types;
  hook = types.submodule (
    { config, ... }:
    {
      options = {
        id = mkOption {
          type = types.str;
          description = "The id of the hook - used in pre-commit-config.yaml";
        };
        name = mkOption {
          type = types.str;
          description = "The name of the hook - shown during hook execution";
          default = config.id;
        };
        entry = mkOption {
          type = types.nullOr types.str;
          description = "The entry point - the executable to run";
          default = null;
        };
        language = mkOption {
          type = types.nullOr types.str;
          description = "The language of the hook - tells pre-commit how to install the hook";
          default = null;
        };
        files = mkOption {
          type = types.nullOr types.str;
          description = "The pattern of files to run on";
          default = null;
        };
        exclude = mkOption {
          type = types.nullOr types.str;
          description = "Exclude files that were matched by `files`";
          default = null;
        };
        types = mkOption {
          type = types.nullOr (types.listOf types.str);
          description = "List of file types to run on (AND)";
          default = null;
        };
        types_or = mkOption {
          type = types.nullOr (types.listOf types.str);
          description = "List of file types to run on (OR)";
          default = null;
        };
        exclude_types = mkOption {
          type = types.nullOr (types.listOf types.str);
          description = "The pattern of files to exclude.";
          default = null;
        };
        always_run = mkOption {
          type = types.nullOr types.bool;
          description = "If true this hook will run even if there are no matching files";
          default = null;
        };
        fail_fast = mkOption {
          type = types.nullOr types.bool;
          description = "If true pre-commit will stop running hooks if this hook fails";
          default = null;
        };
        verbose = mkOption {
          type = types.nullOr types.bool;
          description = "If true, forces the output of the hook to be printed even when the hook passes";
          default = null;
        };
        pass_filenames = mkOption {
          type = types.nullOr types.bool;
          description = "if false no filenames will be passed to the hook.";
          default = null;
        };
        require_serial = mkOption {
          type = types.nullOr types.bool;
          description = "if true this hook will execute using a single process instead of in parallel.";
          default = null;
        };
        description = mkOption {
          type = types.nullOr types.str;
          description = "Description of the hook. Used for metadata purposes only";
          default = null;
        };
        language_version = mkOption {
          type = types.nullOr types.str;
          description = "Sets version of language used to run hook";
          default = null;
        };
        args = mkOption {
          type = types.nullOr (types.listOf types.str);
          description = "list of additional parameters to pass to the hook";
          default = null;
        };
        stages = mkOption {
          type = types.nullOr (types.listOf types.str);
          description = "Confines the hook to the given stages";
          default = null;
        };
      };
    }
  );

  repo = types.submodule (
    { config, ... }:
    {
      options = {
        repo = mkOption {
          type = types.str;
          description = "The address of the repository";
        };
        rev = mkOption {
          type = types.nullOr types.str;
          description = "The revision to fetch the hook at";
          default = null;
        };
        hooks = mkOption {
          type = types.listOf hook;
          description = "The hooks to include in the configuration";
          default = { };
        };
      };
    }
  );
in
{
  options = {
    default_stages = mkOption {
      type = types.nullOr (types.listOf types.str);
      description = "The default stages to use for hooks";
      default = null;
    };
    repos = mkOption {
      type = types.listOf repo;
      description = "The repositories to use";
      default = { };
    };
  };
}

{ pkgs, lib, plugins }:
{ config
, files
, defaultOutput
, postBuild ? ""
, shellHookExtra ? ""
, flags ? { }
}:
with pkgs.lib;
let
  # Build the configuration file derivation
  output = if config.output == "" then defaultOutput else config.output;
  configFile = lib.eval
    ({
      inherit (config) configData;
      inherit postBuild;
      inputFiles = files;
      outputFile = output;
    } // flags);

  # Build shell hook
  # This hook creates a local symlink to the file in the Nix store
  linkHook = ''
    # Check if the link is pointing to the existing derivation result
    if readlink ${output} >/dev/null \
      && [[ $(readlink ${output}) == ${configFile} ]]; then
      echo 1>&2 "nixago: ${output} link is up to date"
    elif [[ -L ${output} || ! -f ${output} ]]; then
      # otherwise we need to update
      echo 1>&2 "nixago: ${output} link updated"

      # Relink to the new result
      unlink ${output} &>/dev/null
      ln -s ${configFile} ${output}

      # Run extra shell hook
      ${shellHookExtra}
    else # this was an existing file
      echo 1>&2 "nixago: ERROR refusing to overwrite ${output}"
    fi
  '';

  # This hook creates a local copy of the file in the Nix store
  copyHook = ''
    # Check if the file exists
    if [[ -f ${output} ]]; then
      # Check if we need to update the local copy
      cmp ${configFile} ${output} >/dev/null
      if [[ $? -gt 0 ]]; then
        # We need to update the local copy
        echo "nixago: ${output} copy updated"
        install -m 644 ${configFile} ${output}

        # Run extra shell hook
        ${config.shellHookExtra}
      else
        echo "nixago: ${output} copy is up to date"
      fi
    else
      # We need to create the first iteration of the file
      echo "nixago: ${output} copy created"
      install -m 644 ${configFile} ${output}

      # Run extra shell hook
      ${config.shellHookExtra}
    fi
  '';

  shellHook = if config.mode == "copy" then copyHook else linkHook;
in
{
  inherit configFile shellHook;
}


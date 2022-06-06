{ pkgs, lib, plugins }:
genRequest:
with pkgs.lib;
let
  output = genRequest.output;
  shellHookExtra = genRequest.shellHookExtra;

  # Build the configuration file derivation
  configFile = lib.eval
    ({
      inherit (genRequest) configData postBuild;
      inputFiles = genRequest.files;
      outputFile = genRequest.output;
    } // genRequest.flags);

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
        ${shellHookExtra}
      else
        echo "nixago: ${output} copy is up to date"
      fi
    else
      # We need to create the first iteration of the file
      echo "nixago: ${output} copy created"
      install -m 644 ${configFile} ${output}

      # Run extra shell hook
      ${shellHookExtra}
    fi
  '';

  shellHook = if genRequest.mode == "copy" then copyHook else linkHook;
in
{
  inherit configFile shellHook;
}


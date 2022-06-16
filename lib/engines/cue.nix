{ pkgs, lib }:
{ files
, preHook ? ""
, postHook ? ""
, flags ? { }
, cue ? pkgs.cue
, jq ? pkgs.jq
}: request:
with pkgs.lib;
let
  inherit (request) configData format output;

  # We opt to feed configuration data as JSON to CUE
  json = builtins.toJSON configData;

  # Default the derivation name to the basename of the output file.
  name = builtins.baseNameOf output;

  allFlags =
    ({
      # Output the result to the derivation output
      outfile = "$out";

      # Specify the desired output file format
      out = format;
    } // flags);

  /*
    CUE can be informed about the format of any input files. Since our input
    file will be extensionless (Nix generates a random name with no extension),
    then we need to append `json:` to the input.
  */
  allInputs = files ++ [ "json: $jsonPath" ];

  # Build the full CUE command
  flagStr = builtins.concatStringsSep " " (cli.toGNUCommandLine { } allFlags);
  inputStr = builtins.concatStringsSep " " allInputs;
  cueEvalCmd = "cue eval ${flagStr} ${inputStr}";

  # runCommand does the work of producing the derivation
  result = pkgs.runCommand name
    {
      inherit json;
      buildInputs = [ cue jq ];
      passAsFile = [ "json" ];
    }
    ''
      # Helpful details if an error occurs
      echo "----- START DEBUG -----"
      echo "using command: ${cueEvalCmd}"
      echo "----- END DEBUG -----"

      if [[ ! -z "$jsonPath" ]]; then
        echo "----- START CONFIG DUMP -----"
        cat $jsonPath | jq
        echo "----- END CONFIG DUMP -----"
      fi

      echo ">>> running pre-hook commands..."
      ${preHook}

      # We do our own error handling here
      set +e

      echo ">>> rendering output..."
      result=$(${cueEvalCmd} 2>&1 >/dev/null)

      if [[ $? -gt 0 ]]; then
        echo "!!! CUE failed rendering the output"

        echo "----- START ERROR DUMP -----"
        echo "$result"
        echo "----- END ERROR DUMP -----"

        exit 1
      fi

      set -e

      echo ">>> running post-hook commands..."
      ${postHook}
    '';
in
result


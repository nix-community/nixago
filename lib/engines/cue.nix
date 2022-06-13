{ pkgs, lib }:
{ path
, package ? ""
, postBuild ? ""
, flags ? { }
, cue ? pkgs.cue
, jq ? pkgs.jq
}: request:
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
      inherit format;
    } // flags);

  /*
    We change into the `path` directory before executing CUE, so we can safely
    assume that the files are in the local directory.

    CUE uses a special format for specifying packages (.:PKGNAME), so we adjust
    the inputs accordingly. CUE can also be informed about the format of any
    input files. Since our input file will be extensionless (Nix generates a
    random name with no extension), then we need to append `json:` to the input.
  */
  allInputs = (if package == "" then [ "./" ] else [ ".:${package}" ])
    ++ [ "json: $jsonPath" ];

  # Build the full CUE command
  flagStr = cli.toGNUCommandLineShell { } allFlags;
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
      echo "using path: ${path}"
      echo "using package: ${package}"
      echo "using command: ${cueEvalCmd}"
      echo "----- END DEBUG -----"

      if [[ ! -z "$jsonPath" ]]; then
        echo "----- START CONFIG DUMP -----"
        cat $jsonPath | jq
        echo "----- END CONFIG DUMP -----"
      fi

      # We do our own error handling here
      set +e

      # Make sure path is a directory
      if [[ ! -d ${path} ]]; then
        echo "!!! path should be a directory: ${path}
        exit 1
      fi

      # Make sure path is not empty
      if [[ -z "$(ls -A ${path})" ]]; then
        echo "!!! path should not be an empty directory: ${path}
        exit 1
      fi

      echo ">>> rendering output..."
      result=$(cd ${path} && ${cueEvalCmd} 2>&1 >/dev/null)

      if [[ $? -gt 0 ]]; then
        echo "!!! CUE failed rendering the output"

        echo "----- START ERROR DUMP -----"
        echo "$result"
        echo "----- END ERROR DUMP -----"

        exit 1
      fi

      set -e

      echo ">>> running post-build commands..."
      ${postBuild}
    '';
in
result


/*
  Evaluates the given cue files and configData and returns a derivation which
  builds the result.
*/
{ pkgs, lib, plugins }:
{ path
, output ? "default"
, format ? ""
, package ? ""
, postBuild ? ""
, configData ? { }
, flags ? { }
, cue ? pkgs.cue
, jq ? pkgs.jq
}:

with pkgs.lib;
let
  json = optionalString (configData != { }) (builtins.toJSON configData);

  defaultFlags = (
    {
      # Output the evaluation result to the derivation output
      outfile = "$out";
      # Add optional output format
    } // (optionalAttrs (format != "") { out = format; })
  );
  defaultInputs = if package == "" then [ "./" ] else [ ".:${package}" ];

  allFlags = defaultFlags // flags;
  allInputs = defaultInputs ++ optionals (json != "") [ "json: $jsonPath" ];

  # Converts {flagName = "string"; } to --flagName "string" (or empty for bool)
  flagsToString = name: value:
    if (builtins.isBool value) then "--${name}" else ''--${name} "${value}"'';

  flagStr = builtins.concatStringsSep " "
    (attrValues (mapAttrs flagsToString allFlags));
  inputStr = builtins.concatStringsSep " " allInputs;
  cueEvalCmd = "cue eval ${flagStr} ${inputStr}";

  # runCommand does the work of producing the derivation
  result = pkgs.runCommand output
    ({
      inherit json;
      buildInputs = [ cue jq ];
      passAsFile = [ "json" ];
    } // optionalAttrs (json != "") { inherit json; passAsFile = [ "json" ]; })
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

/*
  Evaluates the given input files and data and returns a derivation which builds the result.
*/
{ pkgs, lib }:
{ inputFiles
, outputFile
, postBuild ? ""
, data ? { }
, cue ? pkgs.cue
, ...
}@args:

with pkgs.lib;
let
  json = optionalString (data != { }) (builtins.toJSON data);

  defaultFlags = {
    outfile = "$out"; # Output the evaluation result to the derivation output
  };

  # Extra flags are passed via ...
  extraFlags = removeAttrs args [
    "inputFiles"
    "outputFile"
    "postBuild"
    "data"
    "cue"
  ];

  allFlags = defaultFlags // extraFlags;
  allInputs = inputFiles ++ optionals (json != "") [ "json: $jsonPath" ];

  # Converts {flagName = "string"; } to --flagName "string" (or empty for bool)
  flagsToString = name: value:
    if (builtins.isBool value) then "--${name}" else ''--${name} "${value}"'';

  flagStr = builtins.concatStringsSep " "
    (attrValues (mapAttrs flagsToString allFlags));
  inputStr = builtins.concatStringsSep " " allInputs;
  cueEvalCmd = "cue eval ${flagStr} ${inputStr}";

  # runCommand does the work of producing the derivation
  result = pkgs.runCommand outputFile
    ({
      inherit json;
      buildInputs = [ cue ];
      passAsFile = [ "json" ];
    } // optionalAttrs (json != "") { inherit json; passAsFile = [ "json" ]; })
    ''
      echo "nixago: Rendering output..."
      ${cueEvalCmd}
      ${postBuild}
    '';
in
result

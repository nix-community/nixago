/*
  Evaluates the given input files and data and returns a derivation which builds the result.
*/
{ pkgs, lib }:
{ inputFiles, outputFile, data ? { }, cue ? pkgs.cue, ... }@args:
with pkgs.lib;
let
  json = optionalString (data != { }) (builtins.toJSON data);

  defaultFlags = {
    outfile = "$out";
  };
  extraFlags = removeAttrs args [ "inputFiles" "outputFile" "data" "cue" ];

  allFlags = defaultFlags // extraFlags;
  allInputs = inputFiles ++ optionals (json != "") [ "json: $jsonPath" ];

  flagsToString = name: value: if (builtins.isBool value) then "--${name}" else ''--${name} "${value}"'';
  flagStr = builtins.concatStringsSep " " (attrValues (mapAttrs flagsToString allFlags));
  inputStr = builtins.concatStringsSep " " allInputs;
  cueEvalCmd = "cue eval ${flagStr} ${inputStr}";

  result = pkgs.runCommand outputFile
    ({
      inherit json;
      buildInputs = [ cue ];
      passAsFile = [ "json" ];
    } // optionalAttrs (json != "") { inherit json; passAsFile = [ "json" ]; })
    ''
      echo "nixago: Rendering output..."
      ${cueEvalCmd}
    '';
in
result

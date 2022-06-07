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
      buildInputs = [ cue ];
      passAsFile = [ "json" ];
    } // optionalAttrs (json != "") { inherit json; passAsFile = [ "json" ]; })
    ''
      echo "nixago: Rendering output..."
      cd ${path} && ${cueEvalCmd}
      ${postBuild}
    '';
in
result

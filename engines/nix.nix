/* The nix engine uses pkgs.formats for generating output data.

  The engine takes a single parameter (`opts`) which is subsequently passed to
  the specified generator when instantiating it. See the pkgs.formats entries
  for which options are available for each generator type.

  The `type` field of the request determines which generator is invoked. The
  type must be a name in the set produced by `pkgs.formats`.
*/
{ pkgs, lib }:
opts: request:
with pkgs.lib;
let
  inherit (request) configData format output;

  # Type is equivalent to the file format specified by the user.
  type = pkgs.formats.${format};

  # Default the derivation name to the basename of the output file.
  name = builtins.baseNameOf output;

  # The value we want to process is our raw configuration data.
  value = configData;
in
# Validate that the type specified is supported by pkgs.formats
assert assertMsg
  (pkgs.formats ? "${format}") "Invalid type specified: ${format}";

# The format of entries in pkgs.formats is:
#   {
#     type = {...}: {
#       generate = name: value: pkgs.runCommand { ... };
#     };
#   }
# The user is allowed to pass `opts` to set additional options and then we
# subsequently call `generate` with the derivation name and the raw data that we
# want to process.
(pkgs.formats.${format} opts).generate name value

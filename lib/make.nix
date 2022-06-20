{ pkgs, lib }:
let
  # compat: setDefaultModuleLocation is a relatively recent addition to pkgs.lib
  setDefaultModuleLocation = pkgs.lib.setDefaultModuleLocation or (file: m:
    { _file = file; imports = [ m ]; }
  );
in
request:
let
  requestLocation = (builtins.unsafeGetAttrPos "configData" request).file or null;

  # Compile the request into its module equivalent
  userRequest =
    let
      maybeLocatedRequest =
        if requestLocation == null then
          request
        else
          setDefaultModuleLocation requestLocation request;
    in
    lib.mkRequest [ maybeLocatedRequest ];

  # The defined interface between Nixago and an engine is that it takes exactly
  # one parameter: an instance of the request module. The result should be a
  # derivation which builds the desired configuration file.
  configFile = userRequest.engine userRequest;

  # TODO: Remove this once we convert everything over to the new framework
  name = "temp";

  # TODO: Simplify this once we convert everything over to the new framework
  hookConfig = {
    inherit (userRequest) output;
    inherit (userRequest.hook) extra mode;
  };

  # Builds the shell hook for managing the generated file.
  shellHook =
    lib.makeHook { inherit configFile name hookConfig; };
in
{
  inherit configFile shellHook;
}

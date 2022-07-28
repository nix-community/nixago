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

  # Defunctor the request, because the module system can't deal with a functor-type module
  # as an upstream contract, upstream should implement corresponding validators / sanators
  # instead, upstream just "explodes"
  defunctoredRequest = builtins.removeAttrs request [ "__functor" ];

  # Compile the request into its module equivalent
  userRequest =
    let
      maybeLocatedRequest =
        if requestLocation == null then
          defunctoredRequest
        else
          setDefaultModuleLocation requestLocation defunctoredRequest;
    in
    lib.mkRequest [ maybeLocatedRequest ];

  # Apply specific transformations to the request's configData & extra
  reifiedRequest = userRequest // {
    configData = userRequest.apply userRequest.configData;
  };

  # The defined interface between Nixago and an engine is that it takes exactly
  # one parameter: an instance of the request module. The result should be a
  # derivation which builds the desired configuration file.
  configFile = userRequest.engine reifiedRequest;

  # TODO: Remove this once we convert everything over to the new framework
  name = "temp";

  # TODO: Simplify this once we convert everything over to the new framework
  hookConfig = {
    inherit (reifiedRequest) output;
    inherit (reifiedRequest.hook) extra mode;
  };

  # Builds the shell hook for managing the generated file.
  inherit (lib.makeHook { inherit configFile name hookConfig; }) shellHook shellScript;
in
{
  inherit configFile shellHook shellScript;
}

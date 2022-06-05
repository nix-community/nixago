{ pkgs }:
with pkgs.lib;
{
  mkConfigResult = { file, shellHook }:
    evalModules ({
      modules = [
        ../modules/config.nix
        {
          inherit file shellHook;
        }
      ];
    }).config;
  mkEvalRequest = { pluginRequest, files, flags ? [ ], postBuild ? "", shellHookExtra ? "" }:
    evalModules ({
      modules = [
        ../modules/eval_request.nix
        {
          inherit name configData;
        }
        (optionalAttrs (flags != [ ]) { inherit flags; })
        (optionalAttrs (postBuild != "") { inherit postBuild; })
        (optionalAttrs (shellHookExtra != "") { inherit shellHookExtra; })
      ];
    }).config;
  mkPluginRequest = { name, configData, mode ? "", options ? { }, output ? "", type ? "" }:
    evalModules ({
      modules = [
        ../modules/plugin_request.nix
        {
          inherit name configData;
        }
        (optionalAttrs (mode != "") { inherit mode; })
        (optionalAttrs (options != { }) { inherit options; })
        (optionalAttrs (output != "") { inherit output; })
        (optionalAttrs (type != "") { inherit type; })
      ];
    }).config;
}

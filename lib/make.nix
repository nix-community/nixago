{ pkgs, lib, plugins }:
{ name, configData, type ? "", output ? "", mode ? "", options ? { } }:
with pkgs.lib;
let
  plugin = plugins.${name};

  # Build user config
  userConfig = lib.filterEmpty { inherit name configData type output mode; };
  userRequest = lib.mkGenRequest [ userConfig ];

  # Build plugin config
  pluginConfig = plugin.types.${userRequest.type}.make userRequest;

  # Build the generate request
  genRequest = lib.mkGenRequest [
    userConfig
    pluginConfig
    {
      # Use default output if the user didn't specify one
      output =
        if output == "" then
          plugin.types.${userRequest.type}.output else output;
    }
  ];

  # The module system does a recursive merge by default which doesn't work well
  # with configData. If the plugin changed anything, we just use that, otherwise
  # we stick to what the user gave.
  configDataFinal =
    if pluginConfig ? configData then
      pluginConfig.configData else configData;
in
lib.genConfig (lib.updateValue genRequest "configData" configDataFinal)

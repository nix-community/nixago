/* The main function of Nixago. Makes a configuration file by invoking the
  given plugin and combining all resulting data into a request which ultimately
  is used to generate the resulting configuration and shell hook.
*/
{ pkgs, lib, plugins }:
{ name, configData, type ? "", output ? "", mode ? "", pluginOpts ? { } }:
with pkgs.lib;
let
  plugin = plugins.${name};

  # Build user config
  userConfig = {
    inherit configData;
    hook = lib.filterEmpty { inherit output mode; };
    plugin = lib.filterEmpty { inherit name type; opts = pluginOpts; };
  };

  userRequest = lib.mkRequest [ userConfig ];

  # Build plugin config
  pluginConfig = plugin.types.${userRequest.plugin.type}.make userRequest;

  # Build the request
  request = lib.mkRequest [
    userConfig
    pluginConfig
    {
      # Use default output if the user didn't specify one
      hook.output =
        if output == "" then
          plugin.types.${userRequest.plugin.type}.output else output;

      # Use the plugin type as the package name
      cue.package = userRequest.plugin.type;
    }
  ];

  # The module system does a recursive merge by default which doesn't work well
  # with configData. If the plugin changed anything, we just use that, otherwise
  # we stick to what the user gave.
  configDataFinal =
    if pluginConfig ? configData then
      pluginConfig.configData else configData;
in
lib.generate (lib.updateValue request "configData" configDataFinal)

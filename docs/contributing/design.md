# Nixago Design

When contributing to Nixago, it's important to understand the general design
priciples that guide its development. This section provides details on how the
library is structured and introduces the basic concepts required to effectively
contribute to it.

## CUE

The primary tool underlying Nixago is [CUE][1]. CUE stands for Configure, Unify,
and Execute. It's a general-purpose language for defining, generating, and
validating data. CUE was chosen for its strengths in the areas of configuration
validation and generation. It's also a young project with a rapidly growing
platform.

Learning the CUE language is necessary for contributing plugins. Don't worry,
though, it's much easier to pickup than Nix. It's recommended to review the
[Cuetorials website][2] to get an overview of the CUE language. The
[Logic of CUE][3] is also recommended.

When creating a plugin, you'll need to write a CUE schema that can validate the
incoming configuration data. The schema not only ensures that configuration data
is accurate, but it also creates the foundation for transforming that data into
the format needed for the configuration file.

## Plugins

The main interface that Nixago provides is through its [plugin][4]
infrastructure. A plugin is simply a small wrapper which generates a
configuration file for a specific tool. The structure of plugins is consistent
in that they ingest data from the user and produce an instance of the
[template module](#templates). This module provides a derivation which will
build the desired configuration file as well as a shell hook which will manage
linking the file locally.

Plugins are the main source of contribution to Nixago. Individuals are
encouraged to contribute plugins for their tools of choice so that the wider
community may benefit from the plugin.

[See here](plugins.md) for detailed steps for adding plugins.

## Templates

The [template module][5] is the basic building block of Nixago. It's responsible
for creating the derivation that ultimately generates the configuration file. It
also creates the shell hook which manages the configuration file.

The internal library provides a [single function][6] for creating new instances
of the template module. It accepts the following arguments:

- **data**: The raw data provided from the end-user
- **files**: The files to pass to `cue eval` (typically .cue files)
- **output**: The filename to output
- **postBuild**: Shell code to run after `cue eval` is invoked
- **shellHookExtra**: Additional shell code to run when the file is regenered by the shell hook
- **flags**: Additional flags to pass to `cue eval`

The function will return the module's `config` attribute.

The template module provides two primary outputs:

- **configFile**: A derivation that will build the configuration file
- **shellHook**: A shell hook which will link the configuration file locally and update it when it changes

## Evaluation

The foundational function provided by the internal library is the
[eval function][7]. It interacts with the `cue` CLI tool via a call to
[runCommand][8]. This, in turn, creates a derivation which will produce the
output of invoking the `cue eval` command.

[1]: https://cuelang.org/
[2]: https://cuetorials.com/introduction/
[3]: https://cuelang.org/docs/concepts/logic/
[4]: https://github.com/jmgilman/nixago/tree/master/plugins
[5]: https://github.com/jmgilman/nixago/blob/master/modules/template.nix
[6]: https://github.com/jmgilman/nixago/blob/master/lib/template.nix
[7]: https://github.com/jmgilman/nixago/blob/master/lib/eval.nix
[8]: https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/trivial-builders.nix#L27

# Contributing

The power of Nixago comes through its plugin based system. Contributing plugins
will greatly benefit all downstream consumers. This section will document the
basic process for adding a new plugin.

## CUE

The primary tool underlying Nixago is [CUE][1]. CUE stands for Configure, Unify,
and Execute. It's a general-purpose language for defining  generating, and
validating data. CUE was chosen for its strengths in the areas of configuration
validation and generation. It's also a young project with a rapidly growing
platform.

Learning the CUE language is necessary for contributing plugins. Don't worry,
though, it's much easier to pickup than Nix. It's recommended to review the
[Cuetorials website][2] to get an overview of the CUE language. The
[Logic of CUE][3] is also a helpful.

When creating a plugin, you'll need to write a CUE schema that can validate the
incoming configuration data. The schema not only ensures that configuration data
is accurate, but it also creates the foundation for transforming that data into
the format needed for the configuration file.

### Example

Let's review the CUE file for the [pre-commit plugin](plugins/pre-commit.md):

```cue
#Config: {
    default_install_hook_types?: [...string]
    default_language_version?: [string]: string
    default_stages?: [...string]
    files?: string
    exclude?: string
    fail_fast?: bool
    minimum_pre_commit_version?: string
    repos: [...#Repo]
}

#Hook: {
    additional_dependencies?: [...string]
    alias?: string
    always_run?: bool
    args?: [...string]
    entry?: string
    exclude?: string
    exclude_types?: [...string]
    files?: string
    id: string
    language?: string
    language_version?: string
    log_file?: string
    name?: string
    stages?: [...string]
    types?: [...string]
    types_or?: [...string]
    verbose?: bool
}

#Repo: {
    repo: string
    rev?: string
    if repo != "local" {
        rev: string
    }
    hooks: [...#Hook]
}

{
    #Config
}
```

This file defines three [definitions][4], notated by the `#` symbol. A
definition can be thought of as a schema or contract. It defines the shape of
valid data through various constraints. Let's break one down:

```cue
#Repo: {
    repo: string
    rev?: string
    if repo != "local" {
        rev: string
    }
    hooks: [...#Hook]
}
```

The `pre-commit-config.yaml` file has a `repos` field which is a list of
repositories that pre-commit should build from. The `#Repo` definition provides
the schema for these entries. Each entry must have a `repo` field which is a
string value. The `rev` field is an interesting one: it's only optional if the
`repo` field is set to "local". The above first sets the `rev` field to optional
using the `?` symbol and then conditonally sets it to required based on the
value of `repo`. Finally, each entry has a list of hooks, denoted by the
`[...#Hooks]` syntax.

The deriviation will fail to build if the end-user passes in data that violates
any of these constraints. Thus, it's better to lean more broadly than to try and
craft the perfect combination of constraints.

```cue
{
    #Config
}
```

This final bit is where we define the actual elements of the CUE file. This is
what will appear when we evaluate the CUE file. In the above case, we're saying
the input data should be a [struct][5] which conforms to the schema defined by
`#Config`.

In this case, we're doing no additional transformations to the incoming data.
This is because we're expecting the input data to already be in the format
expected in the `.pre-commit-config.yaml` file. Since YAML is a superset of
JSON, we can easily ask CUE to evaluate the input and produce a YAML output.

### Testing

The easiest way to test your CUE file is to feed it data. Once the file has been
crafted, generate some input data and then pass it to `cue eval`:

```shell
cue eval -o output.file file.cue input.json
```

The order of files is not important. The `cue` CLI can interpret several forms
of input, however, Nixago primarily passes JSON, so that is the best format to
test with. Manipulate the input data to ensure that the CUE file works as
expected.

## Nix

Once the CUE file has been created, adding a plugin is simple. First, clone
the repository locally and then create a new folder in the plugins directory and
name it after the tool you're generating a configuration for. Drop the CUE file
into this directory, it's typically named `template.cue`.

Next, add a `default.nix` file and declare the functions that the plugin will
provide. For example, the pre-commit plugin provides two:

```nix
{ pkgs, lib }:
{
  mkConfig = import ./make.nix { inherit pkgs lib; };
  mkLocalConfig = import ./make_local.nix { inherit pkgs lib; };
}
```

The `default.nix` file should be a function which accepts an attribute set as
defined above. The `pkgs` parameter is a copy of `nixpkgs` and `lib` is a copy
of the internal library provided by the flake. In most cases, the actual
function contents should be defined in a separate file as shown above.

Finally, create your functions. Here is the contents of `mkConfig` for the
pre-commit plugin:

```nix
{ pkgs, lib }:
{ config, pre-commit ? pkgs.pre-commit, jq ? pkgs.jq, yq ? pkgs.yq-go }:
with pkgs.lib;
let
  # Find all stages that require installation
  stages = unique (flatten (builtins.map (repo: builtins.map (hook: optionals (hook ? stages) hook.stages) repo.hooks) config.repos) ++ [ "pre-commit" ]);
  stagesStr = builtins.concatStringsSep " " stages;

  # Add an extra hook for reinstalling required stages whenever the file changes
  shellHookExtra = (import ./common.nix { inherit pre-commit stagesStr; }).shellHookExtra;

  # Generate the module
  result = lib.mkTemplate {
    inherit shellHookExtra;
    data = config;
    files = [ ./template.cue ];
    output = ".pre-commit-config.yaml";
  };
in
{
  inherit (result) configFile shellHook;
}
```

Like `default.nix`, the function should first take an attribute set defining
`pkgs` and `lib`. After that, the arguments are dependent on what the plugin is
doing, although usually it always takes a `config` argument.

The main funcion you'll be interacting with is `lib.mkTemplate`. The function
takes three primary arguments:

- **data**: The raw data to be passed to `cue eval`. This is typically the data
provided by the end-user.

- **files**: The input files to be passed to `cue eval`. This is where you'll
want to specify the location of the CUE file.

- **output**: The name of the file to output. Note that CUE determines the
format of the output file by examining the file extension. In the above case, it
will output YAML. You can override this by providing the `--out` flag.

In addition to these, an optional `flags` argument can be provided which will
pass additional flags to the `cue eval` command. Flags are in the format of:

```nix
{
    name = "value";
}
```

This will be translated to `--name "value"`. Finally, some extra shell commands
can be provided. The `postBuild` argument takes a string of shell commands that
will run after `cue eval` is executed. The `shellHookExtra` argument takes a
string of shell commands that will be executed whenever the configuration file
is regenerated due to a change.

The function will return an attribute set with the input values it was called
with plus two additional fields: `configFile` and `shellHook`. The `configFile`
attribute is a derivation that, when built, will generate the configuration file
in the Nix store. The `shellHook` attribute contains a small amount of shell
code which links the generate configuration file to the current working
directory and updates it whenever it is regenerated.

For pre-commit, extra shell code is appended to the `shellHook` because the
pre-commit hooks must be installed before they can be used. Since hooks can be
added or changed at whim, the shell code uninstalls and reinstalls all hooks
whenever the configuration changes.

### Testing

Once you've written your functions, you'll need to write tests for them. This
is done by creating a new folder under the `tests` directory. The folder should
be named the same as the plugin. Testing it straightforward: create some test
input data, feed it into your plugin, and then verify that it produces the
expected output. Here is an example for the pre-commit plugin:

```nix
{ pkgs, plugins }:
let
  output = plugins.pre-commit.mkConfig {
    config = {
      repos = [
        {
          repo = "https://github.com/my/repo";
          rev = "1.0";
          hooks = [
            {
              id = "my-hook";
            }
          ];
        }
      ];
    };
  };

  result = pkgs.runCommand "test.pre-commit"
    { }
    ''
      cmp "${./expected.yml}" "${output.configFile}"
      touch $out
    '';
in
result
```

The test is broken into two phases: first the derivation is created using
the `mkConfig` function (this is the function being tested). Then, the
`runCommand` function is used to compare the result of building the derivation
to the expected output. If there is a mismatch, the test will fail.

To ensure the tests are run, they must be added to the main `flake.nix`:

```nix
{
    # Local tests
    checks = {
        just = pkgs.callPackage ./tests/just { inherit pkgs plugins; };
        pre-commit = pkgs.callPackage ./tests/pre-commit { inherit pkgs plugins; };
    };
}
```

These are all executed in the CI to ensure no breaking changes are introduced.

## Doucment

The final step before submitting a PR is to create a section in the
documentation for the plugin. Create a new markdown file in the `plugins`
directory named after your plugin. You should describe what the plugin does and
give examples for using it.

## Submit a PR

Finally, once all of the above is done, submit a PR with the changes and it will
be reviewed and merged!

[1]: https://cuelang.org/
[2]: https://cuetorials.com/introduction/
[3]: https://cuelang.org/docs/concepts/logic/
[4]: https://cuetorials.com/overview/types-and-values/#definitions
[5]: https://cuetorials.com/overview/types-and-values/#structs

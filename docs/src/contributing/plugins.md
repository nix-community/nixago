# Plugins

Contributing plugins to Nixago is a multi-step process. Fortunately, the design
of Nixago makes these steps relatively straightforward.

## Checklist

The following is a useful checklist to go over before submitting a PR:

1. Is the plugin named after the tool it supports?
2. Does the plugin have a dedicated directory under [plugins][1]?
3. Was the plugin added to the main [default.nix][2]?
4. Does the plugin have tests written for it?
5. Have the tests been added to the [flake.nix][3] `checks` output?
6. Does the plugin have a dedicated page in the documentation?

If you answered yes to all of the above questions you are ready to submit a PR!

## Creating a Plugin

Creating a plugin encompasses three primary tasks:

1. Create a CUE file
2. Create the Nix functions
3. Write tests and documentation

Each plugin should be isolated to a dedicated directory under [plugins][1]. The
first step is to create a new directory with the name of the plugin. The name
should ideally indicate the tool that it supports (i.e. the plugin for the
Prettier formatter is simply called `prettier`).

The remainder of this section will walk through creating a plugin for the
[pre-commit][4] CLI tool. The plugin will generate a `.pre-commit-config.yaml`
file which is used to configure the pre-commit tool.

### Creating the CUE file

Review the [CUE section](design.md#cue) of the design page for more information
about CUE. Each plugin typically utilizes a single CUE file, although more
advanced cases may require multiple files. The file should be called
`template.cue`.

When creating the CUE file, keep the following in mind:

- The schema defined in the file should be sufficient enough to prevent most
  configuration mistakes.

- If the tool being supported has rich documentation around valid values for
  each configuration field, use constraints to improve the accuracy of the schema.

- Don't be overly strict with the schema definition. The goal is to be helpful
  and not generate a large number of false negatives.

Here is the `template.nix` file for our pre-commit plugin:

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

This file defines three [definitions][5], notated by the `#` symbol. A
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

```cue
{
    #Config
}
```

This final bit is where we define the actual elements of the CUE file. This is
what will appear when we evaluate the CUE file. In the above case, we're saying
the input data should be a [struct][6] which conforms to the schema defined by
`#Config`.

In this case, we're doing no additional transformations to the incoming data.
This is because we're expecting the input data to already be in the format
expected in the `.pre-commit-config.yaml` file. Since YAML is a superset of
JSON, we can easily ask CUE to evaluate the input and produce a YAML output.

### Creating the Nix Functions

With the CUE file created, the next step is to create our main Nix function. In
this case, we're going to create a single function for generating our
configuration file.

```nix
{ pkgs, lib }:
data:
with pkgs.lib;
let
  files = [ ./template.cue ];
  output = ".pre-commit-config.yaml";
  pre-commit = pkgs.pre-commit;

  # Add an extra hook for reinstalling required stages whenever the file changes
  stages = unique (flatten (builtins.map (repo: builtins.map (hook: optionals (hook ? stages) hook.stages) repo.hooks) data.repos) ++ [ "pre-commit" ]);
  stagesStr = builtins.concatStringsSep " " stages;
  shellHookExtra = (import ./common.nix { inherit pre-commit stagesStr; }).shellHookExtra;

  # Generate the module
  result = lib.mkTemplate {
    inherit data files output shellHookExtra;
  };
in
{
  inherit (result) configFile shellHook;
}
```

All functions maintain the same basic structure. At the top we accept an
attribute set as the first argument which pulls in local copies of `nixpkgs`
and the internal `lib` provided by the flake. The second argument should always
be named `data` and will contain the data passed in by the end-user.

The top of the function should declare the `files` and `output` variables. The
`files` variable should point to the CUE file we previously created. The
`output` variable should contain the name of the configuration file the plugin
is generating. Note that the extension of the configuration file is important.
CUE uses the file extension to determine what format to output when our CUE file
is evaluated. [See here][7] for supported formats.

The remainder of the function is specific to each plugin. In the case above,
we gather all of the pre-commit `stages` settings to determine what stages of
the pre-commit process should be installed when the configuration is generated.
We then create `shellHookExtra` which contains the necessary logic for
installing the stages.

At the very end, the internal `mkTemplate` function is called. For more details
about this function, [see here](design.md#templates).

In order for our plugin to be picked up by the main flake, we must take two
additional steps. The first is creating a `default.nix` in our plugin directory
that exports our function:

```nix
{ pkgs, lib }:
rec {
  default = mkConfig;

  /* Creates a .pre-commit-config.yaml file for configuring pre-commit.
  */
  mkConfig = import ./mkConfig.nix { inherit pkgs lib; };
}
```

This will allow the `mkConfig` function to be accessible under
`nixago.plugins.{myPlugin}.mkConfig`. Setting the `default` attribute is
recommended, otherwise the plugin may not play well with the `mkAll` function.
It should be set to most widely used function.

Finally, we must create an entry in the main `default.nix`:

```nix
{ pkgs, lib }:
{
  # ...

  /* https://github.com/pre-commit/pre-commit
  */
  pre-commit = import ./pre-commit { inherit pkgs lib; };

  # ....
}
```

This registers the plugin to make it accessible from `nixago.plugins`.

### Writing Tests and Documentation

The final step is to write tests and documentation for the plugin. Tests are
added in the [tests][8] directory in a dedicated directory named after the
plugin. Tests are fairly trivial to write.

The first step is to create a `default.nix` which runs the test:

```nix
{ pkgs, plugins }:
let
  output = plugins.pre-commit.mkConfig {
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

  result = pkgs.runCommand "test.pre-commit"
    { }
    ''
      cmp "${./expected.yml}" "${output.configFile}"
      touch $out
    '';
in
result
```

The test is made up of two parts: a sample configuration is generated and then
it is compared to a known expected output. The test will be provided an instance
of `plugins` in order to access functions for testing. The usage of `runCommand`
in the second part will necessarily build the derivation which is returned from
the function.

The second step is to create the expected output. In this case, the above
invocation should create the following output:

```yaml
repos:
  - hooks:
      - id: my-hook
    repo: https://github.com/my/repo
    rev: "1.0"
```

The generateed output will be compared to this and the test will fail if a
difference is found.

The final step is to add the tests to the `checks` output in the main
`flake.nix` file:

```nix
{
    checks = {
        #...
        pre-commit = pkgs.callPackage ./tests/pre-commit { inherit pkgs plugins; };
        #...
    };
}
```

Finally, before submitting a PR, documentation should be added under the
[plugins][9] section of the documentation. This should cover general usage
information about the plugin including an example invocation.

[1]: https://github.com/jmgilman/nixago/tree/master/plugins
[2]: https://github.com/jmgilman/nixago/blob/master/plugins/default.nix
[3]: https://github.com/jmgilman/nixago/blob/master/flake.nix
[4]: https://pre-commit.com/
[5]: https://cuetorials.com/overview/types-and-values/#definitions
[6]: https://cuetorials.com/overview/types-and-values/#structs
[7]: https://cuelang.org/docs/integrations/
[8]: https://github.com/jmgilman/nixago/tree/master/tests
[9]: https://github.com/jmgilman/nixago/tree/master/docs/plugins

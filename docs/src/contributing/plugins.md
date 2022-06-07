# Plugins

Contributing plugins to Nixago is a multi-step process. Fortunately, the design
of Nixago makes these steps relatively straightforward.

## Checklist

The following is a helpful checklist to go over before submitting a PR:

1. Does the plugin have a dedicated directory under [plugins][1]?
1. Does the plugin have tests written for it?
1. Does the plugin have a dedicated page in the documentation?

If you answered yes to all of the above questions, you are ready to submit a PR!

## Plugin Structure

It's helpful to understand the overall structure of a plugin before diving in to
build one. Each plugin lives in a dedicated directory under the [plugins][1]
directory. The structure of the directory follows a basic format:

- `default.nix`
- `make_<type>.nix`
- `templates/<type>.cue`

### Plugin declaration

The plugin is first _declared_ in the `default.nix`:

```nix
{ pkgs, lib }:
{
  name = "myPlugin"; # The name of the plugin (should match directory name)
  types = { # An attribute set of the types of configurations this plugin makes
    default = { # The default type
      output = "my_plugin.yaml"; # The default output file
      make = import ./make_default.nix { inherit pkgs lib; }; # The type func
    };
    anotherType = { # Another type
      output = "my_plugin.yaml";
      make = import ./make_another_type.nix { inherit pkgs lib; };
    };
  };
}
```

All plugins should receive the `{ pkgs, lib }` set as the first argument. The
flake supplies this set, and it contains a copy of `nixpkgs` and the internal
`lib` set.

The function should return a set with the format shown above. Most plugins only
have one type (`default`). However, some tools have multiple files for
configuring them, and having the ability to designate various types allows this
requirement to be met. For example, the `prettier` plugin generates both a
configuration file and an ignore file.

Each type has two attributes: the `output` defines the default path (relative to
the root) of the file that should be generated (the user can override this), and
the `make` defines the function that should be called when this plugin type is
executed. We will discuss this function next.

### Plugin function

Each declared type of the plugin has an associated function. This function is
called when the user invokes the [make][2] function and specifies this plugin
and type. Each function should live in a separate file with the following naming
scheme: `make_<type>.nix`. This is the format of the function:

```nix
{ pkgs, lib }:
userData:
{ }
```

Believe it or not, this is a valid plugin! It will make more sense soon. Each
function takes an attribute set similar to the one seen in the previous section.
The second argument (`userData`) is an instance of the [request][3] module. Note
that not all options are required to be specified (only `name` and
`configData`).

The plugin is expected to return an attribute set that contains a partial
definition of the [request][3] module. Any values provided here **will
override** the values provided by the user. Thus, if you want to transform the
`configData`, do so in the function body and return it to the set. It will then
override the user-supplied data. Many plugins perform this operation to take
input from the data in one format and then convert it to the format expected by
the configuration file being generated.

Refer to the module definition for all of the available options. Many options
for influencing the way `cue` is executed can also be provided. For an overview
of basic patterns, refer to existing plugin functions.

### Plugin template

Each plugin should have a `templates` subfolder that contains all of the CUE
files used by the plugin. The naming of each CUE file is unimportant; however,
the package that they are included in matters. When a plugin is executed, the
specified type determines which CUE files are evaluated. For example, if the
`default` type is specified, then the files which are in the `default` package
will be evaluated:

```cue
package default

// CUE file contents
```

It's possible to have multiple files belonging to the same package. All files
will be joined together at evaluation time. This feature makes it easy to break
up large CUE files into more manageable chunks.

You may want to re-use a file for multiple types in some cases. In this case,
you may override the `package` attribute in the function:

```nix
{ pkgs, lib }:
userData:
{
  package = "use_this_package";
}
```

## Creating a Plugin

Creating a plugin encompasses three primary tasks:

1. Create the plugin declaration
1. Create functions for each type
1. Create CUE files for each type
1. Create tests and documentation

You should isolate each plugin to a dedicated directory under [plugins][1]. The
first step is to create a new directory with the plugin's name. The name should
ideally indicate the tool that it supports (i.e., the plugin for the Prettier
formatter is called `prettier`).

The remainder of this section will walk through creating a plugin for the
[lefthook][4] CLI tool. The plugin will generate a `lefthook.yml` file to
configure the lefthook tool.

### Creating the declaration

As discussed in the previous section, each function is declared in the
`default.nix` at the root of the plugin directory. Here is the declaration for
our plugin:

```nix
{ pkgs, lib }:
{
  name = "lefthook";
  types = {
    default = {
      output = "lefthook.yml";
      make = import ./make_default.nix { inherit pkgs lib; };
    };
  };
}
```

This should be self-explanatory. The only thing worth noting is the default
output matches what the lefthook tool looks for by default (a `lefthook.yml`
file at the root of the repository).

### Creating the function

The next step is creating our function in `make_default.nix`:

```nix
{ pkgs, lib }:
userData:
with pkgs.lib;
let
  inherit (userData) configData;
  lefthook = pkgs.lefthook;

  # Add an extra hook for adding required stages whenever the file changes
  skip_attrs = [
    "colors"
    "extends"
    "skip_output"
    "source_dir"
    "source_dir_local"
  ];
  stages = builtins.attrNames (builtins.removeAttrs configData skip_attrs);
  stagesStr = builtins.concatStringsSep " " stages;
  shellHookExtra = ''
    # Install configured hooks
    for stage in ${stagesStr}; do
      ${lefthook}/bin/lefthook add -a "$stage"
    done
  '';
in
{
  inherit shellHookExtra;
}
```

This is where we place the meat of the logic for our plugin. In the above case,
we need to perform an extra step when the shell hook activates to ensure that
all of the pre-commit stages we defined in the configuration get installed into
the local `.git/hooks` directory. The stages are declared at the root of the
configuration, along with some other options. We strip these options to get the
stages by themselves and then put them into a space-separated string.

The `shellHookExtra` option allows passing a block of shell code that will be
executed whenever the configuration file is updated. Since the user may have
added more stages to the configuration file, we add some logic to install all
stages whenever the file changes.

As noted earlier, we return all of our desired changes in a set. This set will
be joined with the one provided by the user to make the final request instance
which is used to generate the configuration file.

### Creating the CUE file

Review the [CUE section](design.md#cue) of the design page for more information
about CUE. Each type of the plugin typically utilizes a single CUE file,
although more advanced cases may require multiple files.

When creating the CUE file, keep the following in mind:

- The schema defined in the file should be sufficient to prevent most
  configuration mistakes.

- If the supported tool has rich documentation around valid values for each
  configuration field, use constraints to improve the accuracy of the schema.

- Don't be overly strict with the schema definition. The goal is to be helpful
  and not generate many false negatives.

Here is the `templates/default.cue` file for our plugin:

```cue
package default

#Config: {
    [string]: #Hook
    colors?: bool | *true
    extends?: [...string]
    skip_output?: [...string]
    source_dir?: string
    source_dir_local?: string
    ...
}

#Hook: {
    commands?: [string]: #Command
    exclude_tags?: [...string]
    parallel?: bool | *false
    piped?: bool | *false
    scripts?: [string]: #Script
    ...
}

#Command: {
    exclude?: string
    files?: string
    glob?: string
    root?: string
    run: string
    skip?: bool | [...string]
    tags?: string
    ...
}

#Script: {
    runner: string
    ...
}

{
    #Config
}
```

This file defines four [definitions][5], denoted by the `#` symbol. A definition
is synonymous with a schema or contract. It describes the shape of valid data
through various constraints. Let's break one down:

```cue
#Config: {
    [string]: #Hook
    colors?: bool | *true
    extends?: [...string]
    skip_output?: [...string]
    source_dir?: string
    source_dir_local?: string
}
```

Each definition typically encompasses a single layer of the configuration file.
The `#Config` definition encompasses the top layer. The top layer contains
global options which change the behavior of the tool (i.e., `source_dir`) and a
map of stage names to their respective hook definition (`[string]: #Hook`). The
`?` at the end of the names denotes that they are optional.

Definitions can reference other definitions, as seen by the `[string]: #Hook`
line. This says that the data must contain a string name that has a body that is
compatible with the `#Hook` definition.

```cue
{
    #Config
}
```

This final bit is where we define the elements of the CUE file. This is what
will appear when we evaluate the CUE file. In the above case, we're saying the
input data should be a [struct][6] that conforms to the schema defined by
`#Config`.

We're doing no additional transformations to the incoming data in this case. We
expect the input data to be in the format defined in the `lefthook.yml` file.
Since YAML is a superset of JSON, we can easily ask CUE to evaluate the input
and produce a YAML output.

### Writing Tests and Documentation

The final step is to write tests and documentation for the plugin. Tests live in
the [tests][7] directory in a dedicated directory named after the plugin. Tests
are relatively trivial to write.

The first step is to create a `default.nix` which runs the test:

```nix
{ runTest }:
{ runTest }:
let
  name = "lefthook";
  expected = ./expected.yml;
  configData = {
    commit-msg = {
      scripts = {
        template_checker = { runner = "bash"; };
      };
    };
    pre-commit = {
      commands = {
        stylelint = {
          tags = "frontend style";
          glob = "*.js";
          run = "yarn stylelint {staged_files}";
        };
        rubocop = {
          tags = "backend style";
          glob = "*.rb";
          exclude = "application.rb|routes.rb";
          run = "bundle exec rubocop --force-exclusion {all_files}";
        };
      };
      scripts = {
        "good_job.js" = { runner = "node"; };
      };
    };
  };
in
runTest {
  inherit configData expected name;
}
```

The `runTest` helper function provided performs most of the underlying work
required to test the plugin. It takes three arguments: the plugin's name to
execute, a path to a file with the expected result, and the configuration data
to use.

The second step is to create the expected output. In this case, the above
invocation should produce the following result:

```yaml
commit-msg:
  scripts:
    template_checker:
      runner: bash
pre-commit:
  commands:
    rubocop:
      exclude: application.rb|routes.rb
      glob: "*.rb"
      run: bundle exec rubocop --force-exclusion {all_files}
      tags: backend style
    stylelint:
      glob: "*.js"
      run: yarn stylelint {staged_files}
      tags: frontend style
  scripts:
    good_job.js:
      runner: node
```

The expected result is compared to the generated output, and the test will fail
if there is a difference.

Finally, before submitting a PR, add documentation under the [plugins][8]
section of the documentation. Ensure you cover general usage information about
the plugin, including an example invocation.

[1]: https://github.com/jmgilman/nixago/tree/master/plugins
[2]: https://github.com/jmgilman/nixago/blob/master/lib/make.nix
[3]: https://github.com/jmgilman/nixago/blob/issues/9/modules/request.nix
[4]: https://github.com/evilmartians/lefthook
[5]: https://cuetorials.com/overview/types-and-values/#definitions
[6]: https://cuetorials.com/overview/types-and-values/#structs
[7]: https://github.com/jmgilman/nixago/tree/master/tests
[8]: https://github.com/jmgilman/nixago/tree/master/docs/plugins

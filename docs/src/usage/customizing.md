# Customizing

It's possible to completely bypass the usage of plugins and generate
configuration files directly. This mode of operation requires familization with
[CUE][1] and it's associated CLI tool. See the
[design section](../contributing/design.md#cue) for more information.

Nixago provides a single function for generating custom configurations:
[make_custom][2]. It takes a single argument in the form of the [request
module][3]. The request module is the primary data container that holds all
options used for generating configuration files. Refer to the module source for
the available options.

## Creating a CUE file

Before continuing on in this section, ensure you've setup a `flake.nix` and
added Nixago as an input.

When creating a custom configuration, you will need to supply the CUE files that
will validate and generate the output structure. Refer to the [plugins][4]
directory for examples of these CUE files. For this example, we will create a
configuration for the [lefthook][5] CLI tool:

```cue
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

We will place this file in a subdirectory: `templates/lefthook.cue`.

## Creating a Request

The request module is made up of three submodules: `cue`, `hook`, and `plugin`.
The latter is not useful to us when creating custom configurations. The `cue`
submodule provides options for controlling the CUE CLI tool and the `hook`
submodule provides options for controlling the output of the generated shell
hook.

When creating a custom configuration, only three options are mandatory:

- `configData`: The configuration data to be used in generation
- `cue.path`: The path where CUE should look for `.cue` files
- `cue.format`: The output format that CUE should produce

For our example, we'll specify the following configuration data:

```nix
{
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
}
```

The CUE path should point to our `templates` subdirectory and the output we want
is YAML. We will make the generated configuration file an output of our flake so
that we can build it:

```nix
{
    # ...
    packages.lefthook = (nixago.lib.makeCustom {
          inherit configData;
          cue.path = ./templates;
          cue.format = "yaml";
        }).configFile;
    # ...
}
```

Now we can build our configuration file:

```bash
nix build -o lefthook.yml .#lefthook
```

The result should be a `lefthook.yml` file in our local directory with the
following contents:

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

There are several more options available for controlling the generation process,
including configuring a shell hook and passing custom flags to the CUE CLI tool.

[1]: https://cuelang.org/
[2]: https://github.com/jmgilman/nixago/blob/master/lib/make_custom.nix
[3]: https://github.com/jmgilman/nixago/blob/master/modules/request.nix
[4]: https://github.com/jmgilman/nixago/tree/master/plugins
[5]: https://github.com/evilmartians/lefthook

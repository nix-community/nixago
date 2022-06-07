# Controlling Output

The `make` function takes additional arguments which augment the output
produced.

## Types

Some plugins can generate different types of configuration files. See the
documentation for each plugin for more information. In the quick start example,
we used the `simple` type provided by the pre-commit plugin. This type allows
passing a simplified configuration that is geared towards executing local hooks.
Another example is the plugin for prettier, which can create regular
configuration files as well as ignore files:

```nix
{
  prettier = nixago.lib.make {
    name = "prettier";
    configData = ["file1.txt" "file2.yml" ];
    type = "ignore";
  };
}
```

## Output Path

By default, the shell hook for each plugin will generate the configuration file
at the root of your repository (i.e., the location where `flake.nix` resides).
The file name and relative location can be modified:

```nix
{
# ...
    preCommit = nixago.lib.make {
        name = "pre-commit";
        configData = preCommitConfig;
        output = ".config/pre-commit-config.yaml";
    };
# ...
}
```

The above example would place the configuration file in
`.config/pre-commit-config.yaml`.

## Generation Mode

The shell hook manages a symbolic link from the Nix store to the output path by
default. It automatically synchronizes any changes by updating the link if the
generated configuration file changes. This mode can be altered to instead
maintain a local copy of the generated configuration file. In this mode, the
shell hook compares the contents of the local copy to the one in the Nix store
and updates it accordingly. The primary benefit of this change is that it allows
the file to be checked into git, and if your Nix store is read-only, it can be
edited locally.

```nix
{
# ...
    preCommit = nixago.lib.make {
        name = "pre-commit";
        configData = preCommitConfig;
        mode = "copy";
    };
# ...
}
```

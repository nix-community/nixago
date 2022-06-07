# Quick Start

Nixago provides support for generating configurations for many different
development tools. Refer to the plugins section for a list of currently
supported tools or open up a new issue to request a tool be added.

## Add Nixago as an Input

The first step is adding Nixago as an input to your current `flake.nix`:

```nix
{
  inputs = {
    # ...
    nixpkgs.url = "github:nixos/nixpkgs";
    nixago.url = "github:jmgilman/nixago";
    nixago.inputs.nixpkgs.follows = "nixpkgs";
    # ...
  };
}
```

To maintain consistency in the packages being used across your `flake.nix`, it's
recommended to force Nixago's copy to follow the one declared in your flake.

## Generate a Configuration

Choose a plugin to use. The below example uses the plugin for [pre-commit][1]:

```nix
{
# ...
    preCommitConfig = {
        nixpkgs-fmt = {
            entry = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
            language = "system";
            files = "\\.nix";
        };
    };

    preCommit = nixago.lib.make {
        name = "pre-commit";
        type = "simple";
        configData = preCommitConfig;
    };
# ...
}
```

The easiest way to integrate the generated configuration into your development
environment is to use the provided shell hook:

```nix
{
# ...
    devShell = pkgs.mkShell {
        shellHook = nixago.lib.mkShellHook [ preCommit ];
    };
# ...
}
```

The hook will automatically link the file from the Nix store to the current
working directory. The above example will produce a `.pre-commit-config.yaml`
file with the following contents:

```yaml
repos:
  - hooks:
      - entry: /nix/store/pmfl7q4fqqibkfz71lsrkcdi04m0mclf-nixpkgs-fmt-1.2.0/bin/nixpkgs-fmt
        files: \.nix
        id: nixpkgs-fmt
        language: system
        name: nixpkgs-fmt
    repo: local
```

## Changing Types

Some plugins can generate different types of configuration files. See the
documentation for each plugin for more information. Our previous example used
the `simple` type provided by the pre-commit plugin. This type allows passing a
simplified configuration that is geared towards executing local hooks. Another
example is the plugin for prettier, which can create regular configuration files
as well as ignore files:

```nix
{
  prettier = nixago.lib.make {
    name = "prettier";
    configData = ["file1.txt" "file2.yml" ];
    type = "ignore";
  };
}
```

## Changing Output Path

By default, the shell hook for each plugin will generate the configuration file
at the root of your repository (i.e., the location where `flake.nix` resides).
The file name and relative location can be modified:

```nix
{
# ...
    preCommitConfig = {
        nixpkgs-fmt = {
            entry = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
            language = "system";
            files = "\\.nix";
        };
    };

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

## Changing Generation Mode

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
    preCommitConfig = {
        nixpkgs-fmt = {
            entry = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
            language = "system";
            files = "\\.nix";
        };
    };

    preCommit = nixago.lib.make {
        name = "pre-commit";
        configData = preCommitConfig;
        mode = "copy";
    };
# ...
}
```

## Making Multiple Configurations

A utility function is available for generating multiple configurations. The
following is an excerpt from the `flake.nix` that manages this project:

```nix
{
# Define development tool configuration
configurations = [
  # Conform configuration
  {
    name = "conform";
    configData = {
      commit = {
        header = { length = 89; };
        conventional = {
          types = [
            "build"
            "chore"
            "ci"
            "docs"
            "feat"
            "fix"
            "perf"
            "refactor"
            "style"
            "test"
          ];
          scopes = [
            "conform"
            "just"
            "lefthook"
            "pre-commit"
            "prettier"
            "core"
            "flake"
          ];
        };
      };
    };
  }

  # ....

  # Prettier
  {
    name = "prettier";
    configData = {
      proseWrap = "always";
    };
  }
  {
    name = "prettier";
    type = "ignore";
    configData = [
      ".direnv"
      ".conform.yaml"
      ".prettierrc.json"
      "tests"
      "CHANGELOG.md"
      "lefthook.yml"
    ];
  }
];

# ...

# Local development shell
devShells = {
  default = pkgs.mkShell {
    shellHook = (lib.mkAll configurations).shellHook;
    packages = tools.all;
  };
};
}
```

The input to `mkAll` is a list of configurations. The attribute sets in the list
match the same arguments that the `lib.make` function accepts. The only
difference is that `mkAll` returns a list of the created derivations and a
single `shellHook` encompassing all generated configuration files.

[1]: https://pre-commit.com/

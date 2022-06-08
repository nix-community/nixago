# Quick Start

Nixago is a tool for producing templated configuration files using data from Nix
expressions. It ships with plugins to validate and generate configuration files
for several development tools. The quickest way to get started is by using one
of these plugins.

## Add Nixago as an Input

The first step is adding Nixago to your `flake.nix`:

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

To maintain consistency in the packages used across your `flake.nix`, it's
recommended to force Nixago's copy to follow the ones declared in your flake.

Alternatively, you can download a starter template:

```bash
nix flake init --template github:jmgilman/nixago
```

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

The main entry point Nixago provides is via the [make][2] function. At the
minimum, it needs a plugin name and configuration data for generating the file.
Some plugins take an optional type argument that specifies which type of file to
generate. In the example above, we opt to use the "simple" type that takes a
simplified configuration format for using pre-commit with local commands. For
more information, see the [pre-commit][3] plugin page.

The result from calling `make` is an attribute set with two entries:
`configFile`, which holds the derivation for generating the file, and
`shellHook`, which contains a shell hook for managing the file.

The easiest way to integrate the generated configuration into your development
environment is to use the shell hook:

```nix
{
# ...
    devShell = pkgs.mkShell {
        shellHook = preCommit.shellHook;
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

Note that using the shell hook is optional. It's possible to use the derivation
directly as an output of your flake:

```nix
{
# ...
    packages.precommit = preCommit.configFile;
# ...
}
```

You can then build it locally with:

```bash
nix build #.precommit
```

[1]: https://pre-commit.com/
[2]: https://github.com/jmgilman/nixago/blob/master/lib/make.nix
[3]: https://jmgilman.github.io/nixago/plugins/pre-commit.html

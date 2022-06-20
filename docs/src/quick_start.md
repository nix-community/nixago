# Quick Start

Add Nixago as an input to your `flake.nix`:

```nix
{
  inputs = {
    # ...
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixago.url = "github:nix-community/nixago";
    nixago.inputs.nixpkgs.follows = "nixpkgs";
    # ...
  };
}
```

## Generate a Configuration

Nixago offers [various engines](./engines/index.md) which can be used for
transforming input data into an output file. Nixago will default to the
[nix engine](./engines/nix.md) that utilizes `pkgs.formats` from [nixpkgs][1].

```nix
let
  configData = {
    "field1" = "value1";
    "field2" = true;
  };
in
nixago.lib.make {
  inherit configData;
  output = "config.json";
  format = "json";
  engine = nixago.engines.nix { }; # Optional as this is the default value
}
```

The result of this invocation will be an attribute set with two attributes:

- `configFile`: A derivation for building the configuration file.
- `shellHook`: A shell hook for managing the file.

Building the derivation produces a file with the following output:

```json
{
  "field1": "value1",
  "field2": true
}
```

The `make` function takes an attribute set that supports the options defined in
the [request module][2]. Please refer to the module definition for all of the
available options.

## Using the Shell Hook

The generated shell hook will link the generated configuration file to one of
two places:

- If `$PRJ_ROOT` is defined, the file will be linked to `$PRJ_ROOT/{output}`
  where `output` is the relative path defined in the call to `make`.
- If `$PRJ_ROOT` is not defined, the file will be linked to `./{output}`, where
  the relative path is determined by where the Nix CLI was invoked.

For example, if `$PRJ_ROOT` is set to `/home/user/code/myprj` and the output is
specified as `configs/config.json` then the file will be linked to
`/home/user/code/myprj/configs/config.json`.

The shell hook is designed to be integrated into a development shell:

```nix
{
  # ...
  devShells = {
    default = pkgs.mkShell {
      shellHook = (nixago.lib.make config).shellHook;
    };
  };
 # ...
}
```

This will ensure the file is generated and linked when you enter the shell. The
behavior of the hook can be modified via the [available options][3].

## Extending Nixago

An [additional repository][4] is available that provides extensions for Nixago.
These simplify the process of generating configuration files for common
development tools.

[1]: https://github.com/NixOS/nixpkgs/blob/master/pkgs/pkgs-lib/formats.nix
[2]: https://github.com/nix-community/nixago/blob/master/modules/request.nix
[3]: https://github.com/nix-community/nixago/blob/master/modules/request.nix#L8
[4]: https://github.com/nix-community/nixago-extensions

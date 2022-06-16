# Nix Engine

The nix engine uses the set of functions provided by `pkgs.formats`. [You can
see the source here][1].

## Concepts

The basic outline of an entry in `pkgs.formats` is as follows:

```nix
{
    format = {}: {
        generate = name: value: pkgs.runCommand {...};
    };
}
```

Where `format` is the name of the supported format (i.e., `json`).

Note that the `format` entry is a function that takes a single attribute set. In
some cases, this is an empty set, but in other cases, the set contains
additional options for configuring the format.

## Usage

When using the `nix` engine from Nixago, one can pass attributes to the set with
the following:

```nix
{
    engine = nixago.lib.engines.nix { opt1 = "value1"; };
}
```

The provided set will be passed to the `format` argument before calling its
`generate` function.

When calling `make`, the specified value for the `format` attribute will be used
to determine which entry in `pkgs.formats` to invoke. Thus, specifying an
unsupported format will result in an assertion error. Refer to the [nixpkgs
source code][1] to determine the currently supported output formats.

[1]: https://github.com/NixOS/nixpkgs/blob/master/pkgs/pkgs-lib/formats.nix

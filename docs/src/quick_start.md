# Quick Start

The first step is to add Nixago as an input to your `flake.nix`:

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

To maintain consistency in the packages being used across flake, it's
recommended to force Nixago's copy to follow the one declared in your flake.

## Generate a Configuration

Nixago offers various engines which can be used for transforming input data to the output file. By default, Nixago will use
`pkgs.formats` from the internal Nix library.

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
}
```

This is functionally equivalent to:

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
  engine = nixago.lib.engines.nix { };
}
```

The first example omitted the engine attribute as it is the default value used
when an engine isn't specified.

The result of this invocation will be an attribute set with two attributes:

- `configFile`: A derivation for building the configuration file
- `shellHook`: A shell hook for managing the file

Building the derivation produces a file with the following output:

```json
{
  "field1": "value1",
  "field2": true
}
```

The generated shell hook invokes the following script:

```bash
#!/nix/store/63a4li401f423jl8v5pwjwmyzlwd3lk9-bash-5.1-p16/bin/bash
# Check if the link is pointing to the existing derivation result
if readlink config.json >/dev/null \
  && [[ $(readlink config.json) == /nix/store/gzf07xc8563kzvh157i27zpkr3cifzdv-config.json ]]; then
  log "config.json link is up to date"
elif [[ -L config.json || ! -f config.json ]]; then
  # otherwise we need to update
  log "config.json link updated"

  # Relink to the new result
  unlink config.json &>/dev/null
  ln -s /nix/store/gzf07xc8563kzvh157i27zpkr3cifzdv-config.json config.json

  # Run extra shell hook

else
  # this was an existing file
  error "refusing to overwrite config.json"
fi
```

# Nixago

<p align="center">
    <a href="https://github.com/nix-community/nixago/actions/workflows/ci.yml">
        <img src="https://img.shields.io/github/workflow/status/nix-community/nixago/CI?label=CI"/>
    </a>
    <a href="https://nix-community.github.io/nixago">
        <img src="https://img.shields.io/github/workflow/status/nix-community/nixago/CI?label=Docs"/>
    </a>
    <img src="https://img.shields.io/github/license/nix-community/nixago"/>
    <a href="https://builtwithnix.org">
        <img src="https://img.shields.io/badge/-Built%20with%20Nix-green">
    </a>
</p>

> Generate configuration files using [Nix][1].

Ready to dynamically generate configuration files in your flake-based setup?
Nixago is a flake library for generating configuration files using Nix
expressions as the data source.

## Features

- Specify configuration data using native [Nix][1] syntax
- Generate configuration files using any of the [supported engines][2]
- Places all artifacts in the Nix store
- [Extensions][3] are provided for getting started

## Usage

See the [quick start][4] for how to get started.

## Testing

Tests are run with:

```shell
nix flake check
```

## Contributing

[Read this][5], check out the [issues][6] for items needing attention or submit
your own, and then:

1. Fork the repo (<https://github.com/nix-community/nixago/fork>)
2. Create your feature branch (git checkout -b feature/fooBar)
3. Commit your changes (git commit -am 'Add some fooBar')
4. Push to the branch (git push origin feature/fooBar)
5. Create a new Pull Request

[1]: https://nixos.org/
[2]: https://nix-community.github.io/nixago/engines/index.html
[3]: https://github.com/nix-community/nixago-extensions
[4]: https://nix-community.github.io/nixago/quick_start.html
[5]: https://nix-community.github.io/nixago/contributing
[6]: https://github.com/nix-community/nixago/issues

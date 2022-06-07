# Nixago

<p align="center">
    <a href="https://github.com/jmgilman/nixago/actions/workflows/ci.yml">
        <img src="https://img.shields.io/github/workflow/status/jmgilman/nixago/CI?label=CI"/>
    </a>
    <a href="https://jmgilman.github.io/nixago">
        <img src="https://img.shields.io/github/workflow/status/jmgilman/nixago/CI?label=Docs"/>
    </a>
    <img src="https://img.shields.io/github/license/jmgilman/nixago"/>
    <a href="https://builtwithnix.org">
        <img src="https://img.shields.io/badge/-Built%20with%20Nix-green">
    </a>
</p>

> Generate configuration files using [Nix][1].

Ready to dynamically generate configuration files in your flake-based setup?
Nixago is a flake library for easily generating configuration files using Nix
expressions as the data source. It provides a rich [plugin system][2] for
quickly generating configuration files for common development tools but can also
be easily [customized][3] to fit any scenario.

## Features

- Specify configuration data using native [Nix][1] syntax
- Validate configuration data using the language features from [Cue][4]
- Generate configuration files in any of the [supported formats][5]
- Places all artifacts in the Nix store
- Provides [plugins][2] for generating several types of configuration files

## Usage

See the [quick start][6] for how to get started.

## Testing

Tests are run with:

```shell
nix flake check
```

## Contributing

[Read this][7], check out the [issues][8] for items needing attention or submit
your own, and then:

1. Fork the repo (<https://github.com/jmgilman/nixago/fork>)
2. Create your feature branch (git checkout -b feature/fooBar)
3. Commit your changes (git commit -am 'Add some fooBar')
4. Push to the branch (git push origin feature/fooBar)
5. Create a new Pull Request

[1]: https://nixos.org/
[2]: https://jmgilman.github.io/nixago/plugins/index.html
[3]: https://jmgilman.github.io/nixago/usage/customizing.html
[4]: https://cuelang.org/
[5]: https://cuelang.org/docs/integrations/
[6]: https://jmgilman.github.io/nixago/usage/quick_start.html
[7]: https://jmgilman.github.io/nixago/contributing
[8]: https://github.com/jmgilman/nixago/issues

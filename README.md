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

> The central source of truth for your development tools

Are you tired of having multiple configuration files for your development tools
littering the root of your repositories? Nixago aims to allow your local
`flake.nix` to act as the central source of truth for configuring your
development tools. You can declare the configuration for all of your development
tools in your flake file and Nixago will do the work of generating and
maintaining the configuration files for you.

## Features

- Specify configuration data using native [Nix][1] syntax
- Validate configuration data using the language features from [Cue][2]
- Generate configuration files in any of the [supported formats][3]
- Places all artifacts in the Nix store
- Provides [plugins][4] for generating several types of configuration files

## Usage

See the [quick start][5] for how to get started.

## Testing

Tests are run with:

```shell
nix flake check
```

## Contributing

[Read this][6], check out the [issues][7] for items needing attention or submit
your own, and then:

1. Fork the repo (<https://github.com/jmgilman/nixago/fork>)
2. Create your feature branch (git checkout -b feature/fooBar)
3. Commit your changes (git commit -am 'Add some fooBar')
4. Push to the branch (git push origin feature/fooBar)
5. Create a new Pull Request

[1]: https://nixos.org/
[2]: https://cuelang.org/
[3]: https://cuelang.org/docs/integrations/
[4]: https://jmgilman.github.io/nixago/plugins/index.html
[5]: https://jmgilman.github.io/nixago/quick_start.html
[6]: https://jmgilman.github.io/nixago/contributing/design
[7]: https://github.com/jmgilman/nixago/issues

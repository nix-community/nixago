# Introduction

Nixago is a [flake][1] library for generating configuration files. It's
primarily geared towards reducing clutter at the root of your repository added
by various development tools (i.e. formatters, linters, etc.). However, Nixago
is [flexible enough](./usage/customizing.md) to generate configuration files for
practically any scenario.

The plugin-based approach makes it easy to extend Nixago to cover any
development tool you may use across your projects. Nixago ships with
[plugins](./plugins.md) for many different tools and we encourage others to
[submit their own](./contributing/plugins.md).

Underneath the hood, Nixago uses [Nix][2] and [Cue][3] for generating
configuration files. It's designed to be used in tandem with a [nix shell][4] to
dynamically create and manage configuration files in your existing development
environments. All that's required is defining the configurations in the
`flake.nix` file at the root of your repository, and Nixago will automatically
generate shell hooks that can be used to create and manage the files.

Don't see a plugin for your development tool? [Submit a new feature request][5].

[1]: https://nixos.wiki/wiki/Flakes
[2]: https://nixos.org/
[3]: https://cuelang.org/
[4]: https://nixos.org/manual/nix/stable/command-ref/nix-shell.html
[5]: https://github.com/jmgilman/nixago/issues/new

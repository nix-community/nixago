# Introduction

Nixago is a [flake][1] library for generating configuration files. It's
primarily geared towards reducing clutter at the root of your repository added
by various development tools (i.e., formatters, linters, etc.). However, Nixago
is flexible enough to generate configuration files for most scenarios.

Nixago is designed to be used in tandem with a [nix shell][2] to dynamically
create and manage configuration files in your existing development environments.
Define the configurations in the `flake.nix` file at the root of your
repository, and Nixago will automatically generate shell hooks for managing the
files.

[1]: https://nixos.wiki/wiki/Flakes
[2]: https://nixos.org/manual/nix/stable/command-ref/nix-shell.html

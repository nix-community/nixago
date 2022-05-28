# Nixago

Nixago is a [flake][1] library that provides functions for generating
configuration files using [Nix][2] and [Cue][3]. It's primary use is for
generating configuration files for development tools when using a [nix shell][4]
for setting up the development environment. You define the configuration data in
your Nix file and then call out to Nixago to generate it.

[1]: https://nixos.wiki/wiki/Flakes
[2]: https://nixos.org/
[3]: https://cuelang.org/
[4]: https://nixos.org/manual/nix/stable/command-ref/nix-shell.html

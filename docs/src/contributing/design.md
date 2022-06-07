# Design

When contributing to Nixago, it's essential to understand the general design
principles that guide its development. This section provides details on how the
library is structured and introduces the basic concepts required to contribute
effectively.

## Overview

```mermaid
%%{ init : { "theme" : "dark", "flowchart" : { "curve" : "linear" }}}%%
%%
flowchart TD
    flake{{User's flake.nix}}
    make(Call to make)
    plugin(Plugin is called)
    generate(Call to generate)
    eval(Call to eval)
    flake -- request ---> make
    make <-- request ---> plugin
    make <-- user + plugin request ---> generate
    generate --> eval
    make -- result --> flake
```

Nixago uses a [plugin-based][1] infrastructure to enable easily extending its
support for various configuration files. Plugins act as a middle-man by taking
input from the end-user, applying any potential modifications or additions, and
then sending it off to be generated into the resulting configuration file.

The flow chart above demonstrates the basic data flow from when the user calls
into Nixago to when they receive the resulting configuration. Nixago utilizes
three primary functions to accomplish this.

### Make

The [make][2] function is the main entry point into Nixago. The end-user calls
this function and specifies the plugin to interact with and the configuration
data used to generate the resulting configuration file. The `make` function uses
this data to build the first [request][3]. The request module serves as the
primary data container and is passed around internally when performing
generation.

One of the primary functions of `make` is to call the plugin specified by the
end-user. The plugin will receive a copy of the current request and return its
version. The plugin version may opt to override any of the details included in
the user request; however, it typically only adds additional components, for
example, other flags and files to pass to `eval`.

The `make` function then merges the user request and plugin request modules into
a final unified version passed to the `generate` function.

### Generate

The [generate][4] function is responsible for building the final result returned
to the user. The result includes a derivation that produces the specified
configuration file and a shell hook for managing it. The primary function of
`generate` is to pull the necessary contextual information out of the request
and call `eval` to create the derivation. Secondary to this is building the
correct shell hook and packaging all of this in an attribute set that is
eventually returned to the end-user.

### Eval

The [eval][5] function is at the lowest level and is responsible for interacting
with [CUE][6] via its command-line interface. It takes the necessary contextual
information from `generate` and uses it to create a derivation using the
[runCommand][7] function.

### Result

The result returned to the end-user is an attribute set containing a derivation
and a shell hook. The shell hook has a dependency on the derivation through
interpolation. The derivation is eventually built once the user includes the
shell hook into their environment.

## CUE

The primary tool underlying Nixago is [CUE][1]. CUE stands for Configure, Unify,
and Execute. It's a general-purpose language for defining, generating, and
validating data. This flake chose CUE for its strengths in configuration
validation and generation. It's also a young project with a rapidly growing
platform.

Learning the CUE language is necessary for contributing plugins. Don't worry,
though. It's much easier to pick up than Nix. Please review the [Cuetorials
website][2] and the [Logic of CUE][3] to get an overview of the CUE language.

When creating a plugin, you'll need to write a CUE schema that can validate the
incoming configuration data. The schema ensures that configuration data is
accurate, and it also creates the foundation for transforming that data into the
format needed for the configuration file.

[1]: https://github.com/jmgilman/nixago/tree/master/plugins
[2]: https://github.com/jmgilman/nixago/blob/master/lib/make.nix
[3]: https://github.com/jmgilman/nixago/blob/issues/9/modules/request.nix
[4]: https://github.com/jmgilman/nixago/blob/master/lib/generate.nix
[5]: https://github.com/jmgilman/nixago/blob/master/lib/eval.nix
[6]: https://cuelang.org/
[7]:
  https://github.com/NixOS/nixpkgs/blob/1d44ac176ce6de74ac912a5b043e948a87a6d2f5/pkgs/build-support/trivial-builders.nix#L27

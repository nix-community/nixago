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
    engine(Call to engine)
    flake -- request ---> make
    make <-- request ---> engine
    make -- result --> flake
```

Nixago strives to meet the Unix philosophy of "do one thing and do it well." For
Nixago, this is generating and managing configuration files. Anything that falls
outside of this scope, or risks complicating internal structures, should be
moved to an external project.

The interface for Nixago is purposefully simple: all interactions work around
the [request][1] module. This module defines all required and optional fields
necessary to generate and manage a configuration file. Extending this interface
should not be the default choice, as unmitigated changes can result in muddying
the usefulness of the interface it provides.

Nixago promises two outputs: a derivation for building the specified
configuration file and a shell hook that manages the file locally. Nixago hands
control over to the user regarding how the configuration should be built and how
the hook should handle it.

## Engines

There are many ways to generate a configuration file. The only restraint that
Nixago imposes is that the input data must be a valid Nix expression. The entity
that translates this Nix expression into a derivation is called an _engine_.

The purpose of an engine is to receive and process a request. The request's
processing depends on the engine and its underlying tools. The only expectation
that Nixago has is that a derivation is returned.

For example, the `cue` engine uses the [CUE][2] CLI tool to process a list of
CUE files from the user, along with the user's input, to create a derivation
that produces the desired configuration file. This modular design allows Nixago
to be easily extended to support existing infrastructure.

[1]: https://github.com/nix-community/nixago/blob/master/modules/request.nix
[2]: https://cuelang.org/

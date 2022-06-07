# Making Multiple Configurations

A utility function is available for generating multiple configurations. The
following is an excerpt from the `flake.nix` that manages this project:

```nix
{
configurations = [
  # Conform configuration
  {
    name = "conform";
    configData = {
      commit = {
        header = { length = 89; };
        conventional = {
          types = [
            "build"
            "chore"
            "ci"
            "docs"
            "feat"
            "fix"
            "perf"
            "refactor"
            "style"
            "test"
          ];
          scopes = [
            "conform"
            "just"
            "lefthook"
            "pre-commit"
            "prettier"
            "core"
            "flake"
          ];
        };
      };
    };
  }

  # ....

  # Prettier
  {
    name = "prettier";
    configData = {
      proseWrap = "always";
    };
  }
  {
    name = "prettier";
    type = "ignore";
    configData = [
      ".direnv"
      ".conform.yaml"
      ".prettierrc.json"
      "tests"
      "CHANGELOG.md"
      "lefthook.yml"
    ];
  }
];

# ...

# Local development shell
devShells = {
  default = pkgs.mkShell {
    shellHook = (lib.makeAll configurations).shellHook;
    packages = tools.all;
  };
};
}
```

The input to `makeAll` is a list of configurations. The attribute sets in the
list match the same arguments that the `lib.make` function accepts. The only
difference is that `makeAll` returns a list of the created derivations and a
single `shellHook` for managing all generated configuration files.

# Pre-commit

This plugin generates the `.pre-commit-config.yaml` file used to configure
[pre-commit][1]. It provides two functions for generating the configuration.

## Using mkConfig

The first function follows the [structure described in the docs][2]:

```nix
{
  pre-commit = nixago.plugins.pre-commit.mkConfig {
    config = {
      repos = [
        {
          repo = "https://github.com/my/repo";
          rev = "1.0";
          hooks = [
            {
              id = "my-hook";
            }
          ];
        }
      ];
    };
  };
}
```

Cue validates the structure, and the derivation will fail to build if any
mistakes are found. The above configuration will create the following file
contents:

```yaml
repos:
  - hooks:
      - id: my-hook
    repo: https://github.com/my/repo
    rev: "1.0"
```

## Using mkLocalConfig

The second function accepts a simplified configuration format that significantly
reduces the verbosity. When managing pre-commit with Nix, creating a single
"local" repo entry and adding system hooks that call out to binaries in the Nix
store is often desirable. The benefit of this approach is that Nix manages the
versioning of the binaries, and you have greater control over how the hook
operates.

The accepted format is as follows:

```nix
{
    nixpkgs-fmt = {
        entry = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
        language = "system";
        files = "\\.nix";
    }
}
```

The format is a set consisting of hook names as the keys and their configuration
properties as values. The `id` and `name` fields of the hook configuration are
set to the hook name (i.e., `nixpkgs-fmt`). The `entry` should point to the
binary called by pre-commit. Setting `language` to "system" ensures that the
`entry` is called with the default shell. Finally, setting `files` ensures that
pre-commit only passes Nix files to this hook. The above configuration would
produce the following `pre-commit-config.yaml` file:

```yaml
repos:
  - hooks:
      - entry: /nix/store/pmfl7q4fqqibkfz71lsrkcdi04m0mclf-nixpkgs-fmt-1.2.0/bin/nixpkgs-fmt
        files: \.nix
        id: nixpkgs-fmt
        language: system
        name: nixpkgs-fmt
    repo: local
```

Notice how the `repos` and `repo` properties are set.

[1]: https://pre-commit.com/
[2]: https://pre-commit.com/#adding-pre-commit-plugins-to-your-project

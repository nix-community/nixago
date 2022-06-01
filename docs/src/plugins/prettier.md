# Prettier

This plugin generates the `.prettierrc.json` file for configuring [Prettier][1].
It provides a single function that allows you to configure any valid
API options][2].

## Using mkConfig

The schema for the configuration file is [detailed here][3]. For example:

```nix
{
    config = {
      arrowParens = "always";
      bracketSpacing = true;
      tabWidth = 80;
    };
}
```

Produces the following `.prettierrc.json`:

```json
{
  "arrowParens": "always",
  "bracketSpacing": true,
  "tabWidth": 80
}
```

It's possible to add [overrides][4] tied to specific file formats:

```nix
{
    config = {
      arrowParens = "always";
      bracketSpacing = true;
      tabWidth = 80;
      overrides = [
        {
          files = "*.js";
          options = {
            semi = true;
          };
        }
      ];
    };
}
```

Produces:

```json
{
  "arrowParens": "always",
  "bracketSpacing": true,
  "overrides": [
    {
      "files": "*.js",
      "options": {
        "semi": true
      }
    }
  ],
  "tabWidth": 80
}
```

[1]: https://prettier.io/
[2]: https://prettier.io/docs/en/options.html
[3]: https://prettier.io/docs/en/configuration.html
[4]: https://prettier.io/docs/en/configuration.html#configuration-overrides

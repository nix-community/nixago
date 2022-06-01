# Conform

This plugin generates the `.conform.yaml` file for configuring [Conform][1].
It provides a single function that takes a simplified version of the
configuration file:

- The top-level `policies` entry is removed
- The `type` and `spec` sections of the policy are removed

Instead, the function takes a set where the key is either `commit` or `license`
(the two valid policy types), and the value is what would typically get placed
under `spec`. This change reduces the overall nesting of the input.

Example input:

```nix
{
  commit = {
    header = {
      length = 89;
      imperative = true;
      case = "lower";
      invalidLastCharacters = ".";
    };
    gpg = {
      required = false;
      identity = {
        gitHubOrganization = "some-organization";
      };
    };
    conventional = {
      types = [
        "type"
      ];
      scopes = [
        "scope"
      ];
    };
  };
  license = {
    skipPaths = [
      ".git/"
      "build*/"
    ];
    allowPrecedingComments = false;
  };
}
```

This would produce the following `.conform.yaml` file:

```yaml
policies:
  - spec:
      conventional:
        scopes:
          - scope
        types:
          - type
      gpg:
        identity:
          gitHubOrganization: some-organization
        required: false
      header:
        case: lower
        imperative: true
        invalidLastCharacters: .
        length: 89
    type: commit
  - spec:
      allowPrecedingComments: false
      skipPaths:
        - .git/
        - build*/
    type: license
```

[1]: https://github.com/siderolabs/conform

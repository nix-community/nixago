# Github Settings

This plugin generates the `.github/settings.yml` file used by the [Settings
App][1].

## Usage

The schema for the configuration file is [detailed here][2]. For example:

```nix
{
  configData = {
    repository = {
      name = "repo-name";
      description = "description of repo";
      homepage = "https://example.github.io/";
      private = false;
    };
    labels = [
      {
        name = "bug";
        color = "CC0000";
        description = "An issue with the system";
      }
      {
        name = "feature";
        color = "#336699";
        description = "New functionality";
      }
    ];
    milestones = [
      {
        title = "milestone-title";
        description = "milestone-description";
        state = "open";
      }
    ];
  };
}
```

Produces the following `.github/settings.yml`:

```yaml
labels:
  - color: CC0000
    description: An issue with the system
    name: bug
  - color: "#336699"
    description: New functionality
    name: feature
milestones:
  - description: milestone-description
    state: open
    title: milestone-title
repository:
  description: description of repo
  homepage: https://example.github.io/
  name: repo-name
  private: false
```

[1]: https://github.com/probot/settings
[2]: https://github.com/probot/settings#usage

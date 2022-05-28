# Just

This plugin generates the `.just` file used by the [Just][1] task runner. It
provides a single function which allows you to declare a header section and
then subsequent tasks/steps.

## Using mkConfig

```nix
{
  just = plugins.just.mkConfig {
    config = {
      head = ''
        var := "value"
      '';
      tasks = {
        task1 = [
          ''echo "Doing the thing"''
          "@doThing"
        ];
      };
    };
  };
}
```

The configuration has two major sections. The first is the `header` field which
is a raw string that will be prepended to the top of the file. This is typically
where global settings and variables are defined in the Justfile. The second is
the `tasks` field which is a map of task names to a list of their respective
steps. Each step in the list should ideally encompass a single action (this is
idiomatic for Justfiles), however, multiline strings will also work.

The above example will produce the following file contents:

```just
var := "value"

task1:
    echo "Doing the thing"
    @doThing
```

[1]: https://github.com/casey/just

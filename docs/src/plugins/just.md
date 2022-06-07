# Just

This plugin generates the `.just` file used by the [Just][1] task runner. It
allows the creation of a `.justfile` by specifying a header and tasks:

## Usage

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

The configuration has two major sections. The first is the `header` field, a raw
string prepended to the top of the file. This section is typically where global
settings and variables are defined in the Justfile. The second is the `tasks`
field, a map of task names to a list of their respective steps. Each step in the
list should ideally encompass a single action (this is idiomatic for Justfiles);
however, multiline strings will also work.

The above example will produce the following file contents:

```just
var := "value"

task1:
    echo "Doing the thing"
    @doThing
```

[1]: https://github.com/casey/just

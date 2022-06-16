# CUE

This engine provides an interface for generating configuration files using the
[CUE language][1] and its associated [CLI tool][2]. It allows combining the
user-defined input with one or more CUE files and generating a file in the
designated output format.

For more information on the design of CUE, [see this doc][3]. A good place to
start learning the fundamentals is the [Cuetorials website][4].

## Concepts

### Merging

When using CUE, you will typically define one or more CUE files that will be
merged into the desired output. For example, if we had the below CUE file:

```cue
name: string
name: "John Doe"
```

We could then export it and get the following result:

```bash
$ cue export file.cue
{
    "name": "John Doe"
}
```

When CUE is presented with multiple files, they are all merged into one singular
output:

```cue
name: string
```

```cue
name: "John Doe"
```

```bash
$ cue export file1.cue file2.cue
{
    "name": "John Doe"
}
```

### Combining with JSON

CUE is a superset of JSON, so it's possible to merge JSON and CUE files. Using
our previous example, this time with JSON:

```cue
name: string
```

```json
{
  "name": "John Doe"
}
```

```bash
cue export file1.cue file2.json
{
    "name": "John Doe"
}
```

We get the same result because our JSON file and the previously defined CUE file
are functionally equivalent.

### Constraints

Performing input validation is a natural benefit when using the CUE language. We
used a [constraint][5] earlier when we constrained the `name` field to a string.
Continuing with our previous examples, if we modified the JSON structure to be
the following:

```json
{
  "name": 42
}
```

Then if we attempted to export both files, we would receive an error:

> name: conflicting values 42 and string (mismatched types int and string)

CUE is informing us that we constrained `name` to a `string`, and yet we passed
in an int (42) with our JSON data structure. This is a type mismatch and results
in an error.

### Exporting Modified Structures

A common use case is transforming an incoming structure into a modified outgoing
structure. Take the following input structure:

```json
{
  "first_name": "john",
  "last_name": "doe",
  "address": "123 Lane",
  "city": "Springfield",
  "state": "OR"
}
```

We only want to export the name and a combined address:

```cue
import "strings"

first_name: string
last_name: string
address: string
city: string
state: string

result: {
    name: strings.ToTitle(strings.Join([first_name, last_name], " "))
    full_address: "\(address)\n\(city), \(state)"
}
```

We can then ask CUE to _only_ render our `result` expression:

```bash
$ cue export -e result file1.cue file2.json
{
    "name": "John Doe",
    "full_address": "123 Lane\nSpringfield, OR"
}
```

This allows ingesting one data structure and exporting another. As shown in the
example, we can perform many permutations on the incoming data using CUE's
[standard library][6] and [interpolation][7].

## Usage

| Argument   | Required | Description                                   |
| ---------- | -------- | --------------------------------------------- |
| `files`    | Yes      | A list of file paths to pass to CUE           |
| `preHook`  | No       | A shell hook to execute before CUE is invoked |
| `postHook` | No       | A shell hook to execute after CUE is invoked  |
| `flags`    | No       | Additional flags to pass to CUE               |
| `cue`      | No       | The `cue` package to use                      |
| `jq`       | No       | The `jq` package to use                       |

The CUE engine builds off the concepts above. It takes a single required
argument (`files`) which is the list of files to pass to CUE. In addition to
these files, the engine will also convert the incoming configuration data into
JSON and pass it as a file to CUE. The result is that CUE will evaluate the
given `files` as well as the incoming configuration data. As noted earlier, CUE
will merge all of these together into one final output.

In addition to the `files` argument, pre and post-hooks can be provided that
execute before and after CUE is invoked respectively. Finally, additional flags
can be specified to further control the execution of the CUE CLI tool.

[1]: https://cuelang.org/
[2]: https://cuetorials.com/overview/cli-commands/
[3]: https://cuelang.org/docs/concepts/logic/
[4]: https://cuetorials.com/
[5]: https://cuelang.org/docs/tutorials/tour/intro/constraints/
[6]: https://cuetorials.com/overview/standard-library/
[7]: https://cuetorials.com/overview/expressions/#interpolation

package default

#Config: {
    [string]: #Hook
    colors?: bool | *true
    extends?: [...string]
    skip_output?: [...string]
    source_dir?: string
    source_dir_local?: string
    ...
}

#Hook: {
    commands?: [string]: #Command
    exclude_tags?: [...string]
    parallel?: bool | *false
    piped?: bool | *false
    scripts?: [string]: #Script
    ...
}

#Command: {
    exclude?: string
    files?: string
    glob?: string
    root?: string
    run: string
    skip?: bool | [...string]
    tags?: string
    ...
}

#Script: {
    runner: string
    ...
}

{
    #Config
}
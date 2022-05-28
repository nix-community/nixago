// Generated from http://json.schemastore.org/prettierrc

#Config: {
	// Schema for .prettierrc
	@jsonschema(schema="http://json-schema.org/draft-04/schema#")
	#optionsDefinition & #overridesDefinition | string

	#optionsDefinition: {
		// Include parentheses around a sole arrow function parameter.
		arrowParens?: "always" | "avoid" | *"always"

		// Put > of opening tags on the last line instead of on a new
		// line.
		bracketSameLine?: bool | *false

		// Print spaces between brackets.
		bracketSpacing?: bool | *true

		// Print (to stderr) where a cursor at the given position would
		// move to after formatting.
		// This option cannot be used with --range-start and --range-end.
		cursorOffset?: int | *-1

		// Control how Prettier formats quoted code embedded in the file.
		embeddedLanguageFormatting?: "auto" | "off" | *"auto"

		// Which end of line characters to apply.
		endOfLine?: "lf" | "crlf" | "cr" | "auto" | *"lf"

		// Specify the input filepath. This will be used to do parser
		// inference.
		filepath?: string

		// How to handle whitespaces in HTML.
		htmlWhitespaceSensitivity?: "css" | "strict" | "ignore" | *"css"

		// Insert @format pragma into file's first docblock comment.
		insertPragma?: bool | *false

		// Use single quotes in JSX.
		jsxSingleQuote?: bool | *false

		// Which parser to use.
		parser?: ("flow" | "babel" | "babel-flow" | "babel-ts" | "typescript" | "acorn" | "espree" | "meriyah" | "css" | "less" | "scss" | "json" | "json5" | "json-stringify" | "graphql" | "markdown" | "mdx" | "vue" | "yaml" | "glimmer" | "html" | "angular" | "lwc" | string) & string

		// Custom directory that contains prettier plugins in node_modules
		// subdirectory.
		// Overrides default behavior when plugins are searched relatively
		// to the location of Prettier.
		// Multiple values are accepted.
		pluginSearchDirs?: [...string] | false | *[]

		// Add a plugin. Multiple plugins can be passed as separate
		// `--plugin`s.
		plugins?: [...string]

		// The line length where Prettier will try wrap.
		printWidth?: int | *80

		// How to wrap prose.
		proseWrap?: "always" | "never" | "preserve" | *"preserve"

		// Change when properties in objects are quoted.
		quoteProps?: "as-needed" | "consistent" | "preserve" | *"as-needed"

		// Format code ending at a given character offset (exclusive).
		// The range will extend forwards to the end of the selected
		// statement.
		// This option cannot be used with --cursor-offset.
		rangeEnd?: int | *null

		// Format code starting at a given character offset.
		// The range will extend backwards to the start of the first line
		// containing the selected statement.
		// This option cannot be used with --cursor-offset.
		rangeStart?: int | *0

		// Require either '@prettier' or '@format' to be present in the
		// file's first docblock comment
		// in order for it to be formatted.
		requirePragma?: bool | *false

		// Print semicolons.
		semi?: bool | *true

		// Enforce single attribute per line in HTML, Vue and JSX.
		singleAttributePerLine?: bool | *false

		// Use single quotes instead of double quotes.
		singleQuote?: bool | *false

		// Number of spaces per indentation level.
		tabWidth?: int | *2

		// Print trailing commas wherever possible when multi-line.
		trailingComma?: "es5" | "none" | "all" | *"es5"

		// Indent with tabs instead of spaces.
		useTabs?: bool | *false

		// Indent script and style tags in Vue files.
		vueIndentScriptAndStyle?: bool | *false
		...
	}

	#overridesDefinition: {
		// Provide a list of patterns to override prettier configuration.
		overrides?: [...{
			// Include these files in this override.
			files: string | [...string]

			// Exclude these files from this override.
			excludeFiles?: string | [...string]

			// The options to apply for this override.
			options?: #optionsDefinition
		}]
		...
	}
}

{
    #Config
}
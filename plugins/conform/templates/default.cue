#CommitSpec: {
    header: {
        body?: {
            required?: bool
        }
        case?: string
        conventional?: {
            descriptionLength?: int
            scopes?: [...string]
            types?: [...string]
        }
        dco?: bool
        gpg?: {
            identity?: {
                gitHubOrganization?: string
            }
            required?: bool
        }
        imperative?: bool
        invalidLastCharacters?: string
        jira?: [string]: [...string]
        length?: int
        maximumOfOneCommit?: bool
        spellcheck?: {
            locale?: string
        }
    }
    ...
}

#LicenseSpec: {
    allowPrecedingComments?: bool
    excludeSuffixes?: [...string]
    header?: string
    includeSuffixes?: [...string]
    skipPaths?: [...string]
    ...
}

#CommitPolicy: {
    type: "commit"
    spec: #CommitSpec
}

#LicensePolicy: {
    type: "license"
    spec: #LicenseSpec
}

#Config: {
    policies: [...#CommitPolicy | #LicensePolicy]
}

{
    #Config
}
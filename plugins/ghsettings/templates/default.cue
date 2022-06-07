package default

#Config: {
    repository?: #Repository
    labels?: [...#Label]
    milestones?: [...#Milestone]
    collaborators?: [...#Collaborator]
    teams?: [...#Team]
    branches?: [...#Branch]
    ...
}

#Repository: {
    name?: string
    description?: string
    homepage?: string
    topics?: string
    private?: bool
    has_issues?: bool
    has_projects?: bool
    has_wiki?: bool
    has_downloads?: bool
    default_branch?: string
    allow_squash_merge?: bool
    allow_merge_commit?: bool
    allow_rebase_merge?: bool
    delete_branch_on_merge?: bool
    enable_automated_security_fixes?: bool
    enable_vulnerability_alerts?: bool
    ...
}

#Label: {
    name?: string
    color?: string
    description?: string
    ...
}

#Milestone: {
    title?: string
    description?: string
    state?: string
    ...
}

#Collaborator: {
    username?: string
    permission?: string
    ...
}

#Team: {
    name?: string
    permission?: string
    ...
}

#Branch: {
    name?: string
    protection?: #Protection
    ...
}

#Protection: {
    required_pull_request_reviews?: {
        required_approving_review_count?: int
        dismiss_stale_reviews?: bool
        require_code_owner_reviews?: bool
        dismissal_restrictions?: {
            users?: [...string]
            teams?: [...string]
        }
    }
    required_status_checks?: {
        strict?: bool
        contexts?: [...string]
    }
    enforce_admins?: bool
    required_linear_history?: bool
    restrictions?: {
        apps?: [...string]
        users?: [...string]
        teams?: [...string]
    }
    ...
}
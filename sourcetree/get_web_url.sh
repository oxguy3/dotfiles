#!/usr/bin/env bash
# get_web_url.sh
# Determines the remote web URL for a git commit/file/repository.
# Usage: ./get_web_url.sh <commit|file|repo> [file path or commit hash]

# need to hardcode because SourceTree provides a bad $PATH
GIT="/usr/local/bin/git"

# print message to stderr
# if first argument is "--with-usage", usage info will also be printed
function print_error() {
    if [[ "$1" == "--with-usage" ]]
    then
        >&2 echo ${@:2}
        >&2 echo "Usage: ./get_web_url.sh <commit|file|repo> [file path or commit hash]"
    else
        >&2 echo $@
    fi
}

# check if the http headers for a particular URL contains a particular line
function check_http_header() {
    url="$1"
    header="$2"

    curl -s -L -D - "https://$url" -o /dev/null | grep -q "$header"
    if $?; then
        echo "https://$url"
        exit 0
    fi

    curl -s -L -D - "http://$url" -o /dev/null | grep -q "$header"
    if $?; then
        echo "http://$url"
        exit 0
    fi

    exit 1
}

# check if the http body for a particular URL contains a particular line
function check_http_body() {
    url="$1"
    line="$2"

    curl -s -L "https://$url" | grep "$line"
    if $?; then
        web_url="https://$url"
        exit 0
    fi

    curl -s -L "http://$url" | grep "$line"
    if $?; then
        web_url="http://$url"
        exit 0
    fi

    exit 1
}

# parse and validate arguments

if [[ -z "$1" ]]
then
    print_error --with-usage "FAILURE: Not enough parameters."
    exit 1
fi

ACTION="$1"

if [[ "$ACTION" == "commit" ]]
then
    if [[ -z "$2" ]]; then
        print_error --with-usage "FAILURE: Missing commit hash."
        exit 1
    fi
    SHA="$2"
elif [[ "$ACTION" == "file" ]]
then
    if [[ -z "$2" ]]; then
        print_error --with-usage "FAILURE: Missing file path."
        exit 1
    fi
    FILE="$2"
elif [[ "$ACTION" != "repo" ]]
then
    if [[ -n "$2" ]]; then
        print_error --with-usage "FAILURE: Too many parameters."
        exit 1
    fi
else
    print_error --with-usage "FAILURE: Unknown action '$ACTION'. Valid actions: commit, file, repo."
    exit 1
fi

if [[ -n "$3" ]]; then
    print_error --with-usage "FAILURE: Too many parameters."
    exit 1
fi

current_branch=`$GIT branch --no-color | grep \* | cut -d ' ' -f2`
current_hash=`$GIT rev-parse HEAD`

# iterate over list of remotes
IFS='
'
for remote in `$GIT remote get-url --all origin`
do
    # break the remote URL into parts git@bitbucket.org:hirewheel/hadrian.git
    if [[ "$remote" =~ ^[A-Za-z0-9_\.-]+@([A-Za-z0-9\.-]+):([A-Za-z0-9_\./-]+)\.git$ ]] # match ssh url
    then
        remote_type="ssh"
        remote_domain="${BASH_REMATCH[1]}"
        remote_repo="${BASH_REMATCH[2]}"
    elif [[ "$remote" =~ ^(https?|git)://([A-Za-z0-9\.-]+)/([A-Za-z0-9_\./-]+)\.git$ ]] # match https/git url
    then
        remote_type="${BASH_REMATCH[1]}"
        remote_domain="${BASH_REMATCH[2]}"
        remote_repo="${BASH_REMATCH[3]}"
    else
        print_error "WARNING: Unknown URL format: $remote"
        continue
    fi

    # check if the domain is that of a known git hosting provider
    if [[ "$remote_domain" == "github.com" ]]
    then
        print_error "NOTE: Identified GitHub repository."
        web_repo="https://github.com/$remote_repo"
        web_file="https://github.com/$remote_repo/blob/$current_branch/$FILE"
        web_commit="https://github.com/$remote_repo/commit/$SHA"
        break
    elif [[ "$remote_domain" == "bitbucket.org" ]]
    then
        print_error "NOTE: Identified Bitbucket repository."
        web_repo="https://bitbucket.org/$remote_repo"
        web_file="https://bitbucket.org/$remote_repo/src/$current_branch/$FILE"
        web_commit="https://bitbucket.org/$remote_repo/commits/$SHA"
        break
    elif [[ "$remote_domain" == "gitlab.com" ]]
    then
        print_error "NOTE: Identified GitLab.com repository."
        web_repo="https://gitlab.com/$remote_repo"
        web_file="https://gitlab.com/$remote_repo/blob/$current_branch/$FILE"
        web_commit="https://gitlab.com/$remote_repo/commit/$SHA"
        break
    elif [[ "$remote_domain" =~ ^git-codecommit.([a-z0-9-]+).amazonaws.com$ ]]
    then
        print_error "NOTE: Identified AWS CodeCommit repository."
        # parse out the AWS region and real name of the repo
        aws_region="${BASH_REMATCH[1]}"
        if [[ "$remote_repo" =~ ^v1/repos/(.*)$ ]]
        then
            aws_repo_name="${BASH_REMATCH[1]}"
        else
            print_error "WARNING: Could not parse AWS CodeCommit URL '$remote_repo'"
            continue
        fi

        web_repo="https://console.aws.amazon.com/codecommit/home?region=$aws_region#/repository/$aws_repo_name"
        web_file="https://console.aws.amazon.com/codecommit/home?region=$aws_region#/repository/$aws_repo_name/browse/$current_branch/--/$FILE"
        # TODO: figure out the URL format for commit URLs

        break
    else # not a known domain of a provider, so let's try to identify by probing the server

        # check for GitLab
        gitlab_check=`check_http_header "$remote_domain" "^Set-Cookie: _gitlab_session="`
        if $?; then
            print_error "NOTE: Identified self-hosted GitLab repository."
            web_repo="$gitlab_check/$remote_repo"
            web_file="$gitlab_check/$remote_repo/blob/$current_branch/$FILE"
            web_commit="$gitlab_check/$remote_repo/commit/$SHA"
            break
        fi

        # check for Gogs
        gogs_check=`check_http_header "$remote_domain" "^Set-Cookie: i_like_gogits="`
        if $?; then
            print_error "NOTE: Identified Gogs repository."
            web_repo="$gogs_check/$remote_repo"
            web_file="$gogs_check/$remote_repo/src/$current_branch/$FILE"
            web_commit="$gogs_check/$remote_repo/commit/$SHA"
            break
        fi

        # check for cgit
        cgit_check=`check_http_header "$remote_domain" "^<meta name='generator' content='cgit v[0-9\.]*'/>$"`
        if $?; then
            print_error "NOTE: Identified cgit repository."
            web_repo="$cgit_check/$remote_repo.git"
            web_file="$cgit_check/$remote_repo.git/tree/$FILE?h=$current_branch"
            web_commit="$cgit_check/$remote_repo.git/commit/?id=$SHA"
            break
        fi

        # check for gitweb
        gitweb_check=`check_http_header "$remote_domain" "^<meta name=\"generator\" content=\"gitweb/"`
        if $?; then
            print_error "NOTE: Identified gitweb repository."
            web_repo="$gitweb_check/$remote_repo.git"
            web_file="$gitweb_check/$remote_repo.git/blob/$current_hash:/$FILE"
            web_commit="$gitweb_check/$remote_repo.git/commit/$SHA"
            break
        fi

        print_error "WARNING: Unknown git host '$remote_domain'"
        continue
    fi
done

if [[ "$ACTION" == "commit" ]]
then
    if [[ -n "$web_commit" ]]
    then
        echo "$web_commit"
    else
        print_error "FAILURE: Unable to generate commit URL for this repository."
        exit 1
    fi
elif [[ "$ACTION" == "file" ]]
then
    if [[ -n "$web_file" ]]
    then
        echo "$web_file"
    else
        print_error "FAILURE: Unable to generate file URL for this repository."
        exit 1
    fi
elif [[ "$ACTION" == "repo" ]]
then
    if [[ -n "$web_repo" ]]
    then
        echo "$web_repo"
    else
        print_error "FAILURE: Unable to generate repo URL for this repository."
        exit 1
    fi
fi

# SourceTree custom actions
Scripts is this folder are designed to be used with SourceTree as custom
actions. You can learn more about SourceTree custom actions [here](https://blog.sourcetreeapp.com/2012/02/08/custom-actions-more-power-to-you/).

## Web URL scripts
The `copy_web_url.sh` and `open_web_url.sh` scripts can be used to find the web
URL of a particular file/commit/repository, then copy it to your clipboard or
open it in your web browser (respectively). This means you can view that item
on github.com, bitbucket.org, etc.

Both of these scripts utilize the `get_web_url.sh` script. Usage and more info
can be found in the comments of that script.

### Supported services

Currently, the following public Git hosting services are supported by this:

* GitHub.com
* Bitbucket.org
* GitLab.com
* AWS CodeCommit

Additionally, the following self-hosted Git web interfaces are supported
(assuming non-abnormal configuration):

* GitLab
* Gogs.io
* cgit
* gitweb

### Installation

This script requires:

* bash, version 3.x or newer
* git, version 2.7 or newer
* curl (used for identifying self-hosted services)

These scripts provide six total custom actions. Use these settings to add each
of them to your SourceTree installation:

| Menu Caption           | Script target            | Parameters  |
| ---------------------- | ------------------------ | ----------- |
| Open Repo in Browser   | /path/to/open_web_url.sh | repo        |
| Copy Repo URL          | /path/to/copy_web_url.sh | repo        |
| Open File in Browser   | /path/to/open_web_url.sh | file $FILE  |
| Copy File URL          | /path/to/copy_web_url.sh | file $FILE  |
| Open Commit in Browser | /path/to/open_web_url.sh | commit $SHA |
| Copy Commit URL        | /path/to/copy_web_url.sh | commit $SHA |

**Warning:** `get_web_url.sh` has the location of the `git` executable hardcoded
at `/usr/local/bin/git`. If your `git` is somewhere else, edit the value of the
`GIT` variable near the top of `get_web_url.sh`.

### Notes

* You may store these scripts wherever you like, so long as you put
  `get_web_url.sh` in the same directory.
* If your repository has multiple remote URLs, this script iterate through the
  list of URLs in order until it finds one it can identify.

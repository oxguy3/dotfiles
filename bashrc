# Hayden's hella classy .bashrc config
#
# borrows from...
# * https://github.com/mathiasbynens/dotfiles
# * https://github.com/holman/dotfiles
# ...and probably other places I forgot to attribute (sorry!)


# figure out what OS we're running we're dealing with
# kudos: http://stackoverflow.com/a/17072017/992504
ostype="unknown"
if [ "$(uname)" == "Darwin" ]; then
    ostype="macosx"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    ostype="linux"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    ostype="windows"
fi

# clean prompt
PS1="[\u@\h \W]\$ "


############################################################################
# FILES AND DIRECTORIES
############################################################################

# quick navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias ~="cd ~"
alias dc="cd ~/Documents"
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"

# Create a new directory and enter it
function mkd() {
	mkdir -p "$@" && cd "$_";
}

# Create a data URL from a file
function dataurl() {
	local mimeType=$(file -b --mime-type "$1");
	if [[ $mimeType == text/* ]]; then
		mimeType="${mimeType};charset=utf-8";
	fi
	echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')";
}

# print $PATH in human-readable format
alias showpath="echo $PATH | tr ':' '\n'"

# murder .DS_Store files
alias fuckdsstore="find . -type f -name '*.DS_Store' -ls -delete"


############################################################################
# HTTP AND NETWORKING
############################################################################

# One of @janmoesen’s ProTip™s
for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
	alias "$method"="lwp-request -m '$method'"
done

# URL-encode strings
alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'

# Start an HTTP server from a directory, optionally specifying the port
function server() {
	local port="${1:-8000}";
	sleep 1 && open "http://localhost:${port}/" &
	# Set the default Content-Type to `text/plain` instead of `application/octet-stream`
	# And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
	python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port";
}

# print IP addresses
alias ip='dig +short myip.opendns.com @resolver1.opendns.com'
alias localip="ipconfig getifaddr en0"



############################################################################
# TEXT AND STRINGS
############################################################################

# Trim new lines and copy to clipboard
alias c="tr -d '\n' | pbcopy"

# convert all whitespace characters to spaces and remove duplicate spaces
alias cleanspace="tr -s '[:space:]' ' '"

# list all the words in the input file
alias listwords='tr -cs "[:alnum:]" "\n"'

# convert letter case
alias whisper='tr "[:upper:]" "[:lower:]"'
alias shout='tr "[:lower:]" "[:upper:]"'

# clean formatted timestamps attached to running program
alias tss="ts '[%Y-%m-%d %H:%M:%S]'"

# generate a password that is random enough for simple uses
if [ "$ostype" != "macosx" ]; then
    alias genpasswd="date +%s-%N | sha256sum | base64 | head -c 32 ; echo"
else
    alias genpasswd="date +%s-%N | shasum | base64 | head -c 32 ; echo"
fi

# Syntax-highlight JSON strings or files
# Usage: `json '{"foo":42}'` or `echo '{"foo":42}' | json`
function pjson() {
	if [ -t 0 ]; then # argument
		python -mjson.tool <<< "$*" | pygmentize -l javascript;
	else # pipe
		python -mjson.tool | pygmentize -l javascript;
	fi;
}


############################################################################
# HACKS AND OTHER GARBAGE
############################################################################

# fix gnome .desktop files
alias fixchrome="sudo sed '/\[Desktop Entry\]/a StartupWMClass=Google-chrome-stable' /usr/share/applications/google-chrome.desktop"
alias fixmysqlworkbench="sudo sed '/\[Desktop Entry\]/a StartupWMClass=Mysql-workbench-bin' /usr/share/applications/mysql-workbench.desktop"


############################################################################
# MISCELLANEOUS CRAP
############################################################################

# git stuff
alias git-undo="git reset --soft HEAD^"

# volume controls
alias stfu="osascript -e 'set volume output muted true'"
alias pumpitup="osascript -e 'set volume 7'"

# Lock the screen (when going AFK)
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"

# Reload the shell (i.e. invoke as a login shell)
alias reload="exec $SHELL -l"

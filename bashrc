# Hayden's hella classy .bashrc config
#
# borrows from...
# * https://github.com/mathiasbynens/dotfiles
# * https://github.com/holman/dotfiles
# ...and probably other places I forgot to attribute (sorry!)

# CHANGE THIS TO WHEREVER YOU HAVE THIS REPO SYNCED
scriptsdir="~/dotfiles"


# figure out what OS we're running
# h/t: http://stackoverflow.com/a/17072017/992504
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

# override OS X's BSD utilities with superior GNU utils
if [ "$ostype" == "macosx" ]; then
    export PATH="$(brew --prefix coreutils)/libexec/gnubin:/usr/local/bin:$PATH"
    export MANPATH="$(brew --prefix)/opt/coreutils/libexec/gnuman:$MANPATH"
fi

############################################################################
# SYMFONY2
############################################################################

alias symf="php app/console -vv"
alias symfassets="symf cache:clear; symf assets:install --symlink; symf assetic:dump"
alias symfsrv="symf server:run"
alias symfschema="symf doctrine:schema:update --force"

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
alias dpic="cd ~/Pictures"

# Create a new directory and enter it
function mkd() {
    mkdir -p "$@" && cd "$_";
}

# Create a data URL from a file
# TODO: tweak this to accept from stdin if possible
function dataurl() {
    local mimeType=$(file -b --mime-type "$1");
    if [[ $mimeType == text/* ]]; then
        mimeType="${mimeType};charset=utf-8";
    fi
    echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')";
}

# print $PATH and man-page directories in human-readable format
alias showpath="echo $PATH | tr ':' '\n'"
alias showman="man --path | tr ':' '\n'"

# murder .DS_Store files
alias fuckdsstore="find . -type f -name '*.DS_Store' -ls -delete"

# make a backup of a file
function bak() {
    cp $@{,.bak}
}

# aliases for ls with nice flags enabled
alias lss="ls -ah"
alias lsl="ls -ahl"

# open things in various apps quickly
if [ "$ostype" == "macosx" ]; then
    alias chrome="open -a '/Applications/Google Chrome.app'"
    alias firefox="open -a '/Applications/Firefox.app'"
    alias textedit="open -a '/Applications/TextEdit.app'"
fi

############################################################################
# HTTP AND NETWORKING
############################################################################

# One of @janmoesen’s ProTip™s
# shortcuts for making HTTP requests
for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
    alias "$method"="lwp-request -m '$method'"
done

# Start an HTTP server from a directory, optionally specifying the port
function server() {
    local port="${1:-8000}";
    sleep 1 && open "http://localhost:${port}/" &
    # Set the default Content-Type to `text/plain` instead of `application/octet-stream`
    # And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
    python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port";
}

# print IP address
alias ip='dig +short myip.opendns.com @resolver1.opendns.com'
alias localip="ipconfig getifaddr en0"

# watch for a website to come back online
# example: github down? do `mashf5 github.com`
function mashf5() {
    watch -d -n 5 "curl --head --silent --location $1 | grep '^HTTP/'"
}

# reverse DNS lookup via dig (only supports IPv4 cuz I'm lazy)
function reversedns() {
    octets=""
    addr="in-addr.arpa"
    IFS="." read -r -a octets <<< "$1"
    for octet in "${octets[@]}"; do
         addr=$octet"."$addr
    done
    dig ptr $addr "${@:2}"
}

# shortcut function for terse output
function revdns() {
    reversedns $1 +short "${@:2}"
}

############################################################################
# TEXT AND STRINGS
############################################################################

# four letters is too many
alias e="echo"

# Trim new lines and copy to clipboard
if [ "$ostype" == "macosx" ]; then
    alias c="tr -d '\n' | pbcopy"
elif [ "$ostype" == "linux" ]; then
    alias c="tr -d '\n' | xclip"
elif [ "$ostype" == "windows" ]; then
    alias c="tr -d '\n' | clip"
fi

# TODO add full-width character converter

# highly secure ROT13 encryption algorithm
alias rot13="tr '[A-Za-z]' '[N-ZA-Mn-za-m]'"

# get the Nth line of a file/stdin (pass "N" as first parameter)
function lineno() {
    num=$1
    shift
    sed $num"q;d" $@
}

# convert all whitespace characters to spaces and remove duplicate spaces
alias cleanspace="tr -s '[:space:]' ' '"

# remove diacritic marks
alias noaccents="iconv -f utf8 -t ascii//TRANSLIT//IGNORE"

# list all the words in the input file
alias listwords='tr -cs "[:word:]" "\n"'

# convert letter case
alias lower='tr "[:upper:]" "[:lower:]"'
alias upper='tr "[:lower:]" "[:upper:]"'

# clean formatted timestamps attached to running program
alias tss="ts '[%Y-%m-%d %H:%M:%S]'"

# echo to stderr
alias errcho='>&2 echo'

# generate a password that is random enough for simple uses
# TODO: make character length specifiable via parameter
# TODO: figure out some way to allow user-generated entropy
if command -v sha256sum >/dev/null; then
    alias genpasswd="date +%s-%N | sha256sum | base64 | head -c 32 ; echo"
elif command -v shasum >/dev/null; then
    alias genpasswd="date +%s-%N | shasum -a 256 | base64 | head -c 32 ; echo"
else
    alias genpasswd="echo 'FAIL: No SHA-256 executable found.'"
fi

############################################################################
# SOUND AND AUDIO
############################################################################

# list available sound effects
alias sfx="ls -1 $scriptsdir/sounds | grep .mp3 | sed s/\.mp3/\ / | tr -d '\n'; echo"

# play dumb sound effects
for f in `sfx`; do
    alias "$f"="playmp3 $scriptsdir/sounds/$f.mp3"
done

# play the bell sound (yeah I know `tput bel` exists, but POSIX compliance man!)
alias ding='printf "\a"'

# volume controls
if command -v osascript >/dev/null; then
    alias stfu="osascript -e 'set volume output muted true'"
    alias pumpitup="osascript -e 'set volume 7'"
elif command -v amixer >/dev/null; then
    alias stfu="amixer set Master mute"
    alias pumpitup="amixer set Master 100 unmute"
else
    alias stfu="echo 'FAIL: Volume controls require amixer from the alsa-libs package.'"
    alias pumpitup="echo 'FAIL: Volume controls require amixer from the alsa-libs package.'"
fi

# for utter silliness
alias archey!="archey; tada"


############################################################################
# MISCELLANEOUS CRAP
############################################################################

# fix gnome .desktop files (resolves the issue where you have two dock icons for the same app)
if [ "$ostype" == "linux" ]; then
    alias fixchrome="sudo sed '/\[Desktop Entry\]/a StartupWMClass=Google-chrome-stable' /usr/share/applications/google-chrome.desktop"
    alias fixmysqlworkbench="sudo sed '/\[Desktop Entry\]/a StartupWMClass=Mysql-workbench-bin' /usr/share/applications/mysql-workbench.desktop"
fi

# git stuff
alias git-undo="git reset --soft HEAD^"

# Reload the shell (i.e. invoke as a login shell)
alias reload="exec $SHELL -l"

# Lock the screen (when going AFK)
if [ "$ostype" == "macosx" ]; then
    alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
fi

# because "youtube-dl" is the worst executable name ever
alias ytdl="youtube-dl"

# command-line weather
alias weather="curl -4 http://wttr.in"

# easily share a file via https://github.com/dutchcoders/transfer.sh
# usage: transfer <filename>
transfer() {
    # write to output to tmpfile because of progress bar
    tmpfile=$( mktemp -t transferXXX )
    curl --progress-bar --upload-file $1 https://transfer.sh/$(basename $1) >> $tmpfile;
    cat $tmpfile;
    rm -f $tmpfile;
}
alias transfer=transfer

# typing is really hard, okay?
alias dumbtypo="echo 'LEARN TO TYPE, MORON'"
alias sl="dumbtypo; ls"
alias rbuy="dumbtypo; ruby"
alias pytohn="dumbtypo; python"
alias brwe="dumbtypo; brew"
alias arhcey="dumbtypo; archey"
alias arhcey!="dumbtypo; archey!"

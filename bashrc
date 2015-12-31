# Hayden's hella classy .bashrc config
#
# borrows from...
# * https://github.com/mathiasbynens/dotfiles
# * https://github.com/holman/dotfiles
# ...and probably other places I forgot to attribute (sorry!)

# CHANGE THIS TO WHEREVER YOU HAVE THIS REPO SYNCED
scriptsdir="~/scripts"


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



############################################################################
# TEXT AND STRINGS
############################################################################

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

############################################################################
# MISCELLANEOUS CRAP
############################################################################

# fix gnome .desktop files (resolves the issue where you have two dock icons for the same app)
alias fixchrome="sudo sed '/\[Desktop Entry\]/a StartupWMClass=Google-chrome-stable' /usr/share/applications/google-chrome.desktop"
alias fixmysqlworkbench="sudo sed '/\[Desktop Entry\]/a StartupWMClass=Mysql-workbench-bin' /usr/share/applications/mysql-workbench.desktop"

# # universal package manager basic commands experiment
# if command -v "brew" >/dev/null; then
#     alias "pm"="brew"
#     alias "pmin"="brew install"
#     alias "pmun"="brew uninstall"
#     alias "pmre"="brew reinstall"
#     alias "pmup"="brew update"
#     alias "pmls"="brew list"
#     alias "pmfind"=
# elif command -v "dnf" >/dev/null; then
#     alias "pm"="dnf"
#     alias "pmin"="dnf install"
#     alias "pmun"="brew uninstall"
#     alias "pmre"="brew reinstall"
#     alias "pmup"="brew update"
#     alias "pmls"="brew update"
# fi
#
# pman=""
#
# for p in brew apt-get yum dnf pacman; do
#     if command -v $p >/dev/null; then
#         pman="$p"
#         break
#     fi
# done
#
# if [ -z "$pman" ]; then
#     alias "pm"="$pm"
#     alias "pmwhat"="echo 'You are using $pm!'"
#     if [ "$pman" == "pacman" ]; then
#         alias "pmin"="$pm --sync"
#         alias "pmun"="$pm --remove"
#         #alias "pmre"="$pm reinstall"
#         alias "pmrf"="$pm --sync --refresh"
#         alias "pmup"="$pm --upgrade"
#         alias "pmuu"="$pm --sysupgrade --"
#         alias "pmls"="$pm --query"
#         alias "pmsearch"="$pm search"
#     else
#         alias "pmin"="$pm install"
#         alias "pmun"="$pm uninstall"
#         alias "pmls"="$pm list"
#         alias "pmsearch"="$pm search"
#         if [ "$pman" != "apt-get" ]; then
#
#             alias "pmre"="$pm reinstall"
#         if [ "$pman" == "yum" ] || [ "$pman" == "dnf" ]; then
#             alias "pmup"="$pm update"
#             alias "pmuu"="$pm update"
#         else
#             alias "pmup"="$pm upgrade"
#             alias "pmuu"="$pm update; $pm upgrade"
#     fi
# fi


# git stuff
alias git-undo="git reset --soft HEAD^"

# Reload the shell (i.e. invoke as a login shell)
alias reload="exec $SHELL -l"

# Lock the screen (when going AFK)
if [ "$ostype" == "macosx" ]; then
    alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
fi

# typing is really hard, okay?
alias dumbtypo="echo 'LEARN TO TYPE, MORON'"
alias sl="dumbtypo; ls"
alias rbuy="dumbtypo; ruby"
alias pytohn="dumbtypo; python"
alias brwe="dumbtypo; brew"

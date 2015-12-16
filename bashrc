# Hayden's hella classy .bashrc config

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

# clean formatted timestamps attached to running program
alias tsclean="ts '[%Y-%m-%d %H:%M:%S]'"

# generate a password that is random enough for simple uses
if [ "$ostype" != "macosx" ]; then
    alias genpasswd="date +%s-%N | sha256sum | base64 | head -c 32 ; echo"
else
    alias genpasswd="date +%s-%N | shasum | base64 | head -c 32 ; echo"
fi

# print $PATH in human-readable format
alias showpath="echo $PATH | tr ':' '\n'"

# print public IP address
alias myip='echo -n "Public IP address: "; dig +short myip.opendns.com @resolver1.opendns.com'

# fix gnome .desktop files
alias fixchrome="sudo sed '/\[Desktop Entry\]/a StartupWMClass=Google-chrome-stable' /usr/share/applications/google-chrome.desktop"
alias fixmysqlworkbench="sudo sed '/\[Desktop Entry\]/a StartupWMClass=Mysql-workbench-bin' /usr/share/applications/mysql-workbench.desktop"

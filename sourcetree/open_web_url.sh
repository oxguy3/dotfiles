#!/usr/bin/env bash
# open_web_url.sh
# Wrapper for get_web_url.sh that automatically opens in browser

# run get_web_url.sh, which is in the same directory as this script
web_url=`$( dirname $0 )/get_web_url.sh $@`
code=$?

# if get_web_url.sh failed, we fail as well
if [[ $code -ne '0' ]]; then
    exit $code
fi

echo "URL generated: $web_url"

# every OS has a different "open in browser" command, so we have to try them all
if [[ -x "$BROWSER" ]]; then # $BROWSER env var takes precedence over all else
    $BROWSER "$web_url"
elif command -v open >/dev/null; then # macOS
    open "$web_url"
elif command -v start >/dev/null; then # Windows
    start "$web_url"
elif command -v xdg-open >/dev/null; then # most other systems
    xdg-open "$web_url"
elif command -v gvfs-open >/dev/null; then # GNOME (newer)
    gvfs-open "$web_url"
elif command -v gnome-open >/dev/null; then # GNOME (older)
    gnome-open "$web_url"
elif command -v kde-open >/dev/null; then # KDE
    kde-open "$web_url"
elif command -v x-www-browser >/dev/null; then # X11
    x-www-browser "$web_url"
elif command -v cmd >/dev/null; then # maybe it's a weird Windows setup?
    cmd /C "start $web_url"
elif [[ -x "/mnt/c/System32/cmd.exe" ]]; then # cmd on Bash for Windows
    /mnt/c/System32/cmd.exe /C "start $web_url"
elif [[ -x "/cygdrive/c/System32/cmd.exe" ]]; then # cmd on Cygwin
    /cygdrive/c/System32/cmd.exe /C "start $web_url"
elif [[ -x "/c/System32/cmd.exe" ]]; then # cmd on MSYS
    /c/System32/cmd.exe /C "start $web_url"
elif command -v python >/dev/null; then # Python module
    python -m webbrowser -t "$web_url"
elif command -v w3m >/dev/null; then # now trying command-line web browsers...
    w3m "$web_url"
elif command -v links2 >/dev/null; then
    links2 "$web_url"
elif command -v elinks >/dev/null; then
    elinks "$web_url"
elif command -v lynx >/dev/null; then
    lynx "$web_url"
else # alright, we can't keep doing this forever
    >&2 echo "FAILURE: Could not open in a web browser. What OS are you running???"
    exit 1
fi

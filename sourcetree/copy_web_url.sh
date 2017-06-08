#!/usr/bin/env bash
# copy_web_url.sh
# Wrapper for get_web_url.sh that automatically copies to clipboard

echo $@

# run get_web_url.sh, which is in the same directory as this script
web_url=`$( dirname $0 )/get_web_url.sh $@`
code=$?

# if get_web_url.sh failed, we fail as well
if [[ $code -ne '0' ]]; then
    exit $code
fi

echo "URL generated: $web_url"

# every OS has a different clipboard-copy command, so we have to try them all
if command -v pbcopy >/dev/null; then # macOS
    echo -n "$web_url" | pbcopy
elif command -v copy >/dev/null; then # Windows
    echo -n "$web_url" | copy
elif command -v xclip >/dev/null; then # Linux, etc (any system using X11)
    echo -n "$web_url" | xclip
else
    >&2 echo "FAILURE: Could not copy to clipboard. This probably means you need to install xclip."
    exit 1
fi

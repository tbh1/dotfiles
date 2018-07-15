if uname -a | grep 'Linux' >/dev/null
    abbr pbcopy "xclip -selection c"
    abbr pbpaste "xclip -selection c -o"
end


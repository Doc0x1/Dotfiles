#!/bin/zsh

# .zshenv is sourced on ALL invocations of the shell, unless the -f option is
# set.  It should NOT normally contain commands to set the command search path,
# or other common environment variables unless you really know what you're
# doing.  E.g. running "PATH=/custom/path gdb program" sources this file (when
# gdb runs the program via $SHELL), so you want to be sure not to override a
# custom environment in such cases.  Note also that .zshenv should not contain
# commands that produce output or assume the shell is attached to a tty.

# List of directories for PATH: defaults first, then conditional directories
directories=(
    # Default directories (always included)
    "/usr/bin"
    "/usr/local/bin"
    "/usr/local/games"
    "/usr/games"
    "/usr/share/games"
    "/usr/local/sbin"
    "/usr/sbin"
    "/sbin"
    "/bin"
    
    # Custom directories (include these if needed)
    "/snap/bin"
    "/usr/sandbox"
    "~/.config/composer/vendor/bin"
    "/usr/local/go/bin"
    "~/.local/bin"
    "~/go/bin"
    "~/.nimble/bin"
)

# Use an associative array to avoid duplicates
typeset -A unique_dirs
final_path=""

for dir in "${directories[@]}"; do
    # Only add existing directories and prevent duplicates
    if [[ -d "$dir" && -z ${unique_dirs["$dir"]} ]]; then
        unique_dirs["$dir"]=1
        final_path="$final_path:$dir"
    fi
done

# Export the constructed PATH (remove leading colon)
export PATH="${final_path#:}"

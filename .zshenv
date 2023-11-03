#!/bin/zsh

# .zshenv is sourced on ALL invocations of the shell, unless the -f option is
# set.  It should NOT normally contain commands to set the command search path,
# or other common environment variables unless you really know what you're
# doing.  E.g. running "PATH=/custom/path gdb program" sources this file (when
# gdb runs the program via $SHELL), so you want to be sure not to override a
# custom environment in such cases.  Note also that .zshenv should not contain
# commands that produce output or assume the shell is attached to a tty.

export PATH=/snap/bin:/usr/sandbox/:/usr/local/bin:/usr/bin:/usr/local/games:/usr/games:/usr/share/games:/usr/local/sbin:/usr/sbin:/sbin:~/.config/composer/vendor/bin:/usr/local/go/bin:~/.local/bin:~/go/bin:/bin:~/.nimble/bin:$PATH

#!/bin/zsh

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Check if ZDOTDIR is set, otherwise, use the home directory as default
if [ -z "$ZDOTDIR" ]; then
    ZDOTDIR=$HOME
fi

# Use this to override the editor variable
EDITOR_OVERRIDE="true"

# use best command line text editor available
if (( $+commands[nvim] )); then
    EDITOR_NO_DM='nvim';
elif (( $+commands[vim] )); then
    EDITOR_NO_DM='vim';
fi

# use best graphical text editor available
if (( $+commands[kate] )); then
    EDITOR_DM='kate'
elif (( $+commands[gedit] )); then
    EDITOR_DM='gedit'
else
    EDITOR_DM='nano'
fi

# Preferred editor for session (depends on if the session has a display manager running and if EDITOR_OVERRIDE is set)
if [[ -n $DESKTOP_SESSION ]] && [[ -z $EDITOR_OVERRIDE || $EDITOR_OVERRIDE == 'false' ]]; then
    EDITOR=$EDITOR_DM;
elif [[ -n $SSH_CONNECTION ]] || [[ -z $SESSION_MANAGER ]]; then
    EDITOR=$EDITOR_NO_DM;
elif [[ $EDITOR_OVERRIDE == 'true' ]]; then
    EDITOR='nvim'   # Specify override for EDITOR here
else
    EDITOR='nano';  # Fallback EDITOR if all other checks fail
fi

# Default EDITOR assignment behavior. Example: export EDITOR='kate'
export EDITOR

export ZSH=$ZDOTDIR/.oh-my-zsh

# Hyphen-insensitive completion
HYPHEN_INSENSITIVE="true"
# Case-insensitive completion
CASE_SENSITIVE="false"
# Set command history file location and name with below variable.
HISTFILE=$ZDOTDIR/.zsh_history
# You can set one of the optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# see 'man strftime' for details.
HIST_STAMPS="mm/dd/yyyy"
# disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"
# display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="false"
ENABLE_CORRECTION="true"
# change this to false to turn off the help message and neofetch on terminal startup
# STARTUP_CONTENT="true"

# Oh-my-zsh enabled plugins
plugins=(
add-to-omz
colorize
common-aliases
cp extract
gitignore jump
node npm
pip pipenv
python 
sudo vscode
zautoload
zpentest
zsh-autosuggestions
zsh-syntax-highlighting)

# make less more friendly for non-text input files, see lesspipe(1)
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"

export LESSOPEN="|/usr/share/source-highlight/src-hilite-lesspipe.sh %s"
export LESS=R

# P10K is only theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# For completions
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

source $ZSH/oh-my-zsh.sh

clear && printf '\n%.0s' {1..100}

# Terminal startup output (won't run unless $STARTUP_CONTENT is true)
if [[ -o interactive ]] && [[ -n "$STARTUP_CONTENT" ]]; then
    neofetch
fi


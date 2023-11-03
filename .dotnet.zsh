#!/bin/zsh

# For adding dotnet related things to path
if [ -d "$HOME/.dotnet" ]; then
    export PATH="$PATH:$HOME/.dotnet:$HOME/.dotnet/tools"
fi

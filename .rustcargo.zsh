#!/bin/zsh

#$ For rust cargo
if [[ -f "$HOME/.cargo/env" ]]; then
	. "$HOME/.cargo/env"
fi

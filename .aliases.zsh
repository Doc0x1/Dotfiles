#!/bin/zsh
#! Doc0x1's Aliases

# Useful stuff
alias s='sudo'
alias rt='sudo -i'
alias e='echo'
alias m='mark'
alias own='sudo chown -v $USER:$USER'
alias owndir='sudo chown -R $USER:$USER'

# copy, symlinks
alias cpd='cp -r'
alias cpd-ffs='sudo cp -r'
alias sl='ln -srv'
alias sl-ffs='sudo ln -srv'
alias rma='rm -drf'
alias rma-ffs='sudo rm -drf'
alias j='jump'

# list octal file permissions
alias lso="ls -alG | awk '{k=0;for(i=0;i<=8;i++)k+=((substr(\$1,i+2,1)~/[rwx]/)*2^(8-i));if(k)printf(\" %0o \",k);print}'"

if (( $+commands[python] )); then
	alias py-m='python -m'
	alias manage-py='python -m manage.py'
	alias py-pip='python -m pip'
	alias py-pip-i='python -m pip install'
	alias py-httpserver='python -m http.server'
fi

# apt/apt-get
if (( $+commands[apt] && $+commands[apt-get] )); then
	alias a='sudo apt'
	alias ag='sudo apt-get'
	alias ac='sudo apt-cache'
	alias alu='apt list --upgradeable'
	alias ase='apt search'
	alias ash='apt show'
	alias au='sudo apt-get update'
	alias ai='sudo apt install'
	alias ar='sudo apt reinstall'
	alias arm='sudo apt remove'
	alias ap='sudo apt purge'
	alias mark-a='sudo apt-mark auto'
	alias mark-m='sudo apt-mark manual'
	alias afix='sudo apt-get install -f'
	alias aup='sudo apt-get update && sudo apt-get upgrade -y'
	alias apc='sudo apt-get --purge autoremove -y && sudo apt-get autoclean -y'
fi

alias reconf='sudo dpkg-reconfigure'
alias add-arch='sudo dpkg --add-architecture'

# git aliases
if (( $+commands[git] )); then
	alias gst='git status'
	alias ga='git add'
	alias gcm='git commit -m'
	alias gph='git push'
	alias gpl='git pull'
	alias gd='git diff'
	alias gco='git checkout'
	alias gsw='git switch'
	alias gb='git branch'
	alias guncommitsoft='git reset --soft HEAD~1'
	alias guncommithard='git reset --hard HEAD~1'
	alias glgraph='git log --graph'
fi

# docker aliases
if (( $+commands[docker] )); then
	alias d='docker'
	alias dps='docker ps'
	alias docker-ip="docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}'"
fi

# Time, IP and systemd/systemctl aliases etc.
alias sync-time='sudo ntpd ntp.ubuntu.com'
alias extip='curl https://ipecho.net/plain; echo'
alias intip='hostname -I; echo'
alias gettun0='ifconfig | grep -i -A 10 tun0'
alias tunip="ifconfig | grep -i -A 1 tun0 | tail -n 1 | awk ' { print \$2 }'"
alias shutdown='sudo shutdown now'
alias sctl='sudo systemctl'
alias sd='sudo systemd'

# Grep aliases
alias grepa='grep -i -A'
alias grepb='grep -i -B'
alias grepc='grep -i -C'

# Misc
alias printlines="printf '\n%.0s' {1..100}"

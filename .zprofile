#!/bin/zsh

# Only runs if shell is running inside Windows Subsystem for Linux
if [[ -n "${WSL_DISTRO_NAME}" ]]; then
    if [[ -d "/mnt/wsl/${WSL_DISTRO_NAME}" ]]; then
	printf "%s\n" "System mounted at: /mnt/wsl/${WSL_DISTRO_NAME}"
    else
        mkdir "/mnt/wsl/${WSL_DISTRO_NAME}"
        # note the terminating / on the directory name below!
        wsl.exe -d ${WSL_DISTRO_NAME} -u root mount --bind / "/mnt/wsl/${WSL_DISTRO_NAME}/"
    fi
fi

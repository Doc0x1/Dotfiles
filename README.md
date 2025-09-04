# Doc0x1's Zsh Dotfiles

| My Zsh Dotfile Setup |                                                                                                           |
| :------------------: | :-------------------------------------------------------------------------------------------------------: |
|       Project:       |                                          Doc0x1's Zsh Dotfiles*                                           |
|       Author:        |                                                **Doc0x1**                                                 |
|      Used for:       |                                        Easily setting up Zsh Setup                                        |
|    Technologies:     | [OhMyZsh](https://github.com/ohmyzsh/ohmyzsh) + [Powerlevel10k](https://github.com/romkatv/powerlevel10k) |
|       Version:       |                                                 **1.0.0**                                                 |
|       License:       |                                                  **MIT**                                                  |
|                      |                                                                                                           |

You can configure your powerlevel10k prompt using `p10k configure` after running the install script.

## Installation

```bash
git clone https://github.com/Doc0x1/Dotfiles.git
cd Dotfiles
chmod +x install.sh
./install.sh
```

## The install script in particular is designed for Debian based distributions with the apt package manager, and it is not guaranteed to work on other distributions

### If you have any problems, feel free to open up an issue.

---

## I've tested the install.sh installer on Debian, Kali Linux, and Parrot OS.

- **It _SHOULD_ work without issue on most distros.**

- Be sure to **BACK UP YOUR FILES** for your shell's configuration **BEFORE running the script.**

---

## INSTALL REQUIREMENTS: zsh, git, wget (neofetch required if you want the startup prompt to work)

- I recommend you also either install the packages `fzf` and `thefuck`, or you remove them from `.zshrc` so you don't get warning messages.

- I am not responsible for anything undesirable that happens as a result of you using any of the files in this repo.

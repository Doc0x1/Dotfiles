#!/bin/bash

#$ COLORS AND STYLING

#* ANSI color codes
WARNING='\033[0;91m'
HIGHLIGHT='\033[0;93m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
INFO='\033[0;36m'
NC='\033[0m' # No Color

#* Text Styles
BOLD='\033[1m'
UNDERLINE='\033[4m'
RESET_ALL='\033[0m'
# ============END============

#$ VARIABLES
CLONED_REPO=$(pwd)
INSTALL_DIRECTORY="$HOME"
SHELL="$SHELL"
DEFAULT_SHELL=$(grep "^$USER:" /etc/passwd | cut -d: -f7)
#! ============END============

#! FUNCTIONS
function error_msg() {
    printf "${WARNING}%s${NC}\n" "An error occurred, this may be due to a compatibility issue with your linux distribution, or for another reason entirely."
    printf "${WARNING}%s${NC}\n" "If the error continues please consider creating an issue here:"
    printf "\t${INFO}%s${NC}\n" "$REPO_URL"
    sleep 2
    exit 1
}

function sudo_check() {
    # Check if the user can run commands with sudo
    sudo -l >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        printf "${WARNING}${BOLD}%s\n${RESET_ALL}" "Error: This script currently requires sudo privileges to install necessary APT packages."
        error_msg
    fi
}

#* Clone custom ohmyzsh plugins/themes to the new ohmyzsh install directory
function clone_to_omz() {
    local type=$1 # repo type, either plugins or themes
    local repo=$2
    local name=$3
    # grab the repo name from the url if it's not provided
    [ -z "$name" ] && local name=$(echo "${repo##*/}" | cut -f 1 -d '.')
    if [ -d "$ZSH/custom/$type/$name" ]; then
        printf "${INFO}%s${NC}\n" "$name already installed, updating..."
        cd "$ZSH/custom/$type/$name" && git pull
    else
        printf "${HIGHLIGHT}%s${NC}\n" "Installing $name..."
        git clone --depth=1 "$repo" "$ZSH/custom/$type/$name"
    fi
}

#* Font download for installation function
function font_install() {
    local font_link=$1
    local font_file=$(echo "${font_link//%20/ }" | cut -d '/' -f 8)
    if [[ -f "$HOME"/.fonts/$font_file ]]; then
        printf "${INFO}%s${NC}\n" "$font_file already installed"
    else
        printf "${HIGHLIGHT}%s${NC}\n" "Installing $font_file..."
        wget -q --show-progress -N "$font_link" -P "$HOME/.fonts/"
    fi
}

# Backup files function
function backup() {
    local file=$1
    local file_loc=$HOME/$file
    local backup_loc="$HOME"/.backups/"$file"_$(date +"%Y-%m-%d")
    if [ -f $file_loc ]; then
        printf "${HIGHLIGHT}%s${NC}\n" "Found $file, backing up $file to $HOME/.backups/ ..."
        mv "$file_loc" "$backup_loc"
        printf "${INFO}%s${NC}\n" "Backed up current $file to $backup_loc"
    fi
}

function pkg_manager_install() {
    local pkg_manager=$1
    local pkg_manager_cmd=$2
    if [ $# -eq 2 ]; then # if 2 params package manager is meant to update
        sudo $pkg_manager $pkg_manager_cmd
    elif [ $# -eq 3 ]; then # if 3 params package manager is meant to install
        local package=$3
        sudo $pkg_manager $pkg_manager_cmd $package
    fi
}

# Example = update_then_install `pkg manager` `update command` `install command` `package to install`
function update_then_install() {
    local pkg_manager=$1
    local pkg_update=$2
    local pkg_install=$3
    local package=$4
    sudo $pkg_manager $pkg_update
    if command -v "$package" >/dev/null 2>&1; then
        printf "${INFO}%s${NC}\n" "$package already installed"
    else
        sudo $pkg_manager $pkg_install $package --yes
        printf "\n${HIGHLIGHT}%s${NC}\n" "$package has been installed successfully"
    fi
}

function install_omz_plugins_and_themes() {
    omz_plugins_to_install=(https://github.com/Doc0x1/add-to-omz.git https://github.com/Doc0x1/zautoload.git https://github.com/Doc0x1/zpentest.git)

    printf "%s\n" "Installing omz plugins and themes..."

    for plugin in ${omz_plugins_to_install[@]}; do
        clone_to_omz plugins $plugin
    done

    clone_to_omz plugins https://github.com/jessarcher/zsh-artisan.git artisan
    clone_to_omz plugins https://github.com/marlonrichert/zsh-autocomplete.git
    clone_to_omz plugins https://github.com/zsh-users/zsh-autosuggestions.git
    clone_to_omz plugins https://github.com/zsh-users/zsh-completions.git
    clone_to_omz plugins https://github.com/zsh-users/zsh-history-substring-search.git
    clone_to_omz plugins https://github.com/zsh-users/zsh-syntax-highlighting.git
    clone_to_omz themes https://github.com/romkatv/powerlevel10k.git
    printf "${BLUE}${BOLD}%s${RESET_ALL}\n" "Finished installing omz plugins and themes."
    sleep 2
    printf "\n${INFO}${BOLD}%s${RESET_ALL}\n" "You can use my zautoload plugin to automatically source certain files in your zsh directory."
    printf "${HIGHLIGHT}${BOLD}%s${RESET_ALL}\n" "For it to autoload a file, it needs to be named like this:"
    printf "\t${HIGHLIGHT}${BOLD}%s${RESET_ALL}\n" "\`.p10k.zsh\` or \`.myzshfile.zsh\`"
    sleep 2
    printf "\n${INFO}${BOLD}%s${RESET_ALL}\n" "You can use the add2omz command to add more plugins and themes to your oh-my-zsh install"
    printf "${HIGHLIGHT}${BOLD}%s${RESET_ALL}\n" "Usage: add2omz [--type type] [--url git-repo-url] [options]"
    sleep 2
}

function copy_to_install_dir() {
    EXCLUDE=("LICENSE" "install.sh" ".gitignore" "README.md")

    find "$CLONED_REPO/." -maxdepth 1 -type f | while read -r i; do
        filename=$(basename -- "$i")

        if [[ ! " ${EXCLUDE[@]} " =~ " ${filename} " ]]; then
            abs_path=$(realpath "$i") # Getting the absolute path
            if [ "$is_ssh" = true ]; then
                if [ -e $INSTALL_DIRECTORY/$filename ]; then
                    printf "\n%s\n" "File $INSTALL_DIRECTORY/$filename already exists, skipping..."
                    continue
                fi
                printf "\n%s\n" "Creating symbolic link from $abs_path to $INSTALL_DIRECTORY/$filename"
                ln -s "$abs_path" "$INSTALL_DIRECTORY/$filename"
            else
                printf "\n%s\n" "Copying $abs_path to $INSTALL_DIRECTORY"
                cp -fv "$abs_path" "$INSTALL_DIRECTORY"
            fi
        fi
    done

    printf "${INFO}%s${NC}\n" "Finished copying repo files to $INSTALL_DIRECTORY" && sleep 1
}

#! ============END==============

#! ============BEGIN============

#* check to make sure user can run sudo commands
sudo_check

#* Make sure we're in the github repo directory before running git config
if ! (git status); then
    printf "%s\n" "We aren't in the cloned repo directory,"
    cd "$CLONED_REPO"
fi

#* Fetch repository URL from git config
REPO_URL=$(git config --get remote.origin.url)

#* Transform the URL to the HTTP version if necessary, or set to default
if [ -z "$REPO_URL" ]; then
    REPO_URL="https://github.com/Doc0x1/Dotfiles"
else
    REPO_URL=$(echo "$REPO_URL" | sed -e 's/git@github.com:/https:\/\/github.com\//' -e 's/.git$//')
fi

#* the necessary packages to install
req_pkgs=(zsh git wget neofetch fzf curl)

if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -y
    sudo apt-get install $req_pkgs
else
    if command -v pacman >/dev/null 2>&1; then
        for package in "${req_pkgs[a]}"; do
            update_then_install pacman -Syu -S $package
        done
    elif command -v dnf >/dev/null 2>&1; then
        for package in "${req_pkgs[a]}"; do
            update_then_install dnf update install $package
        done
    elif command -v yum >/dev/null 2>&1; then
        for package in "${req_pkgs[a]}"; do
            update_then_install yum check-update install $package
        done
    else
        error_msg
    fi
fi

#$ ASK TO BACKUP FILES --- ZSH CONFIG INSTALLS BEGIN AFTER THIS
backup_files=(.zshrc .zprofile .zshenv .zlogin .zlogout .bashrc .bash_profile .bash_logout)
while true; do
    printf "During this install, any zsh related dotfiles (such as .zshrc, .zshenv) in user's home directory will be deleted.\n"
    printf "Are there dotfiles in your home directory that you want to backup?\n"
    read -rp "Backup existing dotfiles in home directory? [Y/n]: " yn
    case $yn in
    [Yy]*)
        printf "Starting backup...\n"
        mkdir -p "$HOME/.backups" # Create file backup directory
        # Backup files
        for file in $backup_files; do
            backup $file
        done
        printf "Finished backing up any existing zsh files. Continuing...\n" && sleep 1
        break
        ;;
    [Nn]*)
        printf "Continuing without backing up existing zsh files...\n" && sleep 1
        break
        ;;
    *)
        printf "Please provide a valid answer.\n"
        ;;
    esac
done

#$ CHOOSE INSTALL DIRECTORY
while true; do
    printf "\n%s\n" "Where should your zsh and oh-my-zsh configuration files be installed?"
    printf "%s\n" "Default install directory is: $HOME"
    printf "%s\n" "Directory must be a subdirectory of your user's home folder."
    printf "  - %s\n" "Press ENTER to confirm the location" "Press CTRL-C to abort the installation" "Or specify a different location below"
    printf "[%s] >>> " "$HOME"
    read -r user_prefix

    # If user presses enter
    if [ -z "$user_prefix" ]; then
        user_prefix=$HOME
    else # If user provides custom directory
        # Replace ~ with the value of $HOME
        user_prefix="${user_prefix/#\~/$HOME}"
        # Clean up double slashes if any
        user_prefix=$(echo "$user_prefix" | sed 's/\/\//\//g')
    fi

    # Ensure the directory is within the home folder
    case "$user_prefix" in
    "$HOME") INSTALL_DIRECTORY=$HOME ;;
    "$HOME"/*) INSTALL_DIRECTORY=$user_prefix ;;
    *)
        printf "ERROR: Installation directory must be a subdirectory of the home folder.\n" >&2
        continue
        ;;
    esac

    # if directory exists, don't try creating it
    if [ -e "$INSTALL_DIRECTORY" ]; then
        printf "\n%s\n" "Directory already exists, no need to create it."
        break
    else
        if mkdir -p "$INSTALL_DIRECTORY"; then
            printf "\n%s\n" "Directory created." && ls -ld "$INSTALL_DIRECTORY" && sleep 1
            break
        else # let user know we couldn't create directory
            printf "%s\n%s\n%s\n" '!-------------------------!' "Couldn't create directory: $INSTALL_DIRECTORY" '!-------------------------!'
            printf "Make sure you have the correct permissions to create the directory.\n" && sleep 3
            continue
        fi
    fi
done

eval EXPANDED_INSTALL_DIRECTORY="${INSTALL_DIRECTORY%/}"

if [ "$EXPANDED_INSTALL_DIRECTORY" = "$HOME" ]; then
    INSTALL_IS_HOME=true
else
    INSTALL_IS_HOME=false
fi

#$ START TO COPY FILES FROM REPO TO INSTALL DIRECTORY
cd "$CLONED_REPO" || error_msg
# Check if the URL is SSH format (In case it's me running this script on one of my machines)
if [[ "$(git config --get remote.origin.url)" == git@github.com:* ]]; then
    printf "${BLUE}${BOLD}%s${RESET_ALL}\n" "Hi Doc! Nice to see you!"
    read -p "Do you want to create symbolic links instead of copying files this time? [Y/n]: " decision
    if [[ "$decision" =~ ^[Yy]$ || -z "$decision" ]]; then
        is_ssh=true
    else
        is_ssh=false
    fi
else
    is_ssh=false
fi

# Oh-My-ZSH INSTALL
printf "\n%s\n" "Installing oh-my-zsh into $INSTALL_DIRECTORY" && sleep 1
ZDOTDIR="$INSTALL_DIRECTORY"
ZSH=$ZDOTDIR/.oh-my-zsh
if [ -d "$HOME/.oh-my-zsh" ]; then # OMZ already installed, but located in user's home dir
    printf "%s\n" "oh-my-zsh is already installed in home directory, moving to new $INSTALL_DIRECTORY directory..."
    OMZ_INSTALLED=true
    mv "$HOME/.oh-my-zsh" "$INSTALL_DIRECTORY"
    cd "$INSTALL_DIRECTORY/.oh-my-zsh" && git pull
else
    if [ -d "$INSTALL_DIRECTORY/.oh-my-zsh" ]; then # OMZ installed in install dir
        printf "%s\n" "oh-my-zsh is already installed in $INSTALL_DIRECTORY."
        OMZ_INSTALLED=true
        cd "$INSTALL_DIRECTORY/.oh-my-zsh" && git pull
    else
        printf "oh-my-zsh is not installed. Installing...\n" # OMZ not installed
        cd $INSTALL_DIRECTORY >/dev/null 2>&1
        ZDOTDIR=$INSTALL_DIRECTORY ZSH=$INSTALL_DIRECTORY/.oh-my-zsh sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        if [ -f "$INSTALL_DIRECTORY/.zshrc" ]; then
            mv .zshrc .zshrc.post-oh-my-zsh
        fi
        printf "oh-my-zsh installed successfully.\n"
    fi
fi

cd - >/dev/null 2>&1

copy_to_install_dir

printf "\n%+50s\n\n" "READY TO INSTALL OhMyZSH PLUGINS" && sleep 1

if [ ! -d "$INSTALL_DIRECTORY/.oh-my-zsh" ]; then
    printf "%s\n" "Something's wrong, oh-my-zsh isn't in $INSTALL_DIRECTORY..."
    printf "Checking if oh-my-zsh is in home directory...\n" && sleep 3
    if [ -d ~/.oh-my-zsh ]; then
        printf "%s\n" "oh-my-zsh is in home directory, will move it to $INSTALL_DIRECTORY..."
        mv "$HOME/.oh-my-zsh" "$INSTALL_DIRECTORY" && printf "%s\n" "oh-my-zsh directory moved to $INSTALL_DIRECTORY, can proceed now" && sleep 3
        install_omz_plugins_and_themes
    else
        printf "oh-my-zsh is NOT in correct directory, something is wrong!\n"
        error_msg
    fi
else
    # INSTALL (or update) OMZ PLUGINS
    install_omz_plugins_and_themes
fi

printf "%s\n" "Install Fonts? (Recommended if not done already) [Y/n]: "
read -r install_fonts
case $install_fonts in
[Yy]*)
    printf "%s\n" "Installing fonts..."
    # INSTALL EMOJI FONTS IF NONE FOUND
    if fc-list | grep -i emoji >/dev/null; then
        printf "Emoji fonts found, won't install any more. If emojis are missing try downloading fonts-noto-color-emoji and fonts-recommended packages\n" && sleep 1
    else
        if command -v apt >/dev/null 2>&1; then
            if sudo apt install -y fonts-noto-color-emoji fonts-recommended || sudo pacman -S fonts-noto-color-emoji fonts-recommended || sudo dnf install -y fonts-noto-color-emoji fonts-recommended || sudo yum install -y fonts-noto-color-emoji fonts-recommended || pkg install fonts-noto-color-emoji fonts-recommended; then
                printf "Fonts to show latest emojis are installed\n"
            else
                printf "Couldn't install fonts, latest emojis may not show correctly\n"
            fi
        fi
    fi

    # INSTALL FONT FILE
    # Create .fonts directory in home folder if not existing
    if [[ -d ~/.fonts ]]; then
        echo "Fonts directory already exists."
    else
        mkdir ~/.fonts
    fi

    font_install https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
    font_install https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
    font_install https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
    font_install https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf

    # use fc-cache -f -c to immediately make them available immediately
    cd ~/.fonts && fc-cache -f -v >/dev/null 2>&1 && cd - >/dev/null 2>&1
    printf "Fonts installed.\n"
    sleep 1
    printf "\nBe sure to set your terminal font to MesloLGS NF Regular for Powerlevel10k icons to display properly.\n"
    sleep 3
    ;;
[Nn]*)
    printf "Skipping font installation...\n"
    ;;
*)
    printf "Skipping font installation...\n"
    ;;
esac

cd $INSTALL_DIRECTORY

#* ONLY RUN IF INSTALLING TO A DIRECTORY OTHER THAN HOME
if [ "$INSTALL_IS_HOME" != true ]; then
    # If we aren't installing to user's home directory, we need a way to let Zsh know where to look for zshrc, zshenv, etc.. files
    if [ $(pwd) != "$HOME" ]; then
        cd "$HOME"
        [ -e "~/.zshrc" ] && rm -f .zshrc
        [ -e "~/.zsh" ] && rm -rf .zsh
    fi

    # List of common Zsh config files
    config_files=( ".zshrc" ".zsh_history" ".zsh_profile" ".zlogin" ".zlogout" ".zcompdump*" )

    # Directory to search in, defaults to the current user's home directory.
    # Replace with another path if needed.
    HOME_DIR="${HOME}"

    # Loop through the list of config files and remove them
    for file in "${config_files[@]}"; do
    # Use find to locate the files and directories and remove them
    find "$HOME_DIR" -name "$file" -exec rm -rv {} +
    done

    printf "${INFO}%s${NC}\n" "Zsh configuration files have been removed from $HOME_DIR"

    #* PARTIAL_DIRECTORY variable is used to get the relative path of the install directory from the user's home directory
    PARTIAL_DIRECTORY="${INSTALL_DIRECTORY#$HOME/}"

    # INSERT_TEXT variable is used to insert the export ZDOTDIR line into the user's .zshenv file
    INSERT_TEXT="[[ -z "\$ZDOTDIR" && -e \$HOME/$PARTIAL_DIRECTORY ]] && export ZDOTDIR=\$HOME/$PARTIAL_DIRECTORY"
    if ! grep -Fxq "$INSERT_TEXT" "$INSTALL_DIRECTORY/.zshenv"; then
        printf "%s\n" "Inserting lines to export ZDOTDIR into $HOME/.zshenv file..."
        echo "$INSERT_TEXT" >>"$INSTALL_DIRECTORY/.zshenv"
    else
        printf "%s\n" "Lines already exist in $INSTALL_DIRECTORY/.zshenv file, taking no action."
    fi

    while true; do
        printf "\n%s\n\v%s\n\n%s\n\n%+50s\n\t%s\t%s\n\t%s\t%s\n\t%s\t%s\n\t>>> " \
            "Zsh, by default, looks for zshrc, zshenv, etc.. in the user's home directory, so we set the ZDOTDIR variable required to let Zsh know where to look for these files." \
            "We can symlink the zshenv file with the export ZDOTDIR line in it to your home directory from your $INSTALL_DIRECTORY directory, or we can export the variable in /etc/zsh/zshenv (this is my preferred method)." \
            "If already set, you can press enter to continue." \
            "OPTIONS:" \
            "[1]" "Create symbolic link to $INSTALL_DIRECTORY/.zshenv in $HOME directory to point to your ZSH install directory." \
            "[2]" "Configure global ZSH file /etc/zsh/zshenv to set ZSH install directory to $INSTALL_DIRECTORY (may require sudo privileges)" \
            "[Enter]" "Do nothing; ZDOTDIR is already set."
        read -r choice
        case $choice in
        [1])
            printf "%s\n" "Let's make sure there's no .zshenv file in your home directory already..."
            if [ -L "$HOME/.zshenv" ]; then
                printf "%s\n" "Found .zshenv file in home directory, removing it..."
                rm -v "$HOME/.zshenv"
                printf "%s\n" "Checking to see if we need to insert lines exporting ZDOTDIR in the $INSTALL_DIRECTORY/.zshenv file..."
                ln -sv "$INSTALL_DIRECTORY/.zshenv" "$HOME/.zshenv"
            else
                printf "%s\n" "No .zshenv file found in home directory, creating symbolic link now..."
                ln -sv "$INSTALL_DIRECTORY/.zshenv" "$HOME/.zshenv"
            fi
            # Print out indicator if something went wrong
            [ $? -eq 0 ] && printf "Finished.\n" || printf "%s\n" "Something went wrong around install.sh lines 386-412..."

            printf "${WARNING}%s${RESET_ALL}\n" "YOU WILL NEED TO MODIFY $HOME/.zshenv IF YOU CHANGE YOUR ZSH DIRECTORY LOCATION!"
            sleep 5

            break
            ;;
        [2])
            printf "%s\n" "Checking to see if we need to insert lines exporting ZDOTDIR in the /etc/zsh/zshenv file..."
            if ! grep -Fxq "$INSERT_TEXT" "/etc/zsh/zshenv"; then
                printf "%s\n" "Lines not found in /etc/zsh/zshenv file, inserting lines now..."
                echo "$INSERT_TEXT" | sudo tee -a /etc/zsh/zshenv
            else
                printf "%s\n" "Lines already exist in /etc/zsh/zshenv file, taking no action."
            fi
            # Print out indicator if something went wrong
            [ $? -eq 0 ] && printf "Finished.\n" || printf "%s\n" "Something went wrong around install.sh lines 386-429..."
            printf "%s\n" "!!!IMPORTANT: YOU WILL NEED TO MODIFY /etc/zsh/zshenv IF YOU CHANGE YOUR ZDOTDIR DIRECTORY LOCATION!" && sleep 5
            break
            ;;
        "")
            if [[ "$DEFAULT_SHELL" != *"/zsh" ]]; then
                printf "%s\n" "Using bash as default shell, so ZDOTDIR variable won't be naturally set.\n"
                printf "%s\n" "We can grep for ZDOTDIR being exported in the user's chosen install directory .zshenv file, and if it's there, it means it's set."
                if grep -q "export ZDOTDIR" "$INSTALL_DIRECTORY/.zshenv" >/dev/null 2>&1; then
                    printf "%s\n%s\n" "ZDOTDIR variable found already being exported inside the $INSTALL_DIRECTORY/.zshenv file." "We can continue..." && sleep 3
                    break
                else
                    printf "%s\n" "ZDOTDIR variable not found in $INSTALL_DIRECTORY/.zshenv file."
                    printf "%s\n" "You'll have to create a symbolic link to your .zshenv file in your $INSTALL_DIRECTORY directory to your home directory. Otherwise"
                    printf "%s\n" "you'll have to export the ZDOTDIR variable in your .bashrc file or .bash_profile file."
                    break
                fi
            else
                if [[ -z "$ZDOTDIR" ]] && [[ "$INSTALL_DIRECTORY" != "$HOME" ]]; then
                    printf "%s\n" "You don't have the ZDOTDIR variable set! You need to choose one of the above options. Read through them carefully."
                    continue
                elif [[ -n "$ZDOTDIR" ]] || [[ "$INSTALL_DIRECTORY" == "$HOME" ]]; then
                    printf "%s\n" "Variable already set. Nothing will be done. Continuing on to final steps..." && sleep 5
                    break
                fi
            fi
            ;;
        *)
            printf "%s\n" "Please provide a valid answer."
            ;;
        esac
    done
else
    printf "${INFO}%s${NC}\n" "Since we're using home directory for install, skipping alternate location setup."
fi

# Check if default shell is zsh
if [[ "$DEFAULT_SHELL" != *"/zsh" ]]; then
    # Ask user if they want to change default shell to zsh
    while true; do
        printf "${YELLOW}%s${NC}\n" "DEFEAULT SHELL IS NOT ZSH"
        printf "${WARNING}%s${NC}\n" "Important: Sudo access may be needed to change default shell"
        printf "${HIGHLIGHT}%s${NC}\n" "Change default shell to zsh? [Y/n]: "
        read -r change_shell
        case $change_shell in
            [Yy]*)
                printf "${INFO}%s${NC}\n" "Changing default shell to zsh"
                if chsh -s "$(which zsh)"; then
                    printf "${INFO}%s${NC}\n" "Installation Successful, exit terminal and enter a new session"
                else
                    error_msg
                fi
                break
                ;;
            [Nn]*)
                printf "${INFO}%s${NC}\n" "Default shell will not be changed"
                break
                ;;
            *)
                continue
                ;;
        esac
    done
else
    printf "${INFO}%s${NC}\n" "Default shell is already $(which zsh)"
fi

printf "${HIGHLIGHT}%s${NC}\n" "Install finished."

exit

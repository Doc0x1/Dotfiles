#!/bin/zsh
#! Doc0x1's Functions

# COLORS (to make help message look pretty)
# color_off='\033[0m'
# Regular Colors
local Purple=$(tput setaf 0)
local Red=$(tput setaf 1)
local Green=$(tput setaf 2)
local Brown=$(tput setaf 3)
local Blue=$(tput setaf 4)
local Magenta=$(tput setaf 5)
local Cyan=$(tput setaf 6)
local White=$(tput setaf 7)
local Black=$(tput setaf 8)

cleanzsh() {
  rm -f ${ZDOTDIR:-$HOME}/.zcompdump* ${ZDOTDIR:-$HOME}/.zshrc.zwc
  omz reload
}

# edit recent git commit
function gcedit() {
  git add .
  if [[ "$1" != "" ]]; then
    git commit -m "$1"
  else
    git commit -m update # default commit message is `update`
  fi
}

# cheat sheets (github.com/chubin/cheat.sh), find out how to use commands
# example 'cheat tar'
# for language specific question supply 2 args first for language, second as the question
# eample: cheat python3 execute external program
cheat() {
  if [[ "$2" ]]; then
    curl "https://cheat.sh/$1/$2+$3+$4+$5+$6+$7+$8+$9+$10"
  else
    curl "https://cheat.sh/$1"
  fi
}

speedtest() {
  curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -
}

# Updates Oh-My-Zsh plugins
update_plugins() {
  local cwd=$(pwd)
  for i in $ZSH/custom/plugins/*; do
    if [[ -d "$i" ]]; then
      echo $Red"Checking $i for updates..."
      cd "$i" &>/dev/null && git pull --no-rebase &>/dev/null && echo $Blue"Updated $i" || echo $Red"No updates for $i"
      echo $Green"Done.\n"
    fi
  done && cd $cwd
}

ssh_copy_server_key() {
  if [[ $# -eq 0 ]]; then
    echo "Specify the server connection details and the public key to install.\n"
    echo "Ex: $0 $HOME/.ssh/id_rsa.pub user@192.168.1.1\n"
  elif [[ $# -eq 2 ]]; then
    if [[ "$1" == *".pub" ]] && [[ "$2" == *"@"* ]]; then
      echo "Copying public key file $1 to $2 ...\n"
      ssh-copy-id -i "$1" "$2"
      [[ $? -eq 0 ]] && echo "Operation completed successfully.\n" || echo "Error: Something went wrong.\n"
    else
      echo "Error: Invalid parameters specified.\n"
    fi
  else
    echo "Error: Invalid number of parameters specified.\n"
    echo "Specify the server connection details and the public key to install.\n"
    echo "Ex: $0 $HOME/.ssh/id_rsa.pub user@192.168.1.1\n"
  fi
}

exec_in_bg() {
  if [[ $# -eq 0 ]]; then
    echo "Specify the command to execute in the background.\n"
    echo "Ex: $0 nohup ./vendor/bin/sail up\n"
  elif [[ $# -eq 1 ]]; then
    echo "Executing $1 in the background...\n"
    nohup $1 &
  elif [[ $# -gt 1 ]]; then
    local command=$1
    local params=$2
    for i in "$@"; do
      if [[ "$i" != "$0" ]] && [[ "$i" != "$1" ]] && [[ "$i" != "$2" ]]; then
        params+=" $i"
      fi
    done
    echo "Executing $command in the background...\n"
    nohup $command $params &
  else
    echo "Unknown error.\n"
    echo "Specify the command to execute in the background.\n"
    echo "Ex: $0 nohup ./vendor/bin/sail up\n"
  fi
}

# Github
git_pushupstr() {
  if [[ $# -eq 0 ]]; then
    echo "Please specify the upstream branch name to push to\n"
  elif [[ $# -eq 1 ]]; then
    git push --set-upstream origin $1
  else
    echo "Invalid number of parameters specified. Please specify the upstream branch name to push to\n"
  fi
}

permissioncheck() {
  local filename="$1"
  local fullpath=$(realpath "$filename")
  local dirname=$(dirname "$fullpath")

  echo "=================================="
  echo "Filename:  $filename in $dirname"

  ls -ld "$filename" | awk '{print $1, $3, $4}' | awk -v user=$(whoami) -v group=$(id -gn) '
  function format_permission(symbol, permission) {
    if (symbol == "-") {
      return permission " (No)";
    } else {
      return permission " (OK)";
    }
  }

  BEGIN {
    type_trans["-"] = "Regular File";
    type_trans["d"] = "Directory";
    type_trans["l"] = "Symbolic Link";
  }

  {
    own = ($2 == user) ? "Yes" : "No";
    grp = ($3 == group) ? "Yes" : "No";
    
    printf "Owner: %s (You are owner: %s)\nGroup: %s (You are in group: %s)\nType: %s\nUser: %s | %s | %s\nGroup: %s | %s | %s\nOthers: %s | %s | %s\n", 
    $2, own, $3, grp, type_trans[substr($1, 1, 1)], 
    format_permission(substr($1, 2, 1), "Read"), format_permission(substr($1, 3, 1), "Write"), format_permission(substr($1, 4, 1), "Execute"), 
    format_permission(substr($1, 5, 1), "Read"), format_permission(substr($1, 6, 1), "Write"), format_permission(substr($1, 7, 1), "Execute"), 
    format_permission(substr($1, 8, 1), "Read"), format_permission(substr($1, 9, 1), "Write"), format_permission(substr($1, 10, 1), "Execute")
  }'

  echo "=================================="
}

pyvenv() {
  if [[ $# -eq 0 ]]; then
    if [[ -d "./venv" ]]; then
      printf "venv directory already exists. Will source it...\n" && sleep 1
      source ./venv/bin/activate
    else
      while true; do
        printf "Are you sure you want to create a python venv directory here: $(pwd) ?\n"
        read "yn?[Y/n]: "
        case $yn in
        [Yy]*)
          printf "Creating virtual environment venv in $(pwd) ...\n"
          /bin/python3 -m venv venv
          printf "Finished creating python virtual environment. Will now source it...\n" && sleep 1
          source ./venv/bin/activate
          break
          ;;
        [Nn]*)
          printf "Okay, not setting up a venv directory here.\n"
          break
          ;;
        *)
          printf "Please provide a valid answer.\n"
          ;;
        esac
      done
    fi
  else
    printf "Why are you providing arguments? Just go to the directory and use the command.\n"
  fi
}

verify_checksum() {
  [[ $# -eq 0 ]] && printf "\nUsage: verify_checksum <sha256 checksum> <file>\n"
  if [[ $# -eq 2 ]]; then
    local checksum=$1
    [[ -f $2 ]] && local file=$2 || printf "File $2 does not exist.\n" && return
    printf "Verifying checksum of $file ...\n"
    sha256sum -c <<<"$checksum $file"
  else
    printf "Incorrect number of arguments provided.\n"
    printf "\nUsage: verify_checksum <sha256 checksum> <file>\n"
  fi
}

diffcolor() {
  if [ $# -eq 2 ]; then
    diff --color=always $1 $2
  else
    diff --help
  fi
}

rustscanauto() {
  [[ $# -eq 0 ]] && printf "\nUsage: rustscanauto <IP>\n"
  if [[ $# -eq 1 ]]; then
    rustscan -a $1 -- -sC -sV | tee scan.txt
  else
    printf "\nUsage: rustscanauto <IP>\n"
  fi
}

find_and_do() {
  local dir=""
  local name=""
  local cmd=""
  local ext=""
  local opts=""
  local log_file=""
  local confirm=1

  # Parse command-line arguments
  while [ "$#" -gt 0 ]; do
    case "$1" in
    -dir)
      dir="$2"
      shift 2
      ;;
    -name)
      name="$2"
      shift 2
      ;;
    -cmd)
      cmd="$2"
      shift 2
      ;;
    -ext)
      ext="$2"
      shift 2
      ;;
    -opts)
      opts="$2"
      shift 2
      ;;
    --log)
      log_file="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      return 1
      ;;
    esac
  done

  # Check if mandatory arguments are provided
  if [ -z "$dir" ] || [ -z "$name" ] || [ -z "$cmd" ]; then
    echo "Missing mandatory arguments. Usage:"
    echo "find_and_do -dir [DIRECTORY] -name [NAME] -cmd [COMMAND] [-ext [EXTENSION]] [-opts [FIND-OPTIONS]] [--log [LOG_FILE]]"
    return 1
  fi

  # Construct the find command for listing files
  local list_cmd="find $dir -name \"$name\""

  if [ ! -z "$ext" ]; then
    list_cmd="$list_cmd -name \"*.$ext\""
  fi

  if [ ! -z "$opts" ]; then
    list_cmd="$list_cmd $opts"
  fi

  # Show the list of files that will be affected
  echo "The following files will be affected:"
  eval "$list_cmd"

  # Prompt for confirmation
  if [ $confirm -eq 1 ]; then
    read -p "Are you sure you want to proceed? (y/N): " response
    if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      echo "Operation cancelled."
      return 0
    fi
  fi

  # Append the -exec option for find
  list_cmd="$list_cmd -exec sudo $cmd {} \;"

  # Execute the find command
  if [ ! -z "$log_file" ]; then
    eval "$list_cmd" | tee -a "$log_file"
  else
    eval "$list_cmd"
  fi
}

add2path() {
  local input_path="$1"
  
  if [[ $# -ne 1 ]]; then
    echo "Invalid input. Please specify a single, valid directory path to add."
    return 1
  fi

  # Expand potential environment variables in the input path
  local expanded_path
  expanded_path=$(eval echo "$input_path")

  # Check if the path exists and is a directory
  if [[ ! -e "$expanded_path" ]]; then
    echo "The specified path does not exist. Exiting."
    return 1
  elif [[ ! -d "$expanded_path" ]]; then
    echo "The specified path is not a directory. Exiting."
    return 1
  fi

  # Determine the location of .zshenv
  local zenv
  if [[ -z $ZDOTDIR ]]; then
    zenv="$HOME/.zshenv"
  else
    zenv="$ZDOTDIR/.zshenv"
  fi

  # Check if .zshenv exists
  if [[ ! -f "$zenv" ]]; then
    echo "No .zshenv file found. Exiting."
    return 1
  fi

  # Check if the path is already in the directories=() array
  if grep -qF "\"$input_path\"" "$zenv"; then
    echo "Path $input_path is already in the directories array. Skipping."
    return 0
  fi

  # Ask for confirmation before adding
  printf "Do you want to add %s to your PATH in .zshenv?\n" "$input_path"
  read -r "yn?[Y/n]: "

  case $yn in
    [Yy]*|"") ;; # Continue if user says yes or presses enter
    [Nn]*) 
      printf "Aborted. No changes made.\n"
      return 0
      ;;
    *)
      printf "Invalid response. Aborting.\n"
      return 1
      ;;
  esac

  # Add the path to the end of the directories=() array in .zshenv
  local tmp_file
  tmp_file=$(mktemp)
  if awk -v new_path="$input_path" '
    BEGIN { in_directories = 0 }
    /^directories=\(/ { 
      print; 
      in_directories = 1; 
      next 
    } 
    /^\)/ && in_directories { 
      printf "    \"%s\"\n", new_path; 
      in_directories = 0 
    } 
    { print }
  ' "$zenv" > "$tmp_file"; then
    mv -f "$tmp_file" "$zenv"
    echo "Successfully added $input_path to directories in .zshenv."
  else
    echo "Failed to update .zshenv. Make sure you have write access to it."
    rm -f "$tmp_file"
    return 1
  fi
}

# remove_path_duplicates() {
#   # Determine the location of .zshenv
#   local zenv
#   if [[ -z $ZDOTDIR ]]; then
#     zenv="~/.zshenv"
#   else
#     zenv="$ZDOTDIR/.zshenv"
#   fi

#   # Check if .zshenv exists
#   if [[ ! -f $zenv ]]; then
#     echo "No .zshenv file found. Exiting.\n"
#     return 1
#   fi

#   # Extract the current PATH from .zshenv
#   local current_path=$(grep '^PATH=' $zenv | sed 's/^PATH=//')

#   if [[ -z $current_path ]]; then
#     echo "No PATH variable found in .zshenv. Exiting.\n"
#     return 1
#   fi

#   # Remove duplicate entries
#   local seen=""
#   local new_path=""
#   local separator=":"
#   IFS="$separator"
#   for dir in $current_path; do
#     if [[ ! $seen == *"$separator$dir$separator"* ]]; then
#       if [[ -n $new_path ]]; then
#         new_path="$new_path$separator"
#       fi
#       new_path="$new_path$dir"
#       seen="$seen$separator$dir$separator"
#     fi
#   done
#   unset IFS

#   # Update .zshenv
#   local tmp_file=$(mktemp)
#   sed "s|^export PATH=.*$|export PATH=$new_path|" $zenv > $tmp_file
#   if mv $tmp_file $zenv; then
#     echo "Successfully removed duplicate entries from PATH in .zshenv.\n"
#   else
#     echo "Failed to update .zshenv. Make sure you have write access to it.\n"
#     rm -f $tmp_file
#     return 1
#   fi
# }

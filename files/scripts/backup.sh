#!/usr/bin/env bash

function help() {
  echo "Usage: $0 create (init|desktop|usb)"
  echo "Usage: $0 move <backup_dest>"
  exit 1
}

function test_server_connection() {
  if [[ ! -d "/smb/other" ]]; then
    echo "Unable to connect to server"
    exit 1;
  fi
}

function create_init() {
  test_server_connection
  local dest="/smb/.backup"

  if [[ -d "$dest" ]]; then
    echo "Deleting old backup data"
    rm -rf "$dest";
  fi

  mkdir -p $dest

  clone_github() {
    local gh_user="keifufu"
    local gh_dir=$1
    get_repos() {
      curl -s "https://api.github.com/users/$gh_user/repos" | grep -o 'git@[^"]*'
    }
    mkdir -p "$gh_dir"
    for repo_url in $(get_repos); do
      local repo_name=$(basename -s .git "$repo_url")
      git clone "$repo_url" "$gh_dir/$repo_name"
    done
  }

  clone_github "$dest/github"

  echo "Done initializing backup"
}

function create_desktop() {
  test_server_connection
  if ! mountpoint -q "/stuff"; then
    echo "wtf? where /stuff?"
    exit 1
  fi
  local dest="/smb/.backup"
  local ssh_dest="keifufu@192.168.2.111:/data/data/.backup"

  local excluded_desktop=("/.Trash-1000" "/lost+found" "/games" "/SteamLibrary" "/.pnpm-store" "wineprefix")
  mkdir -p "$dest/desktop"
  rsync -ah --info=progress2 --filter=':- .gitignore' "${excluded_desktop[@]/#/--exclude=}" "/stuff/" "$ssh_dest/desktop"

  echo "Done creating desktop"
}

function create_usb() {
  test_server_connection
  if ! mountpoint -q "/usb"; then
    echo "Mount /usb to continue"
    exit 1
  fi
  local dest="/smb/.backup"
  local ssh_dest="keifufu@192.168.2.111:/data/data/.backup"

  local excluded_usb=("/.Trash-1000" "/lost+found")
  mkdir -p "$dest/desktop"
  rsync -ah --info=progress2 --filter=':- .gitignore' "${excluded_desktop[@]/#/--exclude=}" "/usb/" "$ssh_dest/usb"
 
  echo "Done creating usb"
}

function move_backup() {
  local dest="$1"
  local dotbackup="/data/data/.backup"
  local excluded_server=("/.Trash-1000" "/lost+found" ".backup")

  if [[ ! -d "$dotbackup" || ! -d "$dotbackup/github" || ! -d "$dotbackup/desktop" || ! -d "$dotbackup/usb" ]]; then
    echo "backup was not created or is incomplete"
    exit 1
  fi

  rsync -ah --info=progress2 "$dotbackup/" "$dest"
  rsync -ah --info=progress2 --filter=':- .gitignore' "${excluded_server[@]/#/--exclude=}" "/data/" "$dest/server"

  echo "Done moving backup"
}

if [[ "$1" == "create" ]]; then
  # Backing up on laptop is not handled yet (or even nessecary)
  if [[ "$(hostname)" != "desktop" ]]; then
    echo "Invalid hostname"
    exit 1
  fi

  if [[ "$2" == "init" ]]; then
    create_init
  elif [[ "$2" == "desktop" ]]; then
    create_desktop
  elif [[ "$2" == "usb" ]]; then
    create_usb
  else
    help
  fi
elif [[ "$1" == "move" ]]; then
  if [[ "$(hostname)" != "server" ]]; then
    echo "Invalid hostname"
    exit 1
  fi

  if [[ ! -d "$2" ]]; then
    echo "$2 does not exist"
    exit 1
  elif [[ -d "$2/backup" ]]; then
    echo "$2 does not have a backup folder"
    exit 1
  fi

  move_backup "$2/backup/$(date +"%Y-%m-%d")"
else
  help
fi

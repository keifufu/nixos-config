## Installing

This isn't meant for anyone to follow really, it's just a reminder for myself.

`sudo loadkeys de`

<details>
<summary>Setting up archive disks</summary>

- `sudo cryptsetup luksFormat --label ARCHIVE1 /dev/<DISK>`
- `sudo cryptsetup luksOpen /dev/<DISK> ARCHIVE1`
- `sudo cryptsetup refresh --perf-no_read_workqueue --perf-no_write_workqueue --persistent ARCHIVE1`
- `sudo mkfs.ext4 /dev/mapper/ARCHIVE1`
- `sudo cryptsetup luksClose ARCHIVE1`

use cryptutil.sh for mounting/unmounting

</details>

<details>
<summary>Enabling wifi</summary>

- `sudo systemctl start wpa_supplicant`
- `wpa_cli`
- `scan`
- `scan_results`
- `add_network`
- `set_network 0 ssid "<SSID>"`
- `set_network 0 psk "<PASS>"`
- `enable_network 0`

</details>

<details>
<summary>Partitions</summary>

<details>
<summary>Creating partitions</summary>

## Create Partitions

### EFI

- `sudo fdisk /dev/nvme0n1`
- `g (gpt disk label)`
- `n`
- `1`
- `2048`
- `+500M`
- `t`
- `1 (EFI System)`

### Root Partition

- `n`
- `2`
- `default`
- `+250G`

### Stuff Partition

- `n`
- `3`
- `default`
- `default (fill up partition)`
- `w (write)`

### Format EFI

- `sudo mkfs.fat -F 32 /dev/nvme0n1p1`
- `sudo fatlabel /dev/nvme0n1p1 BOOT`

### Setup LUKS for ROOT

- `sudo cryptsetup luksFormat --label CRYPTROOT /dev/nvme0n1p2`
- `sudo cryptsetup luksOpen /dev/nvme0n1p2 cryptroot`
- `sudo pvcreate /dev/mapper/cryptroot`
- `sudo vgcreate vg /dev/mapper/cryptroot`
- `sudo lvcreate -L 16G -n swap vg`
- `sudo lvcreate -l 100%FREE -n root vg`
- `sudo mkfs.ext4 /dev/vg/root -L ROOT`
- `sudo mkswap /dev/vg/swap -L SWAP`

### Setup LUKS for STUFF

- `sudo cryptsetup luksFormat --label CRYPTSTUFF /dev/nvme0n1p3`
- `sudo cryptsetup luksOpen /dev/nvme0n1p3 cryptstuff`
- `sudo mkfs.ext4 /dev/mapper/cryptstuff -L STUFF`

### Installing NixOS

## Mount Partitions

- `sudo mount /dev/vg/root /mnt`
- `sudo mkdir /mnt/boot`
- `sudo mount -o umask=077 /dev/nvme0n1p1 /mnt/boot`
- `sudo swapon /dev/vg/swap`

</details>

### Desktop

- nvme0n1
  - 1 - 500MB EFI
  - 2 - 38GB SWAP
  - 3 - 461.5GB ROOT
- nvme1n1
  - \* - 1TB STUFF

### Laptop

- nvme0n1
  - 1 - 500MB EFI
  - 2 - 20GB SWAP
  - 3 - 250GB ROOT
  - 4 - 729.5GB STUFF

### Server

- sda
  - 1 - 500MB EFI
  - 2 - 20GB Swap
  - 3 - 229.5GB ROOT
- nvme0n1
  - p1 - 2TB STUFF

</details>

### Clone repo

- `nix-shell -p git`
- `git clone https://github.com/keifufu/snowflake`

## Mount Partitions

- `sudo mount /dev/disk/by-label/ROOT /mnt`
- `sudo mkdir -p /mnt/boot`
- `sudo mount /dev/disk/by-label/BOOT /mnt/boot`

## Install NixOS

On server before nixos-install:

- `sudo mkdir -p /mnt/etc/secrets/initrd`
- `sudo ssh-keygen -t rsa -N "" -f /mnt/etc/secrets/initrd/ssh_host_rsa_key`

`sudo nixos-install --flake .#<host> --option substituters "https://cache.nixos.org?trusted=1 https://hyprland.cachix.org?trusted=1 https://nix-community.cachix.org?trusted=1"`

## After install

- set root password
- `touch /mnt/home/keifufu/.no-hypr`
- `sudo reboot`
- `sudo passwd keifufu`
- `git clone https://github.com/keifufu/snowflake ~/.snowflake`
- `Hyprland`

- server: sudo smbpasswd -a \<user>

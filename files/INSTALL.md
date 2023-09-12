## Installing

This isn't meant for anyone to follow really, it's just a reminder for myself.

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

### Swap

- `n`
- `2`
- `default`
- `+15G`
- `t`
- `2`
- `19 (Linux swap)`

### root

- `n`
- `3`
- `default (fill up partition)`
- `default (fill up partition)`
- `w (write)`

## Label Partitions

- `sudo mkfs.fat -F 32 /dev/nvme0n1p1`
- `sudo fatlabel /dev/nvme0n1p1 BOOT`
- `sudo mkswap /dev/nvme0n1p2`
- `sudo mkfs.ext4 /dev/nvme0n1p3 -L ROOT`

</details>

### Desktop

- nvme0n1
  - 1 - 500MB EFI
  - 2 - 15GB SWAP
  - 3 - 450GB ROOT
- nvme1n1
  - \* - 1TB STUFF

### Laptop

- nvme0n1
  - 1 - 500MB EFI
  - 2 - 15GB SWAP
  - 3 - 100GB ROOT
  - 4 - 100GB STUFF
  - 5 - 784.5GB GAMES

</details>

### Clone repo

- `nix-shell -p git`
- `git clone https://github.com/keifufu/nixos-config`

## Mount Partitions

- `sudo mount /dev/disk/by-label/ROOT /mnt`
- `sudo mkdir -p /mnt/boot`
- `sudo mount /dev/disk/by-label/BOOT /mnt/boot`

## Install NixOS

`sudo nixos-install --flake .#<host> --impure`

## After install

- set password
- `git clone https://github.com/keifufu/nixos-config ~/.nixos-config`
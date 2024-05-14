#!/usr/bin/env bash

if [[ $1 == "mount" ]]; then
  sudo cryptsetup luksOpen /dev/disk/by-label/$2 $2
  sudo mount /dev/mapper/$2 $3
elif [[ $1 == "umount" ]]; then
  sudo umount $3
  sudo cryptsetup luksClose $2
else
  echo "Usage: cryptutil.sh (mount|umount) <LABEL> <PATH>"
fi
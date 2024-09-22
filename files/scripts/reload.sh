#/usr/bin/env bash

# TODO: remove this temporary fix for https://github.com/Aylur/ags/issues/444
pkill -f "^wnpcli metadata -f"
pkill -f "^mpscd consume ags"
systemctl restart --user ags.service
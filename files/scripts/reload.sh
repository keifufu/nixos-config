#/usr/bin/env bash

# ags service has KillMode=process because otherwise
# it'd kill processes launched by the launcher too.
# this is hacky but it works
pkill -f "^wnpcli metadata -f"
pkill -f "^mpscd consume ags"
systemctl restart --user ags.service
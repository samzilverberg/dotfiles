#!/bin/sh
# New machine: restore app settings snapshots from macos/ (see macos/app-settings).
# after_ and numbered after 20-packages, so the apps are installed first. Apps already set up are skipped.
exec "$CHEZMOI_WORKING_TREE/macos/app-settings" import

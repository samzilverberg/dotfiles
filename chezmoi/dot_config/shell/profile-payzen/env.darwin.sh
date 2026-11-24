# payzen profile, macOS only (fish + POSIX syntax, see ../env.sh).
# GitHub token lives in the macOS keychain, not in this repo. Exception to the no-$(...) rule:
# env files load once per session (DOTFILES_ENV_LOADED), so the keychain is read once, not per shell.
#   store/update: security add-generic-password -U -a "$USER" -s GITHUB_WORKFLOW_TOKEN -w <token>
export GITHUB_WORKFLOW_TOKEN="$(security find-generic-password -w -s GITHUB_WORKFLOW_TOKEN 2>/dev/null)"

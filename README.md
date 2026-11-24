# Sam Zilverberg dotfiles

Managed with [chezmoi](https://chezmoi.io). macOS first, Linux (apt / dnf) supported for the basics.
Secrets live in 1Password, never in this (public) repo.

## New machine

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/samzilverberg/dotfiles/master/install.sh)"
```

Installs chezmoi, clones this repo to `~/dotfiles` and applies it. It asks which **profiles** the
machine gets (e.g. `payzen` on the work laptop, empty for none). The first apply stops once and asks
you to sign in to 1Password and enable **Settings → Developer → CLI integration** and **SSH agent**,
then run `chezmoi apply` again.

Headless Linux without 1Password: `DOTFILES_SKIP_1PASSWORD=1 DOTFILES_PROFILES=none` before the command.

## Layout

```
install.sh                  bootstrap one-liner target
macos/                      manual-import extras (BetterTouchTool preset)
chezmoi/                    chezmoi source dir (.chezmoiroot)
  .chezmoi.toml.tmpl        machine config: profiles, 1Password cli path, symlink mode
  .chezmoidata/
    packages.yaml           brew (base + per profile), apt, dnf package lists
    profiles.yaml           profile catalog (what each profile owns)
    onepassword_config.toml 1Password account / vault / item names (no secret values)
  .chezmoiignore            OS + profile gating
  .chezmoiscripts/          bootstrap, packages, gpg import, fisher, cleanup; darwin/ + linux/ only run there
  dot_config/shell/         shared shell layer (below)
  dot_config/fish/ ...      everything else maps 1:1 to $HOME
```

## Profiles

A profile is an extra layer on top of the base. A machine's profiles are stored in
`~/.config/chezmoi/chezmoi.toml`. Change them with `chezmoi init --prompt` or
`DOTFILES_PROFILES=payzen chezmoi init`.

A profile owns:
- `~/.config/shell/profile-<name>/`: `env.sh`, `env.<os>.sh`, `aliases.sh`, `config.fish` (fish extras),
  `bin/` (scripts on PATH). The shell loaders pick these up automatically.
- extra target paths listed in `.chezmoidata/profiles.yaml` (e.g. `~/.aws`)
- packages under `packages.profiles.<name>` in `.chezmoidata/packages.yaml`

On machines without the profile, all of it is skipped. To add a profile: add it to `profiles.yaml`,
create `chezmoi/dot_config/shell/profile-<name>/`, done.

## Shared shell layer (fish, zsh, bash, agents)

fish is the daily shell, but apps and AI agents often spawn zsh/bash. They all load `~/.config/shell`:

| file | what | loaded by |
|---|---|---|
| `env.sh`, `env.<os>.sh` | `export NAME="value"` lines only (valid fish *and* sh) | every shell, incl. non-interactive (`zsh -c`) |
| `paths`, `paths.<os>` | PATH dirs, one per line, first wins | every shell |
| `bin/` | portable scripts (kcn, klogs, ...) — work everywhere, incl. agents | on PATH |
| `aliases.sh` | `alias x='...'` lines only (valid fish *and* sh) | interactive shells |

Wiring: zsh `~/.zshenv` (+ `~/.zprofile`, `~/.zshrc`), bash `~/.bashrc`, fish `conf.d/00-shared-shell.fish`.
Shell-specific extras stay in `config.fish` / `.zshrc`. Rule of thumb: logic → a script in `bin/`.

## Secrets (1Password, personal account, vault `dotfiles`)

Nothing secret is committed. Values come from 1Password in two ways, both designed so that a normal
`chezmoi apply` **never calls 1Password** (no Touch ID prompts):

- `create_` templates: written once when the file is missing, never re-rendered.
  To refresh one: delete the target file and `chezmoi apply`.
- scripts that run `op read` at runtime only when something is missing (gpg import).

| item | used for |
|---|---|
| SSH key items | served by the 1Password SSH agent (`~/.config/1Password/ssh/agent.toml`), no private keys on disk |
| `sjctvxkxjteiffussgini63rcu` (files `gpg_all_private.asc`, `gpg_all_public.asc`, `gpg_trust_levels.txt`) | gpg import (commit signing) |
| `bettertouchtool-license` (Document) | `~/Library/Application Support/BetterTouchTool/urlimported.bttlicense` |
| `payzen-profile` (fields `aws_account_staging`, `aws_account_prod`, `aws_sso_start_url`, `cdn_bucket`, `git_email`, `git_signingkey`) | payzen profile: `~/.aws/config`, `~/.gitconfig-payzen`, `profile-payzen/env.sh` |

The GitHub workflow token (payzen) stays in the macOS keychain:
`security add-generic-password -U -a "$USER" -s GITHUB_WORKFLOW_TOKEN -w <token>`.

## Day to day

- `mode = "symlink"`: plain files in `$HOME` are symlinks into this repo, so edit them in place and commit.
  Templates, `private_`, `executable_` and `create_` files are copies: edit with `chezmoi edit <file>`
  (or edit the source and `chezmoi apply`).
- Removing a file from the repo leaves a dangling symlink; the `90-prune` script removes those on the next apply.
- Packages: edit `.chezmoidata/packages.yaml`, `chezmoi apply` (nothing is ever uninstalled automatically).
- iTerm2 reads/writes its prefs directly in `chezmoi/dot_config/iterm2-config` (never deployed).
- `chezmoi diff` excludes scripts. To re-run all scripts:
  `chezmoi state delete-bucket --bucket=entryState && chezmoi state delete-bucket --bucket=scriptState`

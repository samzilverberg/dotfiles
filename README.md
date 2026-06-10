
# Sam Zilverberg dotfiles !

## WIP chezmoi

NO NEED TO CLONE REPO, steps to start:

- install chezmoi, then
  - `chezmoi init samzilverberg --branch chezmoi -S ~/dotfiles`
  - this will init from my git repo, specific branch, and put it in dotfiles dir in home
- `chezmoi apply`

## howto new mac

NOTE: secrets are used from 1pass, so maybe will need "chezmoi apply" multiple times and in the middle login to 1pass.


- run mac general customizations via defaults and more 
- font size? can it be done via defaults? is it config per app?
- vsc + config + extensions
- twingate
  - is there config somewhere?
  - how to brew install without all the dialogs it shows?
- raycast
  - how to automate open + agree to all? maybe cli to import? or config files?
  - how to automate takeover spotlight: https://manual.raycast.com/hotkey
- syncthing
  - WIP synced files via gpg encrypting (chezmoi fn)
  - TODO check if device id was duplicated and in-use by both macs
- nodejs
  - mise use -g node@22
  - npm login (via 1pass? .npmrc?)


to clean chezmoi scripts state:

```
chezmoi state delete-bucket --bucket=entryState && chezmoi state delete-bucket --bucket=scriptState

```


## usage

```
curl -fsSL https://raw.githubusercontent.com/samzilverberg/dotfiles/master/install.sh | bash
```

## supported os

- macos
- linux arch based (manjaro)

## whats config dir?

holds shared config that all OS can use

## more?

pass encrypted secrets are in bitbucket private repo:

https://bitbucket.org/samuelz/secrets


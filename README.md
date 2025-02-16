# Scripts

Misc scripts repo

## imageBaser (Python)

Converts a bunch of images in base64 and saves them in a JSON file.

## mapTiler (Javascript)

Slices up one big image into Leaflet-compatible chunks.

## pullAll (Bash)

Switches back to main/master and pulls updates for all repositories found in
the subfolders of the `$git_home` folder.

## tmuxer (Bash)

Connects via ssh to all servers given in input using [tmux](https://github.com/tmux/tmux).

## updateDeps

Runs `yarn upgrade` in all the repos, then commits and pushes the changes.

## winFixer (Batch)

Fixes the random issues with Windows 10/11. Needs to run as administrator.

#!/usr/bin/env bash

# usage:
# ./tmux.sh server-1 server-2 ...
#
# Connects via ssh to all servers given in input using tmux.
# Requires 'tmux', forked from https://gist.github.com/dmytro/3984680

hosts=("$@")

tmux new-window "ssh ${hosts[0]}"
unset hosts[0]
for i in "${hosts[@]}"; do
  tmux split-window -h "ssh $i"
  tmux select-layout tiled >/dev/null
done
tmux select-pane -t 0
tmux set-window-option synchronize-panes on >/dev/null

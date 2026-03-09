#!/usr/bin/env bash
# ssh_label.sh — extract SSH target (user@host) from pane's child processes
# Usage: ssh_label.sh <pane_pid>
# Called from automatic-rename-format only when pane_current_command == ssh

pid=$1
target=$(ps -eo ppid=,args= 2>/dev/null \
    | awk -v ppid="$pid" '$1==ppid && $2~/^ssh$/ {print $NF; exit}')
printf "%s" "${target:-ssh}"

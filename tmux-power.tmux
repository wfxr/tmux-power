#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

tmux source-file "$SCRIPT_DIR/tmux-power.theme"

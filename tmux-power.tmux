#!/usr/bin/env bash
#===============================================================================
#   Author: Wenxuan
#    Email: wenxuangm@gmail.com
#  Created: 2018-04-05 17:37
#===============================================================================

# Batch write: accumulate set-option commands, flush at end
_tmux_set_cmds=""

# $1: option
# $2: value
tmux_set() {
    local _escaped="${2//\\/\\\\}"
    _escaped="${_escaped//\"/\\\"}"
    _tmux_set_cmds+="set-option -gq \"$1\" \"$_escaped\""$'\n'
}

# Flush all accumulated set-option commands at once (single fork)
tmux_flush() {
    [[ -z "$_tmux_set_cmds" ]] && return
    local _tmpfile
    _tmpfile="$(mktemp)"
    printf '%s' "$_tmux_set_cmds" > "$_tmpfile"
    tmux source-file "$_tmpfile"
    rm -f "$_tmpfile"
}

# Defaults
right_arrow_icon=''
left_arrow_icon=''
upload_speed_icon='󰕒'
download_speed_icon='󰇚'
session_icon=''
user_icon=''
time_icon=''
date_icon=''
show_user='true'
show_host='true'
show_session='true'
show_upload_speed='false'
show_download_speed='false'
show_web_reachable='false'
prefix_highlight_pos=''
time_format='%T'
date_format='%F'
use_bold='true'
theme='gold'
g0='#262626'
g1='#303030'
g2='#3a3a3a'
g3='#444444'
g4='#626262'
status_interval='1'

# Batch read: load user options in one shot
eval "$(tmux show -g | sed -n 's/^@tmux_power_\([^ ]*\) /\1=/p')"

# short for Theme-Colour
TC="$theme"
case $TC in
    'gold' )
        TC='#ffb86c'
        ;;
    'redwine' )
        TC='#b34a47'
        ;;
    'moon' )
        TC='#00abab'
        ;;
    'forest' )
        TC='#228b22'
        ;;
    'violet' )
        TC='#9370db'
        ;;
    'snow' )
        TC='#fffafa'
        ;;
    'coral' )
        TC='#ff7f50'
        ;;
    'sky' )
        TC='#87ceeb'
        ;;
    'everforest' )
        TC='#a7c080'
        ;;
esac

G0="$g0"
G1="$g1"
G2="$g2"
G3="$g3"
G4="$g4"

if "$use_bold"; then
    bold_prefix="bold"
    bold_postfix="nobold"
else
    bold_prefix="none"
    bold_postfix="none"
fi

# Status options
tmux_set status-interval "$status_interval"
tmux_set status on

# Basic status bar colors
tmux_set status-bg "$G0"
tmux_set status-fg "$G4"
tmux_set status-attr none

# tmux-prefix-highlight
tmux_set @prefix_highlight_show_copy_mode 'on'
tmux_set @prefix_highlight_copy_mode_attr "fg=$TC,bg=$G0,$bold_prefix"
tmux_set @prefix_highlight_output_prefix "#[fg=$TC]#[bg=$G0]$left_arrow_icon#[bg=$TC]#[fg=$G0]"
tmux_set @prefix_highlight_output_suffix "#[fg=$TC]#[bg=$G0]$right_arrow_icon"

# Left side of status bar
tmux_set status-left-bg "$G0"
tmux_set status-left-length 150

# user@host
if "$show_user" && "$show_host"; then
    LS="#[fg=$G0,bg=$TC,$bold_prefix] $user_icon $USER@#h #[fg=$TC,bg=$G2,$bold_postfix]$right_arrow_icon"
elif "$show_user"; then
    LS="#[fg=$G0,bg=$TC,$bold_prefix] $user_icon $USER #[fg=$TC,bg=$G2,$bold_postfix]$right_arrow_icon"
elif "$show_host"; then
    LS="#[fg=$G0,bg=$TC,$bold_prefix] #h #[fg=$TC,bg=$G2,$bold_postfix]$right_arrow_icon"
fi

# session
if "$show_session"; then
    LS="$LS#[fg=$TC,bg=$G2] $session_icon #S "
fi

# upload speed
if "$show_upload_speed"; then
    LS="$LS#[fg=$G2,bg=$G1]$right_arrow_icon#[fg=$TC,bg=$G1] $upload_speed_icon #{upload_speed} #[fg=$G1,bg=$G0]$right_arrow_icon"
else
    LS="$LS#[fg=$G2,bg=$G0]$right_arrow_icon"
fi
if [[ $prefix_highlight_pos == 'L' || $prefix_highlight_pos == 'LR' ]]; then
    LS="$LS#{prefix_highlight}"
fi
tmux_set status-left "$LS"

# Right side of status bar
tmux_set status-right-bg "$G0"
tmux_set status-right-length 150
RS="#[fg=$G2]$left_arrow_icon#[fg=$TC,bg=$G2] $time_icon $time_format #[fg=$TC,bg=$G2]$left_arrow_icon#[fg=$G0,bg=$TC] $date_icon $date_format "
if "$show_download_speed"; then
    RS="#[fg=$G1,bg=$G0]$left_arrow_icon#[fg=$TC,bg=$G1] $download_speed_icon #{download_speed} $RS"
fi
if "$show_web_reachable"; then
    RS=" #{web_reachable_status} $RS"
fi
if [[ $prefix_highlight_pos == 'R' || $prefix_highlight_pos == 'LR' ]]; then
    RS="#{prefix_highlight}$RS"
fi
tmux_set status-right "$RS"

# Window status format
tmux_set window-status-format         "#[fg=$G0,bg=$G2]$right_arrow_icon#[fg=$TC,bg=$G2] #I:#W#F #[fg=$G2,bg=$G0]$right_arrow_icon"
tmux_set window-status-current-format "#[fg=$G0,bg=$TC]$right_arrow_icon#[fg=$G0,bg=$TC,$bold_prefix] #I:#W#F #[fg=$TC,bg=$G0,$bold_postfix]$right_arrow_icon"

# Window status style
tmux_set window-status-style          "fg=$TC,bg=$G0,none"
tmux_set window-status-last-style     "fg=$TC,bg=$G0,$bold_prefix"
tmux_set window-status-activity-style "fg=$TC,bg=$G0,$bold_prefix"
tmux_set window-status-bell-style     "fg=$TC,bg=$G0,$bold_prefix"

# Window separator
tmux_set window-status-separator ""

# Pane border
tmux_set pane-border-style "fg=$G3,bg=default"

# Active pane border
tmux_set pane-active-border-style "fg=$TC,bg=default"

# Pane number indicator
tmux_set display-panes-colour "$G3"
tmux_set display-panes-active-colour "$TC"

# Clock mode
tmux_set clock-mode-colour "$TC"
tmux_set clock-mode-style 24

# Message
tmux_set message-style "fg=$TC,bg=$G0"

# Command message
tmux_set message-command-style "fg=$TC,bg=$G0"

# Copy mode highlight
tmux_set mode-style "bg=$TC,fg=$G4"

# Flush all options at once
tmux_flush

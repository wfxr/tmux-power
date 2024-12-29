#!/usr/bin/env bash
#===============================================================================
#   Author: Wenxuan
#    Email: wenxuangm@gmail.com
#  Created: 2018-04-05 17:37
#===============================================================================

# $1: option
# $2: default value
tmux_get() {
    local value
    value="$(tmux show -gqv "$1")"
    [ -n "$value" ] && echo "$value" || echo "$2"
}

# $1: option
# $2: value
tmux_set() {
    tmux set-option -gq "$1" "$2"
}

# Options
rarrow=$(tmux_get '@tmux_power_right_arrow_icon' '')
larrow=$(tmux_get '@tmux_power_left_arrow_icon' '')
upload_speed_icon=$(tmux_get '@tmux_power_upload_speed_icon' '󰕒')
download_speed_icon=$(tmux_get '@tmux_power_download_speed_icon' '󰇚')
session_icon="$(tmux_get '@tmux_power_session_icon' '')"
user_icon="$(tmux_get '@tmux_power_user_icon' '')"
time_icon="$(tmux_get '@tmux_power_time_icon' '')"
date_icon="$(tmux_get '@tmux_power_date_icon' '')"
show_user="$(tmux_get @tmux_power_show_user true)"
show_host="$(tmux_get @tmux_power_show_host true)"
show_session="$(tmux_get @tmux_power_show_session true)"
show_upload_speed="$(tmux_get @tmux_power_show_upload_speed false)"
show_download_speed="$(tmux_get @tmux_power_show_download_speed false)"
show_web_reachable="$(tmux_get @tmux_power_show_web_reachable false)"
prefix_highlight_pos=$(tmux_get @tmux_power_prefix_highlight_pos)
time_format=$(tmux_get @tmux_power_time_format '%T')
date_format=$(tmux_get @tmux_power_date_format '%F')

# short for Theme-Colour
TC=$(tmux_get '@tmux_power_theme' 'gold')
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

G0=$(tmux_get @tmux_power_g0 "#262626")
G1=$(tmux_get @tmux_power_g1 "#303030")
G2=$(tmux_get @tmux_power_g2 "#3a3a3a")
G3=$(tmux_get @tmux_power_g3 "#444444")
G4=$(tmux_get @tmux_power_g4 "#626262")

# Status options
tmux_set status-interval 1
tmux_set status on

# Basic status bar colors
tmux_set status-bg "$G0"
tmux_set status-fg "$G4"
tmux_set status-attr none

# tmux-prefix-highlight
tmux_set @prefix_highlight_show_copy_mode 'on'
tmux_set @prefix_highlight_copy_mode_attr "fg=$TC,bg=$G0,bold"
tmux_set @prefix_highlight_output_prefix "#[fg=$TC]#[bg=$G0]$larrow#[bg=$TC]#[fg=$G0]"
tmux_set @prefix_highlight_output_suffix "#[fg=$TC]#[bg=$G0]$rarrow"

#     
# Left side of status bar
tmux_set status-left-bg "$G0"
tmux_set status-left-length 150

# user@host
if "$show_user" && "$show_host"; then
    LS="#[fg=$G0,bg=$TC,bold] $user_icon $(whoami)@#h #[fg=$TC,bg=$G2,nobold]$rarrow"
elif "$show_user"; then
    LS="#[fg=$G0,bg=$TC,bold] $user_icon $(whoami) #[fg=$TC,bg=$G2,nobold]$rarrow"
elif "$show_host"; then
    LS="#[fg=$G0,bg=$TC,bold] #h #[fg=$TC,bg=$G2,nobold]$rarrow"
fi

# session
if "$show_session"; then
    LS="$LS#[fg=$TC,bg=$G2] $session_icon #S "
fi

# upload speed
if "$show_upload_speed"; then
    LS="$LS#[fg=$G2,bg=$G1]$rarrow#[fg=$TC,bg=$G1] $upload_speed_icon #{upload_speed} #[fg=$G1,bg=$G0]$rarrow"
else
    LS="$LS#[fg=$G2,bg=$G0]$rarrow"
fi
if [[ $prefix_highlight_pos == 'L' || $prefix_highlight_pos == 'LR' ]]; then
    LS="$LS#{prefix_highlight}"
fi
tmux_set status-left "$LS"

# Right side of status bar
tmux_set status-right-bg "$G0"
tmux_set status-right-length 150
RS="#[fg=$G2]$larrow#[fg=$TC,bg=$G2] $time_icon $time_format #[fg=$TC,bg=$G2]$larrow#[fg=$G0,bg=$TC] $date_icon $date_format "
if "$show_download_speed"; then
    RS="#[fg=$G1,bg=$G0]$larrow#[fg=$TC,bg=$G1] $download_speed_icon #{download_speed} $RS"
fi
if "$show_web_reachable"; then
    RS=" #{web_reachable_status} $RS"
fi
if [[ $prefix_highlight_pos == 'R' || $prefix_highlight_pos == 'LR' ]]; then
    RS="#{prefix_highlight}$RS"
fi
tmux_set status-right "$RS"

# Window status format
tmux_set window-status-format         "#[fg=$G0,bg=$G2]$rarrow#[fg=$TC,bg=$G2] #I:#W#F #[fg=$G2,bg=$G0]$rarrow"
tmux_set window-status-current-format "#[fg=$G0,bg=$TC]$rarrow#[fg=$G0,bg=$TC,bold] #I:#W#F #[fg=$TC,bg=$G0,nobold]$rarrow"

# Window status style
tmux_set window-status-style          "fg=$TC,bg=$G0,none"
tmux_set window-status-last-style     "fg=$TC,bg=$G0,bold"
tmux_set window-status-activity-style "fg=$TC,bg=$G0,bold"

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

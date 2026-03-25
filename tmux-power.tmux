#!/usr/bin/env bash
#===============================================================================
#   Author: Wenxuan
#    Email: wenxuangm@gmail.com
#  Created: 2018-04-05 17:37
#===============================================================================

# Defaults and user overrides

set_defaults() {
    right_arrow_icon=''
    left_arrow_icon=''
    prefix_highlight_pos=''

    # Section contents (left: outer→inner, right: inner→outer)
    left_a=' #{USER}@#h'
    left_b=' #S'
    left_c=''
    left_d=''
    right_w=''
    right_x=''
    right_y=' %T'
    right_z=' %F'

    # Section styles (spliced directly into tmux format strings)
    left_a_style='bold'
    left_b_style=''
    left_c_style=''
    left_d_style=''
    right_w_style=''
    right_x_style=''
    right_y_style=''
    right_z_style=''
    theme='gold'
    g0='#262626'
    g1='#303030'
    g2='#3a3a3a'
    g3='#444444'
    g4='#626262'
    status_interval='1'
}

# Theme resolution

resolve_theme_colors() {
    TC="$theme"
    case $TC in
        gold)       TC='#ffb86c' ;;
        redwine)    TC='#b34a47' ;;
        moon)       TC='#00abab' ;;
        forest)     TC='#228b22' ;;
        violet)     TC='#9370db' ;;
        snow)       TC='#fffafa' ;;
        coral)      TC='#ff7f50' ;;
        sky)        TC='#87ceeb' ;;
        everforest) TC='#a7c080' ;;
    esac

    G0="$g0"
    G1="$g1"
    G2="$g2"
    G3="$g3"
    G4="$g4"
}

# Status bar assembly

configure_status_bar() {
    tmux_set status-interval "$status_interval"
    tmux_set status on

    tmux_set status-bg "$G0"
    tmux_set status-fg "$G4"
    tmux_set status-attr none

    tmux_set @prefix_highlight_show_copy_mode 'on'
    tmux_set @prefix_highlight_copy_mode_attr "fg=$TC,bg=$G0,bold"
    tmux_set @prefix_highlight_output_prefix "#[fg=$TC]#[bg=$G0]$left_arrow_icon#[bg=$TC]#[fg=$G0]"
    tmux_set @prefix_highlight_output_suffix "#[fg=$TC]#[bg=$G0]$right_arrow_icon"

    tmux_set status-left-bg "$G0"
    tmux_set status-left-length 150
    tmux_set status-right-bg "$G0"
    tmux_set status-right-length 150
}

build_left_status() {
    local LS="" prev_bg="$G0" first=true
    local content bg fg style i
    local -a left_bgs=("$TC" "$G2" "$G1" "$G1")
    local -a left_fgs=("$G0" "$TC" "$TC" "$TC")
    local -a left_contents=("$left_a" "$left_b" "$left_c" "$left_d")
    local -a left_styles_arr=("$left_a_style" "$left_b_style" "$left_c_style" "$left_d_style")

    for i in "${!left_contents[@]}"; do
        content="${left_contents[$i]}"
        [[ -z "$content" ]] && continue
        bg="${left_bgs[$i]}"
        fg="${left_fgs[$i]}"
        style="${left_styles_arr[$i]:+,${left_styles_arr[$i]}}"

        if "$first"; then
            LS="#[fg=$fg,bg=$bg${style}] $content "
            first=false
        else
            LS+="#[fg=$prev_bg,bg=$bg,none]$right_arrow_icon"
            LS+="#[fg=$fg,bg=$bg${style}] $content "
        fi
        prev_bg="$bg"
    done

    [[ -n "$LS" ]] && LS+="#[fg=$prev_bg,bg=$G0,none]$right_arrow_icon"

    if [[ $prefix_highlight_pos == 'L' || $prefix_highlight_pos == 'LR' ]]; then
        LS="$LS#{prefix_highlight}"
    fi

    tmux_set status-left "$LS"
}

build_right_status() {
    local RS="" prev_bg="$G0"
    local content bg fg style i
    local -a right_bgs=("$G1" "$G1" "$G2" "$TC")
    local -a right_fgs=("$TC" "$TC" "$TC" "$G0")
    local -a right_contents=("$right_w" "$right_x" "$right_y" "$right_z")
    local -a right_styles_arr=("$right_w_style" "$right_x_style" "$right_y_style" "$right_z_style")

    for i in "${!right_contents[@]}"; do
        content="${right_contents[$i]}"
        [[ -z "$content" ]] && continue
        bg="${right_bgs[$i]}"
        fg="${right_fgs[$i]}"
        style="${right_styles_arr[$i]:+,${right_styles_arr[$i]}}"

        RS+="#[fg=$bg,bg=$prev_bg,none]$left_arrow_icon"
        RS+="#[fg=$fg,bg=$bg${style}] $content "
        prev_bg="$bg"
    done

    if [[ $prefix_highlight_pos == 'R' || $prefix_highlight_pos == 'LR' ]]; then
        RS="#{prefix_highlight}$RS"
    fi

    tmux_set status-right "$RS"
}

# Window, pane, and message styles

configure_ui_styles() {
    tmux_set window-status-format         "#[fg=$G0,bg=$G2]$right_arrow_icon#[fg=$TC,bg=$G2] #I:#W#F #[fg=$G2,bg=$G0]$right_arrow_icon"
    tmux_set window-status-current-format "#[fg=$G0,bg=$TC]$right_arrow_icon#[fg=$G0,bg=$TC,bold] #I:#W#F #[fg=$TC,bg=$G0,nobold]$right_arrow_icon"

    tmux_set window-status-style          "fg=$TC,bg=$G0,none"
    tmux_set window-status-last-style     "fg=$TC,bg=$G0,bold"
    tmux_set window-status-activity-style "fg=$TC,bg=$G0,bold"
    tmux_set window-status-bell-style     "fg=$TC,bg=$G0,bold"
    tmux_set window-status-separator ""

    tmux_set pane-border-style "fg=$G3,bg=default"
    tmux_set pane-active-border-style "fg=$TC,bg=default"

    tmux_set display-panes-colour "$G3"
    tmux_set display-panes-active-colour "$TC"

    tmux_set clock-mode-colour "$TC"
    tmux_set clock-mode-style 24

    tmux_set message-style "fg=$TC,bg=$G0"
    tmux_set message-command-style "fg=$TC,bg=$G0"
    tmux_set mode-style "bg=$TC,fg=$G4"
}

# Batch write: accumulate set-option commands, flush at end
_tmux_set_cmds=""

# $1: option
# $2: value
tmux_set() {
    local _escaped _value="$2"

    if [[ $_value == *"'"* ]]; then
        _escaped="${_value//\\/\\\\}"   # `a\b` -> `a\\b` so literal backslashes survive tmux double quotes
        _escaped="${_escaped//\$/\\\$}" # `$PWD` -> `\$PWD` so shell variables stay literal in tmux command formats
        _escaped="${_escaped//\"/\\\"}" # `"hi"` -> `\"hi\"` so embedded double quotes do not end the tmux string
        _escaped="${_escaped//\`/\\\`}" # keep backticks literal so tmux does not treat them as command substitution
        _tmux_set_cmds+="set-option -gq \"$1\" \"$_escaped\""$'\n'
    else
        _tmux_set_cmds+="set-option -gq \"$1\" '$_value'"$'\n'
    fi
}

# Flush all accumulated set-option commands at once (single fork)
tmux_flush() {
    [[ -z "$_tmux_set_cmds" ]] && return
    # tmux 3.0+ supports reading from stdin via 'source-file -'
    if ! tmux source-file - <<<"$_tmux_set_cmds" 2>/dev/null; then
        local _tmpfile
        _tmpfile="$(mktemp)"
        printf '%s' "$_tmux_set_cmds" >"$_tmpfile"
        tmux source-file "$_tmpfile"
        rm -f "$_tmpfile"
    fi
}

# Batch-read all @tmux_power_* options in one tmux call, but escape shell-active
# characters before feeding the assignments back to eval. tmux show -g serializes
# values with shell-style quoting (including single-quoted forms), so the awk
# pass only escapes $ and ` outside single quotes to preserve tmux/status-format
# literals like #{user}, #(cmd), and $(...) without giving up the PR #62 fast path.
load_tmux_options() {
    eval "$(
        tmux show -g | awk '
            BEGIN {
                sq = sprintf("%c", 39)
                dq = "\""
                bt = sprintf("%c", 96)
                bs = "\\"
            }

            /^@tmux_power_[A-Za-z_][A-Za-z0-9_]* / {
                line = $0
                sub(/^@tmux_power_/, "", line)

                key = line
                sub(/ .*/, "", key)
                sub(/^[^ ]+ /, "", line)

                rhs = line
                n = length(rhs)
                out = ""
                in_sq = 0
                in_dq = 0

                for (i = 1; i <= n; i++) {
                    ch = substr(rhs, i, 1)

                    if (in_sq) {
                        out = out ch
                        if (ch == sq)
                            in_sq = 0
                        continue
                    }

                    # tmux show -g may serialize a literal $ as \$, \\$,
                    # \\\\\\$, etc. depending on the version. Collapse any
                    # run of 1+ backslashes before $ or ` into exactly one.
                    if (ch == bs) {
                        j = i
                        while (j < n && substr(rhs, j + 1, 1) == bs)
                            j++

                        if (j < n) {
                            next_ch = substr(rhs, j + 1, 1)
                            if (next_ch == "$" || next_ch == bt) {
                                out = out bs next_ch
                                i = j + 1
                                continue
                            }
                        }
                    }

                    if (ch == bs) {
                        out = out ch
                        i++
                        if (i <= n)
                            out = out substr(rhs, i, 1)
                        continue
                    }

                    if (ch == sq && !in_dq) {
                        in_sq = 1
                        out = out ch
                        continue
                    }

                    if (ch == dq) {
                        in_dq = !in_dq
                        out = out ch
                        continue
                    }

                    if (ch == "$" || ch == bt)
                        out = out bs ch
                    else
                        out = out ch
                }

                print key "=" out
            }
        '
    )"
}

main() {
    set_defaults
    load_tmux_options
    resolve_theme_colors
    configure_status_bar
    build_left_status
    build_right_status
    configure_ui_styles
    tmux_flush
}

main "$@"

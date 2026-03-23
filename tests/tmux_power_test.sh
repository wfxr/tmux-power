#!/usr/bin/env bash
# shellcheck disable=SC2218

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMUX_POWER_SCRIPT="${TMUX_POWER_SCRIPT:-$ROOT_DIR/tmux-power.tmux}"

TESTS_RUN=0
TESTS_FAILED=0
SOCK_DIR=""
SOCK=""

cleanup() {
    if [[ -n "$SOCK" ]]; then
        tmux -S "$SOCK" kill-server >/dev/null 2>&1 || true
    fi
    if [[ -n "$SOCK_DIR" ]]; then
        rm -rf "$SOCK_DIR"
    fi
    SOCK_DIR=""
    SOCK=""
}

run_tmux() {
    tmux -S "$SOCK" "$@"
}

start_tmux() {
    cleanup
    SOCK_DIR="$(mktemp -d /tmp/tmux-power-test.XXXXXX)"
    SOCK="$SOCK_DIR/tmux.sock"
    run_tmux -f /dev/null new-session -d -s review
}

set_power_option() {
    run_tmux set -g "@tmux_power_$1" "$2"
}

load_plugin() {
    run_tmux run-shell "$TMUX_POWER_SCRIPT"
}

strip_styles() {
    sed 's/#\[[^]]*]//g'
}

normalize_ws() {
    tr '\n' ' ' | tr -s '[:space:]' ' ' | sed 's/^ //; s/ $//'
}

render_left() {
    run_tmux display-message -p '#{T:status-left}' | strip_styles | normalize_ws
}

render_left_raw() {
    run_tmux display-message -p '#{T:status-left}' | strip_styles | tr -d '\n'
}

render_right() {
    run_tmux display-message -p '#{T:status-right}' | strip_styles | normalize_ws
}

render_right_raw() {
    run_tmux display-message -p '#{T:status-right}' | strip_styles | tr -d '\n'
}

show_left() {
    run_tmux show -gv status-left
}

show_right() {
    run_tmux show -gv status-right
}

assert_eq() {
    local expected="$1"
    local actual="$2"
    local message="$3"
    if [[ "$expected" != "$actual" ]]; then
        echo "expected: $expected" >&2
        echo "actual:   $actual" >&2
        echo "$message" >&2
        return 1
    fi
}

assert_contains() {
    local needle="$1"
    local haystack="$2"
    local message="$3"
    if [[ "$haystack" != *"$needle"* ]]; then
        echo "missing:  $needle" >&2
        echo "actual:   $haystack" >&2
        echo "$message" >&2
        return 1
    fi
}

assert_not_contains() {
    local needle="$1"
    local haystack="$2"
    local message="$3"
    if [[ "$haystack" == *"$needle"* ]]; then
        echo "unexpected: $needle" >&2
        echo "actual:     $haystack" >&2
        echo "$message" >&2
        return 1
    fi
}

test_default_left_renders_user_host_and_session() {
    start_tmux
    load_plugin

    local rendered expected_user expected_host
    rendered="$(render_left)"
    expected_user="$(run_tmux display-message -p '#{user}')"
    expected_host="$(run_tmux display-message -p '#h')"

    assert_contains "$expected_user@$expected_host" "$rendered" \
        "default left section should render the tmux user/host" || return 1
    assert_contains "review" "$rendered" \
        "default left section should render the session name" || return 1

    if [[ "$rendered" == *"\$USER"* ]]; then
        echo "actual:   $rendered" >&2
        echo "default left section should not contain a literal \$USER" >&2
        return 1
    fi
}

test_default_left_status_uses_tmux_user_format() {
    start_tmux
    load_plugin

    local rendered
    rendered="$(show_left)"
    assert_contains '#{user}@#h' "$rendered" \
        "default status-left should keep tmux-native user/host format" || return 1

    if [[ "$rendered" == *"\$USER@#h"* ]]; then
        echo "actual:   $rendered" >&2
        echo "default status-left should not keep a literal \$USER token" >&2
        return 1
    fi
}

test_default_sections_preserve_icon_defaults() {
    start_tmux
    load_plugin

    local status_left status_right rendered_left rendered_right
    status_left="$(show_left)"
    status_right="$(show_right)"
    rendered_left="$(render_left)"
    rendered_right="$(render_right)"

    assert_contains ' #{user}@#h' "$status_left" \
        "default left_a should keep the upstream user icon" || return 1
    assert_contains ' #S' "$status_left" \
        "default left_b should keep the upstream session icon" || return 1
    assert_contains ' %T' "$status_right" \
        "default right_y should keep the upstream time icon" || return 1
    assert_contains ' %F' "$status_right" \
        "default right_z should keep the upstream date icon" || return 1
    assert_contains '' "$status_left" \
        "default status-left should keep the upstream right arrow icon" || return 1
    assert_contains '' "$status_right" \
        "default status-right should keep the upstream left arrow icon" || return 1
    assert_contains '' "$rendered_left" \
        "default left render should include the user icon" || return 1
    assert_contains '' "$rendered_right" \
        "default right render should include the date icon" || return 1
}

test_default_sections_do_not_double_pad_content() {
    start_tmux
    load_plugin

    local rendered_left rendered_right
    rendered_left="$(render_left_raw)"
    rendered_right="$(render_right_raw)"

    assert_not_contains '  ' "$rendered_left" \
        "default left_a should not gain an extra leading space from the renderer" || return 1
    assert_not_contains '  ' "$rendered_left" \
        "default left_b should not gain an extra leading space from the renderer" || return 1
    assert_not_contains '  ' "$rendered_right" \
        "default right_y should not gain an extra leading space from the renderer" || return 1
    assert_not_contains '  ' "$rendered_right" \
        "default right_z should not gain an extra leading space from the renderer" || return 1
}

test_left_sections_skip_empty_segments() {
    start_tmux
    set_power_option right_arrow_icon R
    set_power_option left_a 'A'
    set_power_option left_b ''
    set_power_option left_c 'C'
    set_power_option left_d 'D'
    set_power_option right_w ''
    set_power_option right_x ''
    set_power_option right_y ''
    set_power_option right_z ''
    load_plugin

    local rendered
    rendered="$(render_left)"
    assert_eq 'A R C R D R' "$rendered" \
        "left sections should skip empty segments and keep separators aligned" || return 1
}

test_right_sections_render_formats_and_strftime() {
    start_tmux
    set_power_option left_a ''
    set_power_option left_b ''
    set_power_option left_c ''
    set_power_option left_d ''
    set_power_option left_arrow_icon L
    set_power_option right_w 'W'
    set_power_option right_x ' #{user}'
    set_power_option right_y ' %Y'
    set_power_option right_z 'Z'
    load_plugin

    local rendered expected
    rendered="$(render_right)"
    expected="L W L $(run_tmux display-message -p '#{user}') L $(run_tmux display-message -p '%Y') L Z"
    assert_eq "$expected" "$rendered" \
        "right sections should render tmux formats and strftime in order" || return 1

    local left_rendered
    left_rendered="$(render_left)"
    assert_eq '' "$left_rendered" \
        "left status should stay empty when all left sections are disabled" || return 1
}

test_batch_loader_preserves_tmux_and_shell_literals() {
    start_tmux
    local tmux_command_format escaped_tmux_command_format
    local plain_command_substitution double_quoted_value single_quote_value
    local status_left status_right
    single_quote_value="contains'quote"
    set_power_option left_a "$single_quote_value"
    set_power_option left_b ''
    set_power_option left_c ''
    set_power_option left_d ''
    # shellcheck disable=SC2016 # intentional literal shell fragments
    tmux_command_format='#(printf "%s" "$PWD")'
    # shellcheck disable=SC2016 # tmux 3.4 re-serializes status-right with an escaped dollar
    escaped_tmux_command_format='#(printf "%s" "\$PWD")'
    # shellcheck disable=SC2016 # intentional literal shell fragments
    plain_command_substitution='$(printf hacked)'
    double_quoted_value='contains"quote'
    set_power_option right_w "$tmux_command_format"
    set_power_option right_x "$plain_command_substitution"
    set_power_option right_y '#{user}'
    set_power_option right_z "$double_quoted_value"
    load_plugin

    status_left="$(show_left)"
    status_right="$(show_right)"

    if [[ "$status_right" != *"$tmux_command_format"* &&
        "$status_right" != *"$escaped_tmux_command_format"* ]]; then
        echo "expected one of: $tmux_command_format" >&2
        echo "               or: $escaped_tmux_command_format" >&2
        echo "actual:           $status_right" >&2
        echo "batch option loading should preserve tmux command formats across tmux version-specific serialization" >&2
        return 1
    fi
    assert_contains "$plain_command_substitution" "$status_right" \
        "batch option loading should not evaluate plain shell command substitutions" || return 1
    assert_contains '#{user}' "$status_right" \
        "batch option loading should keep tmux-native formats intact" || return 1
    assert_contains "$double_quoted_value" "$status_right" \
        "batch option loading should preserve values that tmux serializes with single quotes" || return 1
    assert_contains "$single_quote_value" "$status_left" \
        "batched tmux writes should preserve apostrophes inside section content" || return 1
}

# Set up a fake tmux binary that serves canned show -g output and captures
# source-file writes. Sets FAKE_TMPDIR, FAKE_SHOW_OUTPUT, and FAKE_CAPTURED.
# Usage: setup_fake_tmux; cat >$FAKE_SHOW_OUTPUT <<'EOF' ... EOF; run_fake_tmux
setup_fake_tmux() {
    FAKE_TMPDIR="$(mktemp -d /tmp/tmux-power-fake.XXXXXX)"
    FAKE_SHOW_OUTPUT="$FAKE_TMPDIR/show-g.txt"
    local fakebin="$FAKE_TMPDIR/bin"
    local fake_tmux="$fakebin/tmux"

    mkdir -p "$fakebin"
    cat >"$fake_tmux" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

case "${1-} ${2-}" in
    'show -g')
        cat "$TMUX_FAKE_SHOW_G"
        ;;
    'source-file -')
        cat >"$TMUX_FAKE_CAPTURE"
        ;;
    'source-file '*)
        cat "$2" >"$TMUX_FAKE_CAPTURE"
        ;;
    *)
        echo "unexpected fake tmux args: $*" >&2
        exit 1
        ;;
esac
EOF
    chmod +x "$fake_tmux"
}

# Run tmux-power.tmux against the fake tmux and store the captured source-file
# content in FAKE_CAPTURED. Cleans up FAKE_TMPDIR on both success and failure.
run_fake_tmux() {
    local capture="$FAKE_TMPDIR/source-file.txt"
    local fakebin="$FAKE_TMPDIR/bin"

    if ! PATH="$fakebin:$PATH" TMUX_FAKE_SHOW_G="$FAKE_SHOW_OUTPUT" \
        TMUX_FAKE_CAPTURE="$capture" bash "$TMUX_POWER_SCRIPT"; then
        rm -rf "$FAKE_TMPDIR"
        return 1
    fi

    FAKE_CAPTURED="$(cat "$capture")"
    rm -rf "$FAKE_TMPDIR"
}

test_batch_writer_preserves_dollar_literals_in_source_file() {
    local expected_tmux_command escaped_tmux_command plain_command_substitution
    # shellcheck disable=SC2016 # intentional literal shell fragments
    expected_tmux_command='#(printf "%s" "$PWD")'
    # shellcheck disable=SC2016 # intentional literal shell fragments
    escaped_tmux_command='#(printf "%s" "\$PWD")'
    # shellcheck disable=SC2016 # intentional literal shell fragments
    plain_command_substitution='$(printf hacked)'

    setup_fake_tmux
    cat >"$FAKE_SHOW_OUTPUT" <<'EOF'
@tmux_power_left_a ''
@tmux_power_left_b ''
@tmux_power_left_c ''
@tmux_power_left_d ''
@tmux_power_right_w '#(printf "%s" "$PWD")'
@tmux_power_right_x '$(printf hacked)'
@tmux_power_right_y '#{user}'
@tmux_power_right_z 'contains"quote'
EOF
    run_fake_tmux || return 1

    assert_contains "$expected_tmux_command" "$FAKE_CAPTURED" \
        "batched writes should keep shell variables intact inside tmux command formats" || return 1
    assert_not_contains "$escaped_tmux_command" "$FAKE_CAPTURED" \
        "batched writes should not add a backslash before shell variables inside tmux command formats" || return 1
    assert_contains "$plain_command_substitution" "$FAKE_CAPTURED" \
        "batched writes should keep plain shell command substitutions literal" || return 1
}

test_batch_loader_normalizes_escaped_dollar_literals() {
    local expected_tmux_command expected_triply_escaped_command
    local escaped_tmux_command escaped_triply_escaped_command
    # shellcheck disable=SC2016 # intentional literal shell fragments
    expected_tmux_command='#(printf "%s" "$PWD")'
    # shellcheck disable=SC2016 # intentional literal shell fragments
    expected_triply_escaped_command='#(printf "%s" "$SHELL")'
    # shellcheck disable=SC2016 # intentional literal shell fragments
    escaped_tmux_command='#(printf "%s" "\$PWD")'
    # shellcheck disable=SC2016 # intentional literal shell fragments
    escaped_triply_escaped_command='#(printf "%s" "\$SHELL")'

    setup_fake_tmux
    cat >"$FAKE_SHOW_OUTPUT" <<'EOF'
@tmux_power_left_a ""
@tmux_power_left_b ""
@tmux_power_left_c ""
@tmux_power_left_d ""
@tmux_power_right_w "#(printf \"%s\" \"\\$PWD\")"
@tmux_power_right_x "#(printf \"%s\" \"\\\\\\$SHELL\")"
@tmux_power_right_y ""
@tmux_power_right_z ""
EOF
    run_fake_tmux || return 1

    assert_contains "$expected_tmux_command" "$FAKE_CAPTURED" \
        "loader should normalize tmux-serialized escaped dollar literals before rewriting options" || return 1
    assert_contains "$expected_triply_escaped_command" "$FAKE_CAPTURED" \
        "loader should collapse repeated tmux-serialized backslashes before shell variables" || return 1
    assert_not_contains "$escaped_tmux_command" "$FAKE_CAPTURED" \
        "loader should not preserve an extra backslash before shell variables from tmux serialization" || return 1
    assert_not_contains "$escaped_triply_escaped_command" "$FAKE_CAPTURED" \
        "loader should not leave a literal backslash before shell variables after repeated escaping" || return 1
}

test_section_styles_apply_per_section() {
    start_tmux
    set_power_option left_a 'A'
    set_power_option left_a_style 'italics'
    set_power_option left_b 'B'
    set_power_option left_b_style 'underscore'
    set_power_option left_c ''
    set_power_option left_c_style 'blink'
    set_power_option left_d ''
    set_power_option right_w 'W'
    set_power_option right_w_style 'dim'
    set_power_option right_x ''
    set_power_option right_x_style 'blink'
    set_power_option right_y ''
    set_power_option right_z 'Z'
    set_power_option right_z_style 'bold'
    load_plugin

    local status_left status_right
    status_left="$(show_left)"
    status_right="$(show_right)"

    assert_contains ',italics] A ' "$status_left" \
        "left_a_style should be applied to the left_a section" || return 1
    assert_contains ',underscore] B ' "$status_left" \
        "left_b_style should be applied to the left_b section" || return 1
    assert_not_contains 'blink' "$status_left" \
        "empty left sections should not leak their style attributes" || return 1
    assert_contains ',dim] W ' "$status_right" \
        "right_w_style should be applied to the right_w section" || return 1
    assert_contains ',bold] Z ' "$status_right" \
        "right_z_style should be applied to the right_z section" || return 1
    assert_not_contains 'blink' "$status_right" \
        "empty right sections should not leak their style attributes" || return 1
}

test_prefix_highlight_position_variants() {
    local pos status_left status_right
    for pos in '' 'L' 'R' 'LR'; do
        start_tmux
        set_power_option prefix_highlight_pos "$pos"
        set_power_option left_a 'A'
        set_power_option left_b ''
        set_power_option left_c ''
        set_power_option left_d ''
        set_power_option right_w ''
        set_power_option right_x ''
        set_power_option right_y ''
        set_power_option right_z 'Z'
        load_plugin

        status_left="$(show_left)"
        status_right="$(show_right)"

        case "$pos" in
            '')
                assert_not_contains '#{prefix_highlight}' "$status_left" \
                    "empty prefix_highlight_pos should not modify status-left" || return 1
                assert_not_contains '#{prefix_highlight}' "$status_right" \
                    "empty prefix_highlight_pos should not modify status-right" || return 1
                ;;
            'L')
                assert_contains '#{prefix_highlight}' "$status_left" \
                    "prefix_highlight_pos=L should append the placeholder to status-left" || return 1
                assert_not_contains '#{prefix_highlight}' "$status_right" \
                    "prefix_highlight_pos=L should not modify status-right" || return 1
                ;;
            'R')
                assert_not_contains '#{prefix_highlight}' "$status_left" \
                    "prefix_highlight_pos=R should not modify status-left" || return 1
                assert_contains '#{prefix_highlight}' "$status_right" \
                    "prefix_highlight_pos=R should prepend the placeholder to status-right" || return 1
                ;;
            'LR')
                assert_contains '#{prefix_highlight}' "$status_left" \
                    "prefix_highlight_pos=LR should append the placeholder to status-left" || return 1
                assert_contains '#{prefix_highlight}' "$status_right" \
                    "prefix_highlight_pos=LR should prepend the placeholder to status-right" || return 1
                ;;
        esac
    done
}

test_use_bold_option_is_ignored() {
    start_tmux
    set_power_option use_bold false
    set_power_option left_b ''
    set_power_option left_c ''
    set_power_option left_d ''
    set_power_option right_w ''
    set_power_option right_x ''
    set_power_option right_y ''
    set_power_option right_z ''
    load_plugin

    local status_left window_current window_last prefix_copy
    status_left="$(show_left)"
    window_current="$(run_tmux show -gv window-status-current-format)"
    window_last="$(run_tmux show -gv window-status-last-style)"
    prefix_copy="$(run_tmux show -gv @prefix_highlight_copy_mode_attr)"

    assert_contains ',bold]' "$status_left" \
        "deprecated use_bold should not disable the default left-section bold style" || return 1
    assert_contains ',bold]' "$window_current" \
        "deprecated use_bold should not disable the current-window bold style" || return 1
    assert_contains ',bold' "$window_last" \
        "deprecated use_bold should not disable the last-window bold style" || return 1
    assert_contains ',bold' "$prefix_copy" \
        "deprecated use_bold should not disable the prefix-highlight bold style" || return 1
}

run_test() {
    local name="$1"
    TESTS_RUN=$((TESTS_RUN + 1))

    if "$name"; then
        echo "ok - $name"
    else
        echo "not ok - $name" >&2
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi

    cleanup
}

main() {
    trap cleanup EXIT

    run_test test_default_left_status_uses_tmux_user_format
    run_test test_default_left_renders_user_host_and_session
    run_test test_default_sections_preserve_icon_defaults
    run_test test_default_sections_do_not_double_pad_content
    run_test test_left_sections_skip_empty_segments
    run_test test_right_sections_render_formats_and_strftime
    run_test test_batch_writer_preserves_dollar_literals_in_source_file
    run_test test_batch_loader_normalizes_escaped_dollar_literals
    run_test test_batch_loader_preserves_tmux_and_shell_literals
    run_test test_section_styles_apply_per_section
    run_test test_prefix_highlight_position_variants
    run_test test_use_bold_option_is_ignored

    if (( TESTS_FAILED > 0 )); then
        echo "$TESTS_FAILED of $TESTS_RUN tests failed" >&2
        exit 1
    fi

    echo "$TESTS_RUN tests passed"
}

main "$@"

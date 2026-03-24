# Tmux Power

Yet another powerline theme for tmux.

[![TPM](https://img.shields.io/badge/tpm--support-true-blue)](https://github.com/tmux-plugins/tpm)
[![Awesome](https://img.shields.io/badge/Awesome-tmux-d07cd0?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAABVklEQVRIS+3VvWpVURDF8d9CRAJapBAfwWCt+FEJthIUUcEm2NgIYiOxsrCwULCwktjYKSgYLfQF1JjCNvoMNhYRCwOO7HAiVw055yoBizvN3nBmrf8+M7PZsc2RbfY3AfRWeNMSVdUlHEzS1t6oqvt4n+TB78l/AKpqHrdwLcndXndU1WXcw50k10c1PwFV1fa3cQVzSR4PMd/IqaoLeIj2N1eTfG/f1gFVtQMLOI+zSV6NYz4COYFneIGLSdZSVbvwCMdxMsnbvzEfgRzCSyzjXAO8xlHcxMq/mI9oD+AGlhqgxjD93OVOD9TUuICdXd++/VeAVewecKKv2NPlfcHUAM1qK9FTnBmQvJjkdDfWzzE7QPOkAfZiEce2ECzhVJJPHWAfGuTwFpo365pO0NYjmEFr5Eas4SPeJfll2rqb38Z7/yaaD+0eNM3kPejt86REvSX6AamgdXkgoxLxAAAAAElFTkSuQmCC)](https://github.com/rothgar/awesome-tmux)
[![License](https://img.shields.io/badge/License-MIT-brightgreen.svg)](https://wfxr.mit-license.org/2017)

![screenshot](https://raw.githubusercontent.com/wfxr/i/master/tmux-power-custom.png)

### ✨ Features

- **Powerline aesthetic** — arrow separators with smooth gradient color transitions
- **9 built-in themes** — or define your own colors
- **Fully configurable sections** — 8 status segments that accept any tmux format string
  - [lualine](https://github.com/nvim-lualine/lualine.nvim)-inspired flexible configuration model
  - Per-section style control (bold, italics, etc.)
  - Empty sections are automatically skipped with correct arrow transitions
- **Fast** — theme loads in a single batch, minimal impact on tmux startup time
- **Plugin ecosystem** — works with [tmux-net-speed](https://github.com/wfxr/tmux-net-speed), [tmux-prefix-highlight](https://github.com/tmux-plugins/tmux-prefix-highlight), [tmux-web-reachable](https://github.com/wfxr/tmux-web-reachable), and more

### 📥 Installation

**Install manually**

Clone the repo somewhere and source it in `.tmux.conf`:

```tmux
run-shell "/path/to/tmux-power.tmux"
```

*NOTE: Options should be set before sourcing.*

**Install using [TPM](https://github.com/tmux-plugins/tpm)**

```tmux
set -g @plugin 'wfxr/tmux-power'
```

### 🎨 Themes

#### Gold (default)
```bash
set -g @tmux_power_theme 'gold'
```
![screenshot](https://raw.githubusercontent.com/wfxr/i/master/tmux-power-gold.png)

#### Everforest
```bash
set -g @tmux_power_theme 'everforest'
```
![screenshot](https://raw.githubusercontent.com/wfxr/i/master/tmux-power-everforest.png)

#### Moon
```bash
set -g @tmux_power_theme 'moon'
```
![screenshot](https://raw.githubusercontent.com/wfxr/i/master/tmux-power-moon.png)

#### Coral
```bash
set -g @tmux_power_theme 'coral'
```
![screenshot](https://raw.githubusercontent.com/wfxr/i/master/tmux-power-coral.png)

#### Snow
```bash
set -g @tmux_power_theme 'snow'
```

#### Forest
```bash
set -g @tmux_power_theme 'forest'
```

#### Violet
```bash
set -g @tmux_power_theme 'violet'
```

#### Redwine
```bash
set -g @tmux_power_theme 'redwine'
```
#### Sky
```bash
set -g @tmux_power_theme 'sky'
```

### ⚙  Customizing

> **Upgrading from v1?** The section-based model replaces the old `show_*` / `*_icon` / `use_bold` options.
> See the [migration guide](https://github.com/wfxr/tmux-power/pull/66#issuecomment-4108589864) for a complete mapping from old options to new ones.

#### Sections

The status bar is composed of configurable sections. Left sections go from outer to inner (`a` → `d`),
right sections go from inner to outer (`w` → `z`). Empty sections are automatically skipped with
correct arrow transitions. Section contents use tmux status formats, so values like `#{user}`, `#h`,
`#S`, and `%T` are expanded by tmux at render time.

```text
+---+---+---+---+--------------------------------------+---+---+---+---+
| A | B | C | D |           ...windows...              | W | X | Y | Z |
+---+---+---+---+--------------------------------------+---+---+---+---+
```

The defaults are:

```tmux
set -g @tmux_power_right_arrow_icon ''
set -g @tmux_power_left_arrow_icon  ''
set -g @tmux_power_left_a  ' #{user}@#h'  # user@host
set -g @tmux_power_left_b  ' #S'          # session name
set -g @tmux_power_left_c  ''
set -g @tmux_power_left_d  ''
set -g @tmux_power_right_w ''
set -g @tmux_power_right_x ''
set -g @tmux_power_right_y ' %T'         # time
set -g @tmux_power_right_z ' %F'         # date
```

Each section can also have a style (e.g. `bold`, `italics`), applied via a `_style` suffix:

```tmux
set -g @tmux_power_left_a_style  'bold'  # default
set -g @tmux_power_right_z_style 'bold'
```

As an example, the following configurations can generate the theme shown in the first screenshot:

```tmux
set -g @plugin 'wfxr/tmux-power'
set -g @plugin 'wfxr/tmux-net-speed'
set -g @tmux_power_theme 'everforest'
set -g @tmux_power_right_arrow_icon ''
set -g @tmux_power_left_arrow_icon  ''
set -g @tmux_power_left_a  '#{user}@#h'
set -g @tmux_power_left_b  '#S'
set -g @tmux_power_left_c  '󰕒 #{upload_speed}'
set -g @tmux_power_right_x '󰇚 #{download_speed}'
set -g @tmux_power_right_y '%T'
set -g @tmux_power_right_z '%F'
```

#### Theme colors

You can define your favourite colors if you don't like any of above.

```tmux
# You can set it to a true color in '#RRGGBB' format
set -g @tmux_power_theme '#483D8B' # dark slate blue

# Or you can set it to 'colorX' which honors your terminal colorscheme
set -g @tmux_power_theme 'colour3'

# The following colors are used as gradient colors
set -g @tmux_power_g0 "#262626"
set -g @tmux_power_g1 "#303030"
set -g @tmux_power_g2 "#3a3a3a"
set -g @tmux_power_g3 "#444444"
set -g @tmux_power_g4 "#626262"
```

#### Shell command integration

Section contents support tmux's `#(cmd)` syntax, so you can embed the output of any shell command.
For example, to show weather in the status bar:

```tmux
set -g @tmux_power_right_w '#(curl -s "wttr.in?format=1" | sed -e "s/+//" -e "s/ \+/ /")'
```

#### Other options

```tmux
set -g @tmux_power_status_interval 1  # status bar refresh interval in seconds
```

*The default arrows/icons and examples that include icon glyphs use characters from [nerd-fonts](https://github.com/ryanoasis/nerd-fonts).*

### 📦 Plugin support

Any tmux plugin that exposes `#{...}` format tokens can be placed in a section.

**[tmux-net-speed](https://github.com/wfxr/tmux-net-speed)**

```tmux
set -g @tmux_power_left_c  '󰕒 #{upload_speed}'
set -g @tmux_power_right_x '󰇚 #{download_speed}'
```

**[tmux-prefix-highlight](https://github.com/tmux-plugins/tmux-prefix-highlight)**

```tmux
# 'L' for left only, 'R' for right only and 'LR' for both
set -g @tmux_power_prefix_highlight_pos 'LR'
```

**[tmux-mem-cpu-load](https://github.com/thewtex/tmux-mem-cpu-load)**

```tmux
set -g @tmux_power_right_w '#(tmux-mem-cpu-load)'
```

### 🔗 Other plugins

You might also find these useful:

- [tmux-fzf-url](https://github.com/wfxr/tmux-fzf-url)
- [tmux-net-speed](https://github.com/wfxr/tmux-net-speed)

### 📃 License

[MIT](https://wfxr.mit-license.org/2017) (c) Wenxuan Zhang

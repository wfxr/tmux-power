# Tmux Powerline Theme

[![License](https://img.shields.io/badge/tpm--support-true-blue)](https://github.com/tmux-plugins/tpm)
![Platform](https://img.shields.io/badge/Platform-OSX%20|%20Linux%20|%20Windows-orange.svg)
[![License](https://img.shields.io/badge/License-MIT-brightgreen.svg)](https://wfxr.mit-license.org/2017)

Yet another powerline theme for tmux.

### 📥 Installation

**Install manually**

```bash
git clone https://github.com/wfxr/tmux-power.git ~/.tmux-power
echo 'source-file "${HOME}/.tmux-power/tmux-power.tmux' >> ~/.tmux.conf
```

**Install using [TPM](https://github.com/tmux-plugins/tpm)**

```tmux
set -g @plugin 'wfxr/tmux-power'
```

### 🎨 Themes

**Gold**(default): `set -g @tmux_power_theme 'gold'`
![screenshot](https://raw.githubusercontent.com/wfxr/i/master/tmux-power-gold.png)

**Redwine**: `set -g @tmux_power_theme 'redwine'`
![screenshot](https://raw.githubusercontent.com/wfxr/i/master/tmux-power-redwine.png)

**Moon**: `set -g @tmux_power_theme 'moon'`
![screenshot](https://raw.githubusercontent.com/wfxr/i/master/tmux-power-moon.png)

**Forest**: `set -g @tmux_power_theme 'forest'`
![screenshot](https://raw.githubusercontent.com/wfxr/i/master/tmux-power-forest.png)

**Violet**: `set -g @tmux_power_theme 'violet'`
![screenshot](https://raw.githubusercontent.com/wfxr/i/master/tmux-power-violet.png)

**Snow**: `set -g @tmux_power_theme 'snow'`
![screenshot](https://raw.githubusercontent.com/wfxr/i/master/tmux-power-snow.png)

**Coral**: `set -g @tmux_power_theme 'coral'`
![screenshot](https://raw.githubusercontent.com/wfxr/i/master/tmux-power-coral.png)

**Sky**: `set -g @tmux_power_theme 'sky'`
![screenshot](https://raw.githubusercontent.com/wfxr/i/master/tmux-power-sky.png)

### Customizing

You can define your favourite main color if you don't like any of above.

```tmux
# dark slate blue
set -g @tmux_power_theme '#483D8B'
```

### 📃 License

[MIT](https://wfxr.mit-license.org/2017) (c) Wenxuan Zhang

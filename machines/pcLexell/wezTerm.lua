local act = wezterm.action
local wezterm = require 'wezterm'
return {
  scrollback_lines = 65000,
  font_size = 15,
  hide_tab_bar_if_only_one_tab = true,
  font = wezterm.font_with_fallback {
    "FiraCode Nerd Font Mono",
    "DejaVu Sans Mono",
    "Noto Color Emoji",
  },
  window_close_confirmation = 'NeverPrompt',
  -- color_scheme = "stylix",
  color_scheme = "custom",
  -- https://wezfurlong.org/wezterm/config/default-keys.html
  keys = {
    {
      key = 'K',
      mods = 'CTRL|SHIFT',
      action = act.Multiple {
        act.ClearScrollback 'ScrollbackAndViewport',
        act.SendKey { key = 'L', mods = 'CTRL' },
      },
    },
    { key = 'PageUp', mods = 'SHIFT', action = act.ScrollByPage(-0.5) },
    { key = 'PageDown', mods = 'SHIFT', action = act.ScrollByPage(0.5) },
    --
    { key = '=', mods = 'CTRL', action = act.SendKey { key = '=', mods = 'CTRL' }, },
    { key = '-', mods = 'CTRL', action = act.SendKey { key = '-', mods = 'CTRL' }, },
    { key = '=', mods = 'SUPER', action = act.SendKey { key = '=', mods = 'SUPER' }, },
    { key = '-', mods = 'SUPER', action = act.SendKey { key = '-', mods = 'SUPER' }, },
    --
    { key = 'PageUp', mods = 'CTRL', action = act.SendKey { key = 'PageUp', mods = 'CTRL' }, },
    { key = 'PageDown', mods = 'CTRL', action = act.SendKey { key = 'PageDown', mods = 'CTRL' }, },
  },
}

-- A slightly altered version of catppucchin mocha
local mocha = {
  rosewater = '#f5e0dc',
  flamingo = '#f2cdcd',
  pink = '#f5c2e7',
  mauve = '#cba6f7',
  red = '#f38ba8',
  maroon = '#eba0ac',
  peach = '#f6a97f',
  yellow = '#f9e2af',
  green = '#a6e3a1',
  teal = '#94e2d5',
  sky = '#89dceb',
  sapphire = '#74c7ec',
  blue = '#89b4fa',
  lavender = '#b4befe',
  text = '#cdd6f4',
  subtext1 = '#bac2de',
  subtext0 = '#a6adc8',
  overlay2 = '#9399b2',
  overlay1 = '#7f849c',
  overlay0 = '#6c7086',
  surface2 = '#585b70',
  surface1 = '#45475a',
  surface0 = '#313244',
  base = '#1f1f28',
  mantle = '#181825',
  crust = '#11111b',
}

local color_utils = {
  mocha = mocha,
  transparent = 'rgba(0,0,0,0)',
  tab_bar = {
    session_tab = {
      leader = mocha.red,
      left_bg_color = mocha.green,
      left_fg_color = mocha.surface0,
      right_bg_color = mocha.surface0,
      right_fg_color = mocha.subtext1,
    },
    active_tab = {
      left_bg_color = mocha.base,
      left_fg_color = mocha.subtext1,
      right_bg_color = mocha.peach,
      right_fg_color = mocha.surface0,
    },
    inactive_tab = {
      left_bg_color = mocha.surface0,
      left_fg_color = mocha.subtext1,
      right_bg_color = mocha.blue,
      right_fg_color = mocha.surface0,
    },
    inactive_tab_hover = {
      left_bg_color = mocha.surface0,
      left_fg_color = mocha.subtext1,
      right_bg_color = mocha.rosewater,
      right_fg_color = mocha.surface0,
    },
    component = {
      left_bg_color = { mocha.blue, mocha.yellow, mocha.mauve, mocha.teal, mocha.green, mocha.peach },
      left_fg_color = mocha.surface0,
      right_bg_color = mocha.surface0,
      right_fg_color = mocha.subtext1,
    },
    notification = mocha.red,
  },
}

local colorscheme = {
  foreground = mocha.text,
  background = mocha.surface0,
  cursor_bg = mocha.rosewater,
  cursor_border = mocha.rosewater,
  cursor_fg = mocha.crust,
  selection_bg = mocha.surface2,
  selection_fg = mocha.text,
  ansi = {
    mocha.crust, --'#0C0C0C', -- black
    mocha.red, --'#C50F1F', -- red
    mocha.green, --'#13A10E', -- green
    mocha.yellow, --'#C19C00', -- yellow
    mocha.blue, -- #0037DA', -- blue
    mocha.mauve, --'#881798', -- magenta/purple
    mocha.sapphire, --'#3A96DD', -- cyan
    '#CCCCCC', -- white
  },
  brights = {
    '#767676', -- black
    '#E74856', -- red
    '#16C60C', -- green
    '#F9F1A5', -- yellow
    '#3B78FF', -- blue
    '#B4009E', -- magenta/purple
    '#61D6D6', -- cyan
    '#F2F2F2', -- white
  },
  tab_bar = {
    background = 'rgba(0, 0, 0, 0)',
    active_tab = {
      bg_color = mocha.surface0,
      fg_color = mocha.subtext1,
    },
    inactive_tab = {
      bg_color = mocha.surface0,
      fg_color = mocha.subtext1,
    },
    inactive_tab_hover = {
      bg_color = mocha.surface0,
      fg_color = mocha.subtext1,
    },
    new_tab = {
      bg_color = mocha.base,
      fg_color = mocha.text,
    },
    new_tab_hover = {
      bg_color = mocha.mantle,
      fg_color = mocha.text,
      italic = true,
    },
  },
  visual_bell = mocha.surface0,
  indexed = {
    [16] = mocha.peach,
    [17] = mocha.rosewater,
    [18] = mocha.green,
  },
  scrollbar_thumb = mocha.surface2,
  split = mocha.overlay0,
  compose_cursor = mocha.flamingo, -- nightbuild only
}

return { colorscheme = colorscheme, utils = color_utils }

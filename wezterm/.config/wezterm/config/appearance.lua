local wezterm = require('wezterm')
local gpu_adapters = require('utils.gpu_adapter')
local my_colors = require('colors.custom')

return {
  animation_fps = 30,
  max_fps = 30,
  front_end = 'WebGpu',
  webgpu_power_preference = 'HighPerformance',
  webgpu_preferred_adapter = gpu_adapters:pick_best(),

  -- background
  background = {
    {
      source = { File = wezterm.GLOBAL.background },
      horizontal_align = 'Center',
    },
    {
      source = { Color = my_colors.colorscheme.background },
      height = '100%',
      width = '100%',
      opacity = 0.93,
    },
  },

  -- scrollbar
  enable_scroll_bar = true,

  -- tab bar
  enable_tab_bar = true,
  hide_tab_bar_if_only_one_tab = false,
  use_fancy_tab_bar = false,
  tab_max_width = 25,
  show_tab_index_in_tab_bar = true,
  switch_to_last_active_tab_when_closing_tab = true,

  -- window_background_opacity = 0.3,
  macos_window_background_blur = 20,

  -- window
  window_padding = {
    left = 5,
    right = 10,
    top = 12,
    bottom = 7,
  },
  warn_about_missing_glyphs = false,
  window_close_confirmation = 'NeverPrompt',
  window_frame = {
    active_titlebar_bg = my_colors.utils.transparent,
    -- font = fonts.font,
    -- font_size = fonts.font_size,
    border_left_width = '0.5cell',
    border_right_width = '0.5cell',
    border_bottom_height = '0.25cell',
    border_top_height = '0.25cell',
  },
  inactive_pane_hsb = {
    saturation = 0.9,
    brightness = 0.65,
  },
  colors = my_colors.colorscheme,
  -- color_scheme = 'Catppuccin Mocha',
}

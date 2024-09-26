local wezterm = require('wezterm')
local umath = require('utils.math')
local ccolors = require('colors.custom')

local nf = wezterm.nerdfonts
local M = {}

local GLYPH_SEMI_CIRCLE_LEFT = nf.ple_left_half_circle_thick --[[ '' ]]
local GLYPH_SEMI_CIRCLE_RIGHT = nf.ple_right_half_circle_thick --[[ '' ]]

local discharging_icons = {
  nf.md_battery_10,
  nf.md_battery_20,
  nf.md_battery_30,
  nf.md_battery_40,
  nf.md_battery_50,
  nf.md_battery_60,
  nf.md_battery_70,
  nf.md_battery_80,
  nf.md_battery_90,
  nf.md_battery,
}
local charging_icons = {
  nf.md_battery_charging_10,
  nf.md_battery_charging_20,
  nf.md_battery_charging_30,
  nf.md_battery_charging_40,
  nf.md_battery_charging_50,
  nf.md_battery_charging_60,
  nf.md_battery_charging_70,
  nf.md_battery_charging_80,
  nf.md_battery_charging_90,
  nf.md_battery_charging,
}

local colors = {
  date_fg = '#fab387',
  battery_fg = '#f9e2af',
  separator_fg = '#74c7ec',
}

local __cells__ = {} -- wezterm FormatItems (ref: https://wezfurlong.org/wezterm/config/lua/wezterm/format.html)

---@param text string
---@param fg string
---@param bg string
local _push = function(text, fg, bg)
  table.insert(__cells__, { Foreground = { Color = fg } })
  table.insert(__cells__, { Background = { Color = bg } })
  table.insert(__cells__, { Attribute = { Intensity = 'Bold' } })
  table.insert(__cells__, { Text = text })
end

local _create_component = function(icon, text, bg)
  _push(GLYPH_SEMI_CIRCLE_LEFT, bg, ccolors.utils.transparent)
  _push(icon, ccolors.utils.transparent, bg)
  _push(' ', ccolors.utils.transparent, bg)
  _push(text, ccolors.utils.tab_bar.component.right_fg_color, ccolors.utils.tab_bar.component.right_bg_color)
  _push(GLYPH_SEMI_CIRCLE_RIGHT, ccolors.utils.tab_bar.component.right_bg_color, ccolors.utils.transparent)
end

local _set_date = function()
  local date = wezterm.strftime(' %a %H:%M:%S')
  _create_component(nf.fa_calendar, date, ccolors.utils.tab_bar.component.left_bg_color[1])
end

local _set_battery = function()
  -- ref: https://wezfurlong.org/wezterm/config/lua/wezterm/battery_info.html

  local charge = ''
  local icon = ''

  for _, b in ipairs(wezterm.battery_info()) do
    local idx = umath.clamp(umath.round(b.state_of_charge * 10), 1, 10)
    charge = string.format(' %.0f%%', b.state_of_charge * 100)

    if b.state == 'Charging' then
      icon = charging_icons[idx]
    else
      icon = discharging_icons[idx]
    end
  end

  _create_component(icon, charge, ccolors.utils.tab_bar.component.left_bg_color[2])
end

M.setup = function()
  wezterm.on('update-right-status', function(window, _pane)
    __cells__ = {}
    -- hack to make the empty tab bar transparent
    _push(
      '                                                                                                                                  ',
      colors.separator_fg,
      ccolors.utils.transparent
    )
    -- set modules
    _set_date()
    _push(' ', colors.separator_fg, ccolors.utils.transparent)
    _set_battery()
    _push(' ', ccolors.utils.transparent, ccolors.utils.transparent)

    window:set_right_status(wezterm.format(__cells__))
  end)
end

return M

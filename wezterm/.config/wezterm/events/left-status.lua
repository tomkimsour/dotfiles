local wezterm = require('wezterm')
local colors = require('colors.custom')

local mux = wezterm.mux
local nf = wezterm.nerdfonts
local M = {}

local GLYPH_SEMI_CIRCLE_LEFT = nf.ple_left_half_circle_thick --[[ '' ]]
local GLYPH_SEMI_CIRCLE_RIGHT = nf.ple_right_half_circle_thick --[[ '' ]]
local GLYPH_KEY_TABLE = nf.md_table_key --[[ '󱏅' ]]
local GLYPH_SESSION = nf.dev_terminal --[['']]

local __cells__ = {}

---@param text string
---@param fg string
---@param bg string
local _push = function(text, fg, bg)
  table.insert(__cells__, { Foreground = { Color = fg } })
  table.insert(__cells__, { Background = { Color = bg } })
  table.insert(__cells__, { Attribute = { Intensity = 'Bold' } })
  table.insert(__cells__, { Text = text })
end

M.setup = function()
  wezterm.on('update-right-status', function(window, _pane)
    __cells__ = {}

    local session = mux.get_active_workspace()

    _push(' ','rgba(0,0,0,0)','rgba(0,0,0,0)')
    if window:leader_is_active() then
      _push(GLYPH_SEMI_CIRCLE_LEFT, colors.indexed[16], 'rgba(0,0,0,0)')
      _push(GLYPH_SESSION, colors.tab_bar.inactive_tab.bg_color,colors.indexed[16] )
      _push(' ', 'rgba(0,0,0,0)',colors.indexed[16] )
    else
      _push(GLYPH_SEMI_CIRCLE_LEFT, colors.indexed[18], 'rgba(0,0,0,0)')
      _push(GLYPH_SESSION, colors.tab_bar.inactive_tab.bg_color,colors.indexed[18] )
      _push(' ', 'rgba(0,0,0,0)',colors.indexed[18] )
    end
    _push(' ' .. session .. ' ', colors.tab_bar.inactive_tab.fg_color, colors.tab_bar.inactive_tab.bg_color)
    _push(GLYPH_SEMI_CIRCLE_RIGHT,  colors.tab_bar.inactive_tab.bg_color,'rgba(0,0,0,0)')

    local name = window:active_key_table()
    if name then
      _push(GLYPH_SEMI_CIRCLE_LEFT,colors.indexed[18], 'rgba(0,0,0,0)')
      _push(GLYPH_KEY_TABLE, colors.foreground, colors.background)
      _push(' ' .. string.upper(name), colors.foreground, colors.background)
      _push(GLYPH_SEMI_CIRCLE_RIGHT, colors.indexed[18], 'rgba(0,0,0,0)')
    end
    _push(' ','rgba(0,0,0,0)','rgba(0,0,0,0)')

    window:set_left_status(wezterm.format(__cells__))
  end)
end

return M

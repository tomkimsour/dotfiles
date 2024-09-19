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

    -- Colored left side
    _push(' ',colors.transparent,colors.transparent)
    if window:leader_is_active() then
      _push(GLYPH_SEMI_CIRCLE_LEFT, colors.tab_bar.session_tab.leader, colors.transparent)
      _push(GLYPH_SESSION, colors.tab_bar.session_tab.right_fg_color,colors.tab_bar.session_tab.leader )
      _push(' ', colors.transparent,colors.tab_bar.session_tab.leader )
    else
      _push(GLYPH_SEMI_CIRCLE_LEFT, colors.indexed[18], colors.transparent)
      _push(GLYPH_SESSION, colors.tab_bar.inactive_tab.bg_color,colors.indexed[18] )
      _push(' ', colors.transparent,colors.indexed[18] )
    end
    -- Uncolored right side
    _push(' ' .. session .. ' ', colors.tab_bar.inactive_tab.fg_color, colors.tab_bar.inactive_tab.bg_color)
    _push(GLYPH_SEMI_CIRCLE_RIGHT,  colors.tab_bar.inactive_tab.bg_color,colors.transparent)

    local name = window:active_key_table()
    if name then
      _push(GLYPH_SEMI_CIRCLE_LEFT,colors.indexed[18], colors.transparent)
      _push(GLYPH_KEY_TABLE, colors.tab_bar.inactive_tab.fg_color, colors.tab_bar.inactive_tab.bg_color)
      _push(' ' .. string.upper(name), colors.tab_bar.inactive_tab.fg_color, colors.tab_bar.inactive_tab.bg_color)
      _push(GLYPH_SEMI_CIRCLE_RIGHT, colors.indexed[18], colors.transparent)
    end
    _push(' ',colors.transparent,colors.transparent)

    window:set_left_status(wezterm.format(__cells__))
  end)
end

return M

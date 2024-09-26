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
    _push(' ', colors.utils.transparent, colors.utils.transparent)
    if window:leader_is_active() then
      _push(GLYPH_SEMI_CIRCLE_LEFT, colors.utils.tab_bar.session_tab.leader, colors.utils.transparent)
      _push(GLYPH_SESSION, colors.utils.tab_bar.session_tab.left_fg_color, colors.utils.tab_bar.session_tab.leader)
      _push(' ', colors.utils.transparent, colors.utils.tab_bar.session_tab.leader)
    else
      _push(GLYPH_SEMI_CIRCLE_LEFT, colors.utils.tab_bar.session_tab.left_bg_color, colors.utils.transparent)
      _push(
        GLYPH_SESSION,
        colors.utils.tab_bar.session_tab.left_fg_color,
        colors.utils.tab_bar.session_tab.left_bg_color
      )
      _push(' ', colors.utils.transparent, colors.utils.tab_bar.session_tab.left_bg_color)
    end
    -- Uncolored right side
    _push(
      ' ' .. session .. ' ',
      colors.utils.tab_bar.session_tab.right_fg_color,
      colors.utils.tab_bar.session_tab.right_bg_color
    )
    _push(GLYPH_SEMI_CIRCLE_RIGHT, colors.utils.tab_bar.session_tab.right_bg_color, colors.utils.transparent)

    local name = window:active_key_table()
    if name then
      _push(GLYPH_SEMI_CIRCLE_LEFT, colors.indexed[18], colors.utils.transparent)
      _push(GLYPH_KEY_TABLE, colors.utils.tab_bar.session_tab.fg_color, colors.utils.tab_bar.session_tab.bg_color)
      _push(
        ' ' .. string.upper(name),
        colors.utils.tab_bar.session_tab.fg_color,
        colors.utils.tab_bar.session_tab.bg_color
      )
      _push(GLYPH_SEMI_CIRCLE_RIGHT, colors.indexed[18], colors.utils.transparent)
    end
    _push(' ', colors.utils.transparent, colors.utils.transparent)

    window:set_left_status(wezterm.format(__cells__))
  end)
end

return M
